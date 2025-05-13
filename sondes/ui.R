library(shinyalert)
library(DT)
library(shinyjs)

shinyUI(
  fluidPage(
    #useShinyalert(),
    # Ajout de l'image en bandeau
    div(
      tags$img(src = "test_Bandeau_CEFS_enligne.jpg", width = "90%", height = "auto"),  # Affiche l'image avec largeur complète
      style = "text-align: center; margin: 0 auto;"  # Centre l'image et la marge
    ),
    br(),
    # Définition du panel de contenu
    tabPanel("",
             fluidRow(
               shinyjs::useShinyjs(),  # Charger shinyjs
               #shinyalert::useShinyalert(),  # Charger shinyalert
               
               # Colonne vide pour espacement à gauche
               column(4),
               
               # Colonne pour le champ de téléchargement du fichier
               column(2, 
                      fileInput("file", "Télécharger le fichier de données",
                                accept = c(".txt"),
                                buttonLabel = "Parcourir..."),
                      style = "margin-top:25px;"),
               
               # Colonne pour le bouton "Importer les données"
               column(2, 
                      actionButton("import_btn", "Importer les données", class = "btn-success"),
                      style = "margin-top:49px;"),
               
               # Colonne vide pour espacement à droite
               column(4),
               # Colonne pour afficher le texte d'aide en bleu et avec des sauts de ligne
               column(4, 
                      helpText(HTML(
                        "<span style=font-weight: bold;'>Aide: Le fichier doit être un fichier texte.</span><br/>",  # Première phrase
                        "<span style=font-weight: bold;'>Le paramètre 'Trip Description' de la sonde doit contenir le code Pyrtick de l'altitude exacte.</span><br/>",  # Deuxième phrase
                        "<span style=font-weight: bold;'>Le paramètre 'Timezone' doit être positionné sur UTC +00:00.</span><br/>"  # Troisième phrase
                      )),
                      style = "display: flex; justify-content: center; align-items: center;"),  # Espacement pour séparer les éléments
               br(),
               br(),  # Espacement entre les sections
               column(12),
               # Colonne pour centrer les boutons d'exportation
               column(4),
               column(2,
                      downloadButton("import_full_csv", "Exporter toutes les données (csv2)", class = "btn-primary")),
               column(2,
                      downloadButton("import_filtered_zip", "Exporter les données filtrées (zip)", class = "btn-primary")),
               column(4),
                      br(), br(),  # Espacement avant le résultat et le tableau
                      verbatimTextOutput("import_result"),  # Affichage du résultat de l'importation
                      DTOutput("data_table")  # Affichage du tableau interactif des données
               )
             )
    )
  )
