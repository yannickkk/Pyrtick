# Documention de l'application de visualisation des résultats de tirages et de tries de tiques du projet Pyrtick.

Cette application permet à l'utilisateur de visualiser, de trier et de téléchatger les données qu'il a saisi sur le terrain ou au laboratoire à l'aide les formulaires ODK collect:

[App_Tirage_V.1.0.xlsx](https://github.com/yannickkk/ODK/blob/3ea07583a9f5e789567ecdbe847376c4ea4f65ef/PyrTick/App_Tirage_V.1.0.xlsx)

[App_Identif_tiques_V.1.3.xlsx](https://github.com/yannickkk/ODK/blob/3ea07583a9f5e789567ecdbe847376c4ea4f65ef/PyrTick/App_Identif_tiques_V.1.3.xlsx)

## Onglet Tirage

Elle se présente ainsi:

<h2 align="center"> Vue de du premier onglet qui permet l'affichage, le trie et l'exportation des données de tirage.</h2>

![Image](https://github.com/user-attachments/assets/37a52375-3255-4fa2-85dc-fbb994934e75)

> [!NOTE]
> Afin de permettre une ouverture rapide de l'application, celle-ci s'ouvre dans l'état ou elle était lors de sa dernière mise à jour (la date de celle-ci est indiqué en haut à
> gauche "Version du fichier des tirages de tiques : XXXX XXXXX";

> [!TIP]
> Pour avoir un affichage des dernières données, pensez à appuyer sur le bouton de mise à jour "MAJ" en haut à gauche.

Les boutons "CSV_Entier", "CSV_Filtré", "XLSX_Entier", "XLSX_Filtré" servent à exporter les résultats filtrés et bruts (Entier). Le format xlsx est un format xml reconnu par le tableur microsoft Excel (ou par calc) et le format csv est, en fait, un format csv2 (séparateur de colonne ";", séparteur de décimales ",") 

Les fichiers de sorties sont nommés ainsi: App_Tirage_V.1.0_yyyy_mm_dd_hh_mm_ss.csv ou App_Tirage_V.1.0_yyyy_mm_dd_hh_mm_ss.xlsx> [!NOTE]

> [!NOTE]
> Si aucun troie n'est effectué dans le tableau les sorties sont toutes identiques et correspondent au jeu de données brut.

Le tableau d'affichage présente la particularité d'autoriser des tries emboités pour extraire les données. Emboité veut dire que le résultat d'un premier trie sur une colonne est conservé lorsque l'on effectue un second trie sur une autre colonne.

Imaginons que je veuille réccupérer toutes les données de tirage de tiques pour l'alitude 5 en forêt dans le Val d'Azun. Le code échantillon correspondant à cette demande est PT-vaz-5f

### Trie des données

Imaginons que je veuille réccupérer toutes les données de tirage de tiques pour l'alitude 5 en forêt dans le Val d'Azun. Le code échantillon correspondant à cette demande est PT-vaz-5f. On rentre donc cette donnée dans le cadre de trie de la colonne code_echantillon

Le résultat se présente ainsi:

![Image](https://github.com/user-attachments/assets/d9a66306-9e09-468c-a627-b3b741d35d8b)

Pour ne conservé de ce trie que les données pour lesquelles la température extérieure est surpérieur à 15 ° c Cliquer sur la case de trie de la colonne temperature une barre glissante apparait avec des valeurs allant (d'après l'exemple ci-dessus) de 12 à 20,4°C. Déplacer le curseur de gauche sur 15 et les données sont réduites à la plage de température 15 à 20,4°C.

Une fois la phase de trie terminée, exporter vos résultats au format souhaité avec l'un des deux boutons "xx_Filtrés.

## Onglet Identification

l'onglet Identification se présente comme l'onglet tirage et possède les même fonctionnalités.

![Image](https://github.com/user-attachments/assets/c36d9d67-1cfd-44f8-82ff-911849e2def8)

Le data table présente toutes données qui ont été entrées dans Collec Science (l'outil de gestion des collections, collec science est alimenté par le formulaire [App_Identif_tiques_V.1.3.xlsx](https://github.com/yannickkk/ODK/blob/3ea07583a9f5e789567ecdbe847376c4ea4f65ef/PyrTick/App_Identif_tiques_V.1.3.xlsx) et les données du programme Pyrtick correspondant à ce formulaire sont affichées ici.

On peut donc à l'aide de ce formulaire trier toutes les tiques au stade nymphe de l'altitude précédente PT-vaz-5f et savoir dans quelles boites de collection elles sont rangés.







