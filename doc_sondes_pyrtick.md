# Documention de l'application d'importation et de visualisation des données des sondes de température/hygrométrie du projet Pyrtick.

Les sondes de température/hygrométrie mises en oeuvre pour se projet sont de type
[Elitech RC-51H](https://www.elitechus.com/en-fr/products/elitech-rc-51h-usb-temperature-and-humidity-data-logger-pen-styled-auto-pdf-temperature-record-32000-points?srsltid=AfmBOoqhAZadzewSb3Je3Q_kohTDsk3zsS8ujRo0u9b_uj-2gW5fvSn8)

Pour télécharger les données depuis votre ordinateur, appuyez sur l'onglet parcourir... et sélectionner le fichier à importer.

> [!CAUTION]
> Le fichier doit être un fichier d'export de sonde au format texte (.txt)
> Le champ 'Trip Description' du fichier texte dois contenir le code Pyrtick de l'altitude concernée se référer au [procédure d’identification des échantillons du CEFS](https://sites.inrae.fr/site/cefs/UNITE_UR0035/Qualite/Manuel_Qualite_CEFS/Documents%20partages/Protocoles_valid%C3%A9s/Collections/Collection_procedure_identif_echantillons_donnees_passeport.html)
> Le paramètre 'Timezone' doit être positionné sur UTC +00:00

Ses information sont rappelées en haut à droite en gris sur la page de l'application:

<img width="532" height="71" alt="Image" src="https://github.com/user-attachments/assets/160203ee-1412-4718-98e1-46f2314c9057" />

une fois le fichier téléchargé par l'application, appuyez sur le bouton vert "importer les données" pour déclencher l'importation des données.

Une fois l'opération réalisée appuyez sur MAJ pour mettre à jour l'affichage.

Les données et les méta données du fichiers sont importés dans la base de données db_pyrtick. Le résultat affiché sur l'application est une synthèse des données et des méta données pour chaque relevé de température/hygrométrie de la sonde ainsi que de sa position géographique lors du relevé.

On peut ensuite trier les données. Dans la capture d'écran ci-dessous, on filtre les données pour n'avoir que les enregistrements pour n'avoir que la période durant laquelle la température était comprise entre 10,8 et 20,8 °C.

<img width="1913" height="957" alt="Image" src="https://github.com/user-attachments/assets/726a49d9-a88a-4499-8498-581f4f284fe4" />

