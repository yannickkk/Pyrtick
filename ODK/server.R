# Serveur de l'application
server <- function(input, output, session) {
  
  # Chargement initial des fichiers les plus récents pour Tirages et Identif
  filepath_tirages <- reactiveVal(get_latest_file("csv", "App_Tirage"))
  filepath_identif <- reactiveVal(get_latest_file("csv", "App_Identif_tiques"))

  # Charger les données d'un fichier CSV
  load_data <- function(filepath) {
    tryCatch({
      read.csv2(filepath)
    }, error = function(e) {
      data.frame()  # Retourner un dataframe vide en cas d'erreur
    })
  }
  
  # Fonction pour récupérer la date de modification du fichier
  get_file_version <- function(filepath) {
    if (!is.null(filepath)) {
      format(file.info(filepath)$mtime, "%Y-%m-%d %H:%M:%S")  # Récupérer la date de dernière modification
    } else {
      NA
    }
  }
  
  # Affichage initial de la version des fichiers
  output$file_version_tirages <- renderText({
    paste("Version du fichier des tirages de tiques :", get_file_version(filepath_tirages()))
  })
  
  output$file_version_identif <- renderText({
    paste("Version du fichier des identifications de tiques :", get_file_version(filepath_identif()))
  })
  
  # Initialisation des tableaux de données au démarrage
  output$table_tirages <- renderDT({
    datatable(load_data(filepath_tirages()), options = list(pageLength = 10, autoWidth = TRUE), filter = "top")
  })
  
  output$table_identif <- renderDT({
    datatable(load_data(filepath_identif()), options = list(pageLength = 10, autoWidth = TRUE), filter = "top")
  })
  
  # Mise à jour des données pour l'onglet Tirages lors de l'appui sur le bouton Maj
  observeEvent(input$maj_tirages, {
    showModal(modalDialog("Mise à jour en cours...", footer = NULL))
    
    # Exécuter le script de mise à jour des données pour Tirages
    system("Rscript scripts/get_App_Tirage_data.R", wait = TRUE)
    
    # Récupérer le dernier fichier pour Tirages
    filepath_tirages(get_latest_file("csv", "App_Tirage"))
    
    # Mettre à jour le tableau avec les nouvelles données
    output$table_tirages <- renderDT({
      datatable(load_data(filepath_tirages()), options = list(pageLength = 10, autoWidth = TRUE), filter = "top")
    })
    
    ####maj version du fichier
    output$file_version_tirages <- renderText({
      paste("Version du fichier des tirages de tiques :", get_file_version(filepath_tirages()))
    })
    
     
    removeModal() ###arrête la barre d'attente
  })
  
  # Mise à jour des données pour l'onglet Identif lors de l'appui sur le bouton Maj
  observeEvent(input$maj_identif, {
    showModal(modalDialog("Mise à jour en cours...", footer = NULL))
    
    # Exécuter le script de mise à jour des données pour Tirages
    system("Rscript scripts/get_App_Identif_tiques_data.R", wait = TRUE)
    
    # Récupérer le dernier fichier pour Identif
    filepath_identif(get_latest_file("csv", "App_Identif_tiques"))
    
    # Mettre à jour le tableau avec les nouvelles données
    output$table_identif <- renderDT({
      datatable(load_data(filepath_identif()), options = list(pageLength = 10, autoWidth = TRUE), filter = "top")
    })
    
    ####maj version du fichier
    output$file_version_identif <- renderText({
      paste("Version du fichier des identifications de tiques :", get_file_version(filepath_identif()))
    })
    
    removeModal()
  })
  
  # Téléchargement des fichiers pour Tirages
  output$download_csv_tirages_full <- downloadHandler(
    filename = function() { basename(get_latest_file("csv", "App_Tirage")) },
    content = function(file) { file.copy(get_latest_file("csv", "App_Tirage"), file) }
  )
  
  output$download_xlsx_tirages_full <- downloadHandler(
    filename = function() { basename(get_latest_file("xlsx", "App_Tirage")) },
    content = function(file) { file.copy(get_latest_file("xlsx", "App_Tirage"), file) }
  )
  
  # Téléchargement des fichiers pour Identif
  output$download_csv_identif_full <- downloadHandler(
    filename = function() { basename(get_latest_file("csv", "App_Identif_tiques")) },
    content = function(file) { file.copy(get_latest_file("csv", "App_Identif_tiques"), file) }
  )
  
  output$download_xlsx_identif_full <- downloadHandler(
    filename = function() { basename(get_latest_file("xlsx", "App_Identif_tiques")) },
    content = function(file) { file.copy(get_latest_file("xlsx", "App_Identif_tiques"), file) }
  )
  
  # Téléchargement des fichiers filtrés pour Tirages en CSV
  output$download_csv_tirages_filtered <- downloadHandler(
    filename = function() { paste("Tirages_filtres_",now(), ".csv", sep = "") },
    content = function(file) {
      # Récupérer les lignes filtrées de la table
      data_filtered <- load_data(filepath_tirages())[input$table_tirages_rows_all, ]
      write.csv2(data_filtered, file, row.names = FALSE)
    }
  )
  
  # Téléchargement des fichiers filtrés pour Tirages en XLSX
  output$download_xlsx_tirages_filtered <- downloadHandler(
    filename = function() { paste("Tirages_filtres_",now(), ".xlsx", sep = "") },
    content = function(file) {
      # Récupérer les lignes filtrées de la table
      data_filtered <- load_data(filepath_tirages())[input$table_tirages_rows_all, ]
      write.xlsx(data_filtered, file)
    }
  )
  
  # Téléchargement des fichiers filtrés pour Identif en CSV
  output$download_csv_identif_filtered <- downloadHandler(
    filename = function() { paste("Identif_filtres_",now(), ".csv", sep = "") },
    content = function(file) {
      # Récupérer les lignes filtrées de la table
      data_filtered <- load_data(filepath_identif())[input$table_identif_rows_all, ]
      write.csv2(data_filtered, file, row.names = FALSE)
    }
  )
  
  # Téléchargement des fichiers filtrés pour Identif en XLSX
  output$download_xlsx_identif_filtered <- downloadHandler(
    filename = function() { paste("Identif_filtres_",now(), ".xlsx", sep = "") },
    content = function(file) {
      # Récupérer les lignes filtrées de la table
      data_filtered <- load_data(filepath_identif())[input$table_identif_rows_all, ]
      write.xlsx(data_filtered, file)
    }
  )
}