# Charger les packages nécessaires
list.of.packages <- c("shiny","DT","readr","ruODK","openxlsx")
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

# Chemin relatif vers le fichier const_submissions généré
const_submissions_path <- "scripts/const_submissions.RData"

# Fonction pour obtenir le dernier fichier par extension dans le dossier "data"
get_latest_file <- function(extension, prefix) {
  files <- list.files("data", pattern = paste0(prefix, ".*\\.", extension), full.names = TRUE)
  if (length(files) > 0) {
    latest_file <- files[order(file.info(files)$mtime, decreasing = TRUE)][1]
    return(latest_file)
  } else {
    return(NULL)
  }
}

now <- function () {
  gsub(":","_",gsub(" ","_",gsub("-","_",gsub(" CEST","",Sys.time()))))}

# Exécuter le script de mise à jour des données pour Tirages
#system("Rscript scripts/get_App_Tirage_data.R", wait = TRUE)

# Exécuter le script de mise à jour des données pour Tirages
#system("Rscript scripts/get_App_Identif_tiques_data.R", wait = TRUE)
