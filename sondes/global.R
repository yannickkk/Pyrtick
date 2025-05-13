# global.R
#####S3: savegarde du fichier soumis sur le S3 pyrtick/DonneesBrutes/data/data_sondes
endpoints3<-"xxxxxxxxxxxxxxxxxxx"
buckets3<-"xxxxxxxxxxxxxxx" ##bucket de sauvegarde des données
paths3<-"DonneesBrutes/data/data_sondes" ###chemin à l'intérieur du bucket dans lequel on veut sauvegarder le fichier

source("genetique.R") #informations de connexion au stockage S3 CEFS

# Charger les packages nécessaires
list.of.packages <- c("shinybusy","lubridate", "sf", "RPostgres", "data.table", "shiny", "shinyalert", "DBI", "stringr","aws.s3")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
if (length(new.packages) > 0) {
  install.packages(new.packages, dependencies = TRUE)
}

suppressPackageStartupMessages({
  lapply(list.of.packages, library, character.only = TRUE)
})


# Connexion à la base de données
# Remplacez par vos informations
#source("C:/Users/ychaval/Documents/BD_Pyrtick/Programmes/R/con_prod_pyrtick.R")
#source("C:/Users/ychaval/Documents/BD_tools/Mes_fonctions_R/fonctions.R")
source("/srv/con_prod_pyrtick.r")
source("/srv/fonctions.R")


# Fonction pour extraire les métadonnées
extract_metadata <- function(dat) {
  metadata <- dat[4:match("No.\tTime\t\t°C\t%RH", dat) - 2]
  metadata <- gsub("[[:space:]]+", " ", metadata)
    altitude_id = gsub("Trip Description : ", "", trimws(metadata[grep("Trip Description : ", metadata)]))
    timezone = gsub("Timezone : ", "", trimws(metadata[grep("Timezone : ", metadata)]))
    creation<-gsub("File created on:","",trimws(metadata[grep("File created on:",metadata)]))
    model<-gsub("Model : ","",trimws(metadata[grep("Model : ",metadata)]))
    logger_id<-gsub("S/N : ","",trimws(metadata[grep("S/N : ",metadata)]))
    firmware_version<-gsub("Firmware Version : ","",trimws(metadata[grep("Firmware Version : ",metadata)]))
    trip_code<-gsub("Trip Code :","",trimws(metadata[grep("Trip Code : ",metadata)]))
    altitude_id<-gsub("Trip Description : ","",trimws(metadata[grep("Trip Description : ",metadata)]))
    start_mode<-gsub("Start Mode : ","",trimws(metadata[grep("Start Mode : ",metadata)]))
    logging_interval<-gsub("Logging Interval : ","",trimws(metadata[grep("Logging Interval : ",metadata)]))
    start_delay<-gsub("Start Delay : ","",trimws(metadata[grep("Start Delay : ",metadata)]))
    repeat_start<-gsub("Repeat Start : ","",trimws(metadata[grep("Repeat Start : ",metadata)]))
    timezone<-gsub("Timezone : ","",trimws(metadata[grep("Timezone : ",metadata)]))
    stop_mode<-gsub("Stop Mode : ","",trimws(metadata[grep("Stop Mode : ",metadata)]))
    light<-gsub("Light : ","",trimws(metadata[grep("Light : ",metadata)]))
    alarm_logging_interval_shorten<-gsub("Alarm Logging Interval Shorten : ","",trimws(metadata[grep("Alarm Logging Interval Shorten : ",metadata)]))
    mark_time<-trimws(metadata[grep("Mark Time : ",metadata)+1])
    first_reading<-gsub("First Reading : ","",trimws(metadata[grep("First Reading : ",metadata)]))
    last_reading<-gsub("Last Reading : ","",trimws(metadata[grep("Last Reading : ",metadata)]))
    current_readings<-gsub("Current Readings : ","",trimws(metadata[grep("Current Readings : ",metadata)]))
    logging_duration<-gsub("Logging Duration : ","",trimws(metadata[grep("Logging Duration : ",metadata)]))
    maximum_t<-gsub(",",".",gsub("\\°C","",unlist(lapply(str_split(gsub("Maximum : ","",trimws(metadata[grep("Maximum : ",metadata)]))," / "),"[[",1))))
    minimum_t<-gsub(",",".",gsub("\\°C","",unlist(lapply(str_split(gsub("Minimum : ","",trimws(metadata[grep("Minimum : ",metadata)]))," / "),"[[",1))))
    average_t<-gsub(",",".",gsub("\\°C","",unlist(lapply(str_split(gsub("Average : ","",trimws(metadata[grep("Average : ",metadata)]))," / "),"[[",1))))
    maximum_h<-gsub(",",".",gsub("%RH","",unlist(lapply(str_split(gsub("Maximum : ","",trimws(metadata[grep("Maximum : ",metadata)]))," / "),"[[",2))))
    minimum_h<-gsub(",",".",gsub("%RH","",unlist(lapply(str_split(gsub("Minimum : ","",trimws(metadata[grep("Minimum : ",metadata)]))," / "),"[[",2))))
    average_h<-gsub(",",".",gsub("%RH","",unlist(lapply(str_split(gsub("Average : ","",trimws(metadata[grep("Average : ",metadata)]))," / "),"[[",2))))
    mean_kinetic_temperature_mkt<-gsub(",",".",gsub("\\°C","",gsub("MeanKineticTemperature\\(MKT\\):","",wsr(metadata[grep("Mean Kinetic",metadata)]))))
    first_alarm_temperature<-gsub("First Alarm\\(Temperature\\) : ","",trimws(metadata[grep("First Alarm\\(Temperature\\) : ",metadata)]))
    first_alarm_humidity<-gsub("First Alarm\\(Humidity\\) : ","",trimws(metadata[grep("First Alarm\\(Humidity\\) : ",metadata)]))
   
    return(data.frame(creation,model,logger_id,firmware_version,trip_code,altitude_id,start_mode,logging_interval,start_delay,repeat_start,timezone,stop_mode,light,alarm_logging_interval_shorten,mark_time,first_reading,last_reading,current_readings,logging_duration,maximum_t,minimum_t,average_t,maximum_h,minimum_h,average_h,mean_kinetic_temperature_mkt,first_alarm_temperature,first_alarm_humidity))
}

