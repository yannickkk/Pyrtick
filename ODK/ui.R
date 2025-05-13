# Interface utilisateur
ui <- fluidPage(
  # Ajout de l'image en bandeau
  div(
  tags$img(src = "test_Bandeau_CEFS_enligne.jpg", width = "90%", height = "auto"),  # Affiche l'image avec largeur complète
  style = "text-align: center; margin: 0 auto;"  # Centre l'image et la marge
  ),
  br(),
  tabsetPanel(
    # Onglet Tirages
    tabPanel(
      h4("Tirages"),
      br(),
      # Affichage de la version du fichier
      fluidRow(
        column(12, textOutput("file_version_tirages"), align = "left")  # Centré et pleine largeur
      ),
      br(),
      fluidRow(
        column(1),
        column(2, actionButton("maj_tirages", "MAJ")),
        column(2, downloadButton("download_csv_tirages_full", "CSV_Entier")),
        column(2, downloadButton("download_csv_tirages_filtered", "CSV_Filtré")),
        column(2, downloadButton("download_xlsx_tirages_full", "XLSX_Entier")),
        column(2, downloadButton("download_xlsx_tirages_filtered", "XLSX_Filtré")),
        column(1)
      ),
      br(),
      DTOutput("table_tirages")
    ),
    
    # Onglet Identif
    tabPanel(
      h4("Identifications"),
      br(),
      # Affichage de la version du fichier
      fluidRow(
        column(12, textOutput("file_version_identif"), align = "left")  # Centré et pleine largeur
      ),
      br(),
      fluidRow(
        column(1),
        column(2, actionButton("maj_identif", "MAJ")),
        column(2, downloadButton("download_csv_identif_full", "CSV_Entier")),
        column(2, downloadButton("download_csv_identif_filtered", "CSV_Filtré")),
        column(2, downloadButton("download_xlsx_identif_full", "XLSX_Entier")),
        column(2, downloadButton("download_xlsx_identif_filtered", "XLSX_Filtré")),
        column(1)
      ),
      br(),
      DTOutput("table_identif")
    )
  )
)