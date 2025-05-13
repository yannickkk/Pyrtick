#-----------------------   Projet Pyrtick    -------------------------------
#-----------------------    App_Tirage      --------------------------------
#----------------------------------------------------------------------------
# Auteur: Yannick Chaval
# Date: 06/11/2024
# Version: 1.0.0
# Description: récupération des données du formulaire App_Tirage sur ODK central et archivage des données sur le S3 au format csv2 et xlsx
# Documentation:
#------------------------------------------------------------------------------
#-------------------------- environnement de travail --------------------------
#------------------------------------------------------------------------------
# Charger les packages nécessaires
list.of.packages <- c("readr","ruODK","openxlsx")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages) > 0){
  install.packages(new.packages, dep=TRUE)
  
}
#loading packages
for(package.i in list.of.packages){
  suppressPackageStartupMessages(
    library(
      package.i, 
      character.only = TRUE
    )
  )
}
###ODK central
projet="CEFS"
#####Chemin vers le dossier local ou l'on veut stocker les données.
csv<-"data"
xlsx<-"data"
#source le code des différents scripts R utilisés
source("scripts/fonctions.r")				# Script des fonctions utilisées
source("scripts/informations_connexion.r")	# Constantes confidentielles de login à la plateforme

formulaire<- "App_Tirage_V.1.0"
source("scripts/constantes.r")				# Script contenant les variables / constantes à personnaliser seln votre usage ...

#####connexion à ODK central
connexion_odkcentral(serveur=url_odk_central,username=login_odk,password=mot_de_passe)
#Utilise l'API pour récupérer un fichier CSV fusionné des soumissions
#recupere_soumission(nom_du_projet=projet,nom_du_formulaire=formulaire,mode_extraction="API",filtre_date="",mode_sortie="CSV",dossier_sortie=csv,mode_full=FALSE)
initialise_service_recuperation(projet,formulaire)
dat<-as.data.frame(odata_submission_get(table="Submissions",filter="",download="TRUE", local_dir="temp"))
###renommage des colonnes
names(dat)<-gsub("single_page_1_|single_page_2_","",names(dat))
####on enleve les retours chariots
if (length(gsub("\n","",dat$remarks)) !=0) {dat$remarks<-gsub("\n","",dat$remarks)}
###dat n'est pas un df mais un array avec $point qui est une liste, comme les informations sont stockées par ailleurs on peut supprimer la liste
dat<-dat[,-grep("^point$",names(dat))]
###supression des vieux fichiers
if (dim(dat)[1] !=0) {
# Liste tous les fichiers dans le dossier qui contiennent "Tirage" dans leur nom
fichiers_a_supprimer <- list.files(csv, pattern = "Tirage", full.names = TRUE)
# Supprime les fichiers listés
file.remove(fichiers_a_supprimer)
}
####reccupération des données
write.table(dat,file.path(csv,paste0(const_submissions,".csv")),row.names = FALSE,quote=FALSE,na="", sep=";", fileEncoding = "UTF-8")
####ecriture au format xlsx
write.xlsx(dat, file = file.path(xlsx,paste0(const_submissions,".xlsx")), overwrite = TRUE)