# Fonction pour vérifier l'altitude
check_altitude <- function(altitude_id, pyrtick) {
  query <- paste0("SELECT altitude_id FROM altitudes WHERE LOWER(altitude) = LOWER('", altitude_id, "')")
  result <- dbGetQuery(pyrtick, query)
  if (nrow(result) == 0) {
    stop("L'altitude définie dans le champ 'Trip Description' de la sonde ne correspond à aucune altitude connue dans la base de données.")
  }
  result$altitude_id[1]
}

# Fonction pour vérifier et initialiser les tables et vues nécessaires
initialize_database <- function(conn) {
  # Vérifier et créer la table metadata
  if (!dbExistsTable(pyrtick, "metadata")) {
    dbExecute(pyrtick, "
      CREATE TABLE metadata (
        metadata_id SERIAL PRIMARY KEY,
        altitude_id INT,
        creation TIMESTAMP,
        model varchar,
        logger_id varchar,
        firmware_version varchar,
        trip_code varchar,
        start_mode varchar,
        logging_interval varchar,
        start_delay varchar,
        repeat_start varchar,
        timezone varchar,
        stop_mode varchar,
        light varchar,
        alarm_logging_interval_shorten varchar,
        mark_time varchar,
        first_reading TIMESTAMP,
        last_reading TIMESTAMP,
        current_readings INT,
        logging_duration varchar,
        maximum_t FLOAT,
        minimum_t FLOAT,
        average_t FLOAT,
        maximum_h FLOAT,
        minimum_h FLOAT,
        average_h FLOAT,
        mean_kinetic_temperature_mkt FLOAT,
        first_alarm_temperature varchar,
        first_alarm_humidity varchar,
        timestamp_import timestamp,
      )
    ")
  }
  if (!dbGetQuery(pyrtick, "
  SELECT EXISTS (
    SELECT 1
    FROM pg_constraint AS con
    INNER JOIN pg_class AS rel ON con.conrelid = rel.oid
    INNER JOIN pg_namespace AS nsp ON rel.relnamespace = nsp.oid
    WHERE con.conname = 'metadata_unique'
      AND nsp.nspname = 'public'
      AND rel.relname = 'metadata'
  )
")$exists){
  dbExecute(pyrtick, "
    ALTER TABLE public.metadata
    ADD CONSTRAINT metadata_unique UNIQUE (altitude_id, creation);")}
  
  # Vérifier et créer la table surveys
  if (!dbExistsTable(pyrtick, "surveys")) {
    dbExecute(pyrtick, "
      CREATE TABLE surveys (
        survey_id SERIAL PRIMARY KEY,
        metadata_id INT REFERENCES metadata(metadata_id) ON DELETE CASCADE,
        numbers INT,
        timestamp_utc TIMESTAMP WITHOUT TIME ZONE,
        timestamp_cest TIMESTAMP WITH TIME ZONE,
        temperature FLOAT,
        hygrometry FLOAT
      )
    ");
    dbExecute(pyrtick, "
    ALTER TABLE public.surveys
    ADD CONSTRAINT survey_unique UNIQUE (metadata_id,timestamp_utc);"
      )
  }
  
  # Vérifier et créer la vue
  dbExecute(conn, "
    CREATE OR REPLACE VIEW v_altitudes_temperatures AS
    SELECT 
      a.altitude as altitude,
      s.timestamp_utc as dateheure_utc,
      ((s.timestamp_utc::timestamp with time zone AT TIME ZONE 'Europe/Paris'::text) AT TIME ZONE 'UTC'::text) dateheure_cet,
      s.temperature as temperature,
      s.hygrometry as hygrometry,
      ST_x(a.geometry) as longitude,
      ST_y(a.geometry) as latitude,
      a.collecting_organization as organization,
      a.country as country, 
      a.valley as valley,
      a.elevation,
      m.metadata_id, 
      a.altitude_id, 
      creation, 
      model, 
      logger_id, 
      firmware_version, 
      trip_code, 
      start_mode, 
      logging_interval, 
      start_delay, 
      repeat_start, 
      timezone, 
      stop_mode, 
      light, 
      alarm_logging_interval_shorten, 
      mark_time, 
      first_reading, 
      last_reading, 
      current_readings, 
      logging_duration, 
      maximum_t, 
      minimum_t, 
      average_t, 
      maximum_h, 
      minimum_h, 
      average_h, 
      mean_kinetic_temperature_mkt, 
      first_alarm_temperature, 
      first_alarm_humidity,
      a.geometry,
      m.timestamp_import
      
    FROM metadata m
    LEFT JOIN altitudes a ON m.altitude_id = a.altitude_id
    LEFT JOIN surveys s ON m.metadata_id = s.metadata_id  ")
}

# Initialiser la base de données
initialize_database(pyrtick)

# Construire une requête SQL pour `INSERT ON CONFLICT`
sql_insert_metadata <- function(metadata_final)(gsub("[\r\n]", " ",paste0("
INSERT INTO public.metadata (
    altitude_id, creation, model, logger_id, firmware_version, trip_code, start_mode, 
    logging_interval, start_delay, repeat_start, timezone, stop_mode, light, 
    alarm_logging_interval_shorten, mark_time, first_reading, last_reading, 
    current_readings, logging_duration, maximum_t, minimum_t, average_t, 
    maximum_h, minimum_h, average_h, mean_kinetic_temperature_mkt, 
    first_alarm_temperature, first_alarm_humidity, timestamp_import
) VALUES (
    ",metadata_final$altitude_id,",'",metadata_final$creation,"','",metadata_final$model,"'
    ,'",metadata_final$logger_id,"','",metadata_final$firmware_version,"','",metadata_final$trip_code,"'
    ,'",metadata_final$start_mode,"','",metadata_final$logging_interval,"','",metadata_final$start_delay,"'
    ,'",metadata_final$repeat_start,"','",metadata_final$timezone,"','",metadata_final$stop_mode,"'
    ,'",metadata_final$light,"','",metadata_final$alarm_logging_interval_shorten,"','",metadata_final$mark_time,"'
    ,'",metadata_final$first_reading,"','",metadata_final$last_reading,"','",metadata_final$current_readings,"'
    ,'",metadata_final$logging_duration,"','",metadata_final$maximum_t,"','",metadata_final$minimum_t,"'
    ,'",metadata_final$average_t,"','",metadata_final$maximum_h,"','",metadata_final$minimum_h,"'
    ,'",metadata_final$average_h,"','",metadata_final$mean_kinetic_temperature_mkt,"','",metadata_final$first_alarm_temperature,"','",metadata_final$first_alarm_humidity,"','",metadata_final$timestamp_import,"'
)
ON CONFLICT (altitude_id, creation) DO UPDATE 
SET 
    model = EXCLUDED.model,
    logger_id = EXCLUDED.logger_id,
    firmware_version = EXCLUDED.firmware_version,
    trip_code = EXCLUDED.trip_code,
    start_mode = EXCLUDED.start_mode,
    logging_interval = EXCLUDED.logging_interval,
    start_delay = EXCLUDED.start_delay,
    repeat_start = EXCLUDED.repeat_start,
    timezone = EXCLUDED.timezone,
    stop_mode = EXCLUDED.stop_mode,
    light = EXCLUDED.light,
    alarm_logging_interval_shorten = EXCLUDED.alarm_logging_interval_shorten,
    mark_time = EXCLUDED.mark_time,
    first_reading = EXCLUDED.first_reading,
    last_reading = EXCLUDED.last_reading,
    current_readings = EXCLUDED.current_readings,
    logging_duration = EXCLUDED.logging_duration,
    maximum_t = EXCLUDED.maximum_t,
    minimum_t = EXCLUDED.minimum_t,
    average_t = EXCLUDED.average_t,
    maximum_h = EXCLUDED.maximum_h,
    minimum_h = EXCLUDED.minimum_h,
    average_h = EXCLUDED.average_h,
    mean_kinetic_temperature_mkt = EXCLUDED.mean_kinetic_temperature_mkt,
    first_alarm_temperature = EXCLUDED.first_alarm_temperature,
    first_alarm_humidity = EXCLUDED.first_alarm_humidity,
    timestamp_import = EXCLUDED.timestamp_import;
")))

sql_insert_surveys <- function(datt) {
  paste0(
    "INSERT INTO public.surveys (",
    "metadata_id, numbers, timestamp_utc, timestamp_cest, temperature, hygrometry",
    ") VALUES (",
    datt$metadata_id, ",",               # metadata_id est un entier, pas besoin de guillemets
    datt$number, ",",                    # number est aussi un entier
    "'", datt$timestamp_utc, "',",       # timestamp_utc est une chaîne de caractères, donc entouré de guillemets
    "'", datt$timestamp_utc, "',",       # timestamp_cest est supposé être le même que timestamp_utc (ajustez si besoin)
    datt$temperature, ",",               # temperature est un nombre (pas de guillemets)
    datt$hygrometry, ") ",               # hygrometry est un nombre (pas de guillemets)
    "ON CONFLICT (metadata_id, timestamp_utc) DO NOTHING;"
  )
}

