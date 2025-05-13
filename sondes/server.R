# server.R

library(shiny)
library(shinyalert)
library(DBI)
library(stringr)
library(DT)  # Pour afficher le tableau interactif
library(data.table)  # Pour manipuler les data.table

shinyServer(function(input, output, session) {
  
  # Variable pour stocker les données du tableau
  data_for_table <- reactiveVal(NULL)
  
  # Mise à jour de la variable réactive avec le résultat de la requête
  observe({
    ######chargement des données
    query <<- "SELECT altitude, dateheure_utc,dateheure_cet, temperature, hygrometry, organization, country, valley, longitude, latitude, elevation, metadata_id, altitude_id, creation, model, logger_id, firmware_version, trip_code, start_mode, logging_interval, start_delay, repeat_start, timezone, stop_mode, light, alarm_logging_interval_shorten, mark_time, first_reading, last_reading, current_readings, logging_duration, maximum_t, minimum_t, average_t, maximum_h, minimum_h, average_h, mean_kinetic_temperature_mkt, first_alarm_temperature, first_alarm_humidity, timestamp_import
            FROM public.v_altitudes_temperatures;"
    
    data <- dbGetQuery(pyrtick, query)
    data <- utf8(dbGetQuery(pyrtick, query)) # Assurez-vous que vos données sont encodées correctement
    data_for_table(data)       # Mise à jour de la variable réactive
  })
  
  observeEvent(input$import_btn, {
    req(input$file)  # Vérifie qu'un fichier est fourni
    
    # Vérification de l'extension
    if (tools::file_ext(input$file$name) != "txt") {
      shinyalert("Erreur", "Format de fichier non conforme, vous devez fournir un fichier .txt", type = "error")
      return(NULL)
    }
    
    tryCatch({
      # sauvegarde du fichier soumis sur le S3
      put_object(
        file = input$file$datapath,          # chemin vers Fichier local
        object = file.path(paths3,input$file$name),   # Chemin cible dans le bucket incluant le nom du fichier
        bucket = buckets3,               # Nom du bucket
        region = "",                   # Garder vide pour les S3 compatibles sans région
        base_url = endpoints3         # Endpoint inrae
      )
      dat <<- iconv(readLines(input$file$datapath), from = "latin1", to = "UTF-8")
      metadata <- dat[4:(match("No.\tTime\t\t°C\t%RH", dat) - 2)]
      metadata <<- gsub("[[:space:]]+", " ", metadata)
      datt <<- read.table(
        text = dat[match("No.\tTime\t\t°C\t%RH", dat):length(dat)],
        sep = "\t", header = TRUE, stringsAsFactors = FALSE, fileEncoding = "UTF-8"
      )[, c(1:4)]
      names(datt)<-c("numbers","timestamp_utc","temperature","hygrometry")
      datt$temperature<-gsub(",",".",datt$temperature)
      datt$hygrometry<-gsub(",",".",datt$hygrometry)
      
      if (length(which(datt$temperature =="NC") != 0)) {datt<-datt[-which(datt$temperature == "NC"),]}
      
      erreur <<-0
      # Extraction des métadonnées
      metadata_final <- cbind(extract_metadata(dat),timestamp_import = substr(Sys.time(),1,19))
      
      # Vérification que 'altitude_id' et 'timezone' sont non vides
      if (metadata_final$timezone != "UTC +00:00") {
        shinyalert("Erreur", "Le paramètre Timezone n'est pas correctement défini sur UTC +00:00.", type = "error")
        erreur <<-1
      }
      if (metadata_final$altitude_id == "") {
        shinyalert("Erreur", "L'altitude définie dans 'Trip Description' est manquante ou incorrecte.", type = "error")
        erreur <<-1
      }
      
      # Vérification de l'altitude dans la base de données
      alt <- metadata_final$altitude_id
      metadata_final$altitude_id <- as.integer(dbGetQuery(pyrtick, paste0("SELECT altitude_id FROM altitudes WHERE altitude = '", metadata_final$altitude_id, "'")))
      if (length(metadata_final$altitude_id) == 0) {
        shinyalert("Erreur", "L'altitude définie n'est pas connue. Veuillez corriger le fichier ou contacter l'administrateur.", type = "error")
        erreur <<-1
      }
      
      # Vérification que les métadonnées ont bien été extraites
      if (any(is.na(metadata_final))) {
        shinyalert("Erreur", "Certains champs des métadonnées sont manquants. Veuillez vérifier votre fichier.", type = "error")
        erreur <<-1
      }
      
      dbExecute(pyrtick, sql_insert_metadata(metadata_final))
      #dbAppendTable(pyrtick, "metadata", metadata_final)
      metadata_id <- dbGetQuery(pyrtick, paste0("Select metadata_id from metadata where creation = '", metadata_final$creation,"' and altitude_id = '", metadata_final$altitude_id,"'"))
      
      datt <- cbind(metadata_id = metadata_id, datt)
      
      if (erreur == 0){
      show_modal_spinner(spin = sample(c("flower", "pixel", "hollow-dots", "intersecting-circles", "orbit", "radar",
                                         "scaling-squares", "half-circle", "trinity-rings", "fulfilling-square",
                                         "circles-to-rhombuses", "semipolar", "self-building-square", "swapping-squares",
                                         "fulfilling-bouncing-circle", "fingerprint", "spring", "atom", "looping-rhombuses",
                                         "breeding-rhombus"),1),
                         color = "firebrick",text = "Veuillez patientier, l'intégration dans la base de données est en cours")
      
      for (i in 1:dim(datt)[1]){
      dbExecute(pyrtick, sql_insert_surveys(datt)[i])
      }
    
      remove_modal_spinner()
      
      shinyalert("Succès", paste(nrow(datt), "lignes importées dans la table surveys pour l'altitude", alt), type = "success")
    }
      
    }, error = function(e) {
      shinyalert("Erreur", paste("Problème lors de l'importation:", e$message), type = "error")
    })
  })
  
  # Affichage du tableau interactif
  output$data_table <- renderDT({
    req(data_for_table())  # Assurez-vous que les données sont disponibles
    datatable(data_for_table(), options = list(pageLength = 10),filter = "top")  # Table interactive avec pagination
  })
  

  ####Exprot des données entières
   output$import_full_csv <- downloadHandler(  
    filename = function() { 
      paste("full_data_probe_", now(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv2(data_for_table(), file, row.names = FALSE, fileEncoding = "UTF-8")
      #shinyalert("Succès", "Le fichier CSV complet a été exporté.", type = "success")
    }
  )

# ####Exprot des données filtrées
# output$import_filtered_csv <- downloadHandler(
#   filename = function() {
#     paste("filtered_data_probe_", now(), ".csv", sep = "")
#   },
#   content = function(file) {
#     filtered_indices <- input$data_table_rows_all  # Récupère les lignes visibles après filtrage
#     filtered_data <- data_for_table()[filtered_indices, ]
#     write.csv2(filtered_data, file, row.names = FALSE, fileEncoding = "UTF-8")
# 
#     #shinyalert("Succès", "Le fichier CSV complet a été exporté.", type = "success")
#   }
# )

output$import_filtered_zip <- downloadHandler(
  filename = function() {
   paste("filtered_data_probe_", gsub("-","_",substr(Sys.time(),1,19)), ".zip", sep = "")
  },
  content = function(file) {
    # Créer des fichiers temporaires pour les données et les donnés filtres
    tim<-gsub("-","_",substr(now(),1,19))
    #filtered_data_file <- paste0("data_probe_filtered_",tim,".csv")
    #filters_file <- paste0("applied_filters_",tim,".txt")
    temp_dir <- tempdir()
    filtered_data_file <- file.path(temp_dir, paste0("data_probe_filtered_", tim, ".csv"))
    filters_file <- file.path(temp_dir, paste0("applied_filters_", tim, ".txt"))
    # Liste de tous les fichiers avec les extensions .csv ou .txt
    #files_to_delete <- list.files(getwd(), pattern = "\\.(csv|txt)$", full.names = TRUE)
    
    # Supprimer les fichiers
    #if (length(files_to_delete) != 0) {file.remove(files_to_delete)}
    
    # 1. Récupérer les données filtrées
    filtered_indices <- input$data_table_rows_all  # Lignes visibles après filtrage
    filtered_data <- data_for_table()[filtered_indices, ]
    n<-names(filtered_data)
    write.csv2(filtered_data, filtered_data_file, row.names = FALSE, fileEncoding = "UTF-8")
    
    ###recherche des filtres appliqués
    applied_filters <- lapply(input$data_table_state$columns, function(x) x$search$search)
    names(applied_filters)<-c("Filtres appliqués sur le jeu de données ",n)
    
    # Écrire les filtres dans un fichier texte
    if (length(applied_filters) > 0) {
      writeLines(paste0(names(applied_filters),':',applied_filters,'\n'), filters_file)
    } else {
      writeLines("Aucun filtre appliqué.", filters_file)
    }

    # 3. Créer un fichier ZIP contenant les deux fichiers
    zip(file, c(filtered_data_file,filters_file), extras = '-j') 
   }
  ,contentType = "application/zip"  # Définit le type MIME pour forcer le téléchargement
  
)


})

