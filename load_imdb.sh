#!/bin/bash
echo "======================================================"
echo " Chargement des données IMDb dans PostgreSQL"
echo "======================================================"

# Fonction pour charger un fichier avec la bonne syntaxe COPY
charger_table() {
    FICHIER=$1
    TABLE=$2
    echo "-> Insertion dans $TABLE depuis $FICHIER..."
    time zcat "imdb_datasets/$FICHIER" | sudo docker exec -i db_dev psql -U sae_user -d dev_db -c "COPY $TABLE FROM STDIN WITH (FORMAT csv, DELIMITER E'\t', HEADER true, QUOTE E'\b', NULL '\N');"
    echo "------------------------------------------------------"
}

# Ordre strict pour respecter les clés étrangères
charger_table "title.basics.tsv.gz" "title_basics"
charger_table "name.basics.tsv.gz" "name_basics"
charger_table "title.akas.tsv.gz" "title_akas"
charger_table "title.crew.tsv.gz" "title_crew"
charger_table "title.episode.tsv.gz" "title_episode"
charger_table "title.principals.tsv.gz" "title_principals"
charger_table "title.ratings.tsv.gz" "title_ratings"

echo "Chargement terminé avec succès !"