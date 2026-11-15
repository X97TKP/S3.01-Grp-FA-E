#!/bin/bash

DB_CONTAINER="db_dev"
DB_USER="sae_user"
DB_NAME="dev_db"
DATA_DIR="imdb_datasets"

echo "========================================================="
echo "  Chargement des données IMDb dans PostgreSQL"
echo "========================================================="

# Tableau associant le fichier à sa table de destination
# L'ordre est strict pour respecter les clés étrangères (Foreign Keys)
FILES=(
    "name.basics.tsv.gz:name_basics"
    "title.basics.tsv.gz:title_basics"
    "title.akas.tsv.gz:title_akas"
    "title.crew.tsv.gz:title_crew"
    "title.episode.tsv.gz:title_episode"
    "title.principals.tsv.gz:title_principals"
    "title.ratings.tsv.gz:title_ratings"
)

START_GLOBAL=$SECONDS

for item in "${FILES[@]}"; do
    FILE="${item%%:*}"
    TABLE="${item##*:}"
    FILE_PATH="$DATA_DIR/$FILE"
    
    echo -n "→ Insertion dans $TABLE ... "
    START=$SECONDS
    
    # Décompression à la volée et injection directe
    zcat "$FILE_PATH" | sudo docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "COPY $TABLE FROM STDIN WITH (FORMAT csv, DELIMITER E'\t', HEADER true, QUOTE E'\b');" > /dev/null 2>&1
    
    DURATION=$(( SECONDS - START ))
    echo "OK (${DURATION}s)"
done

TOTAL_DURATION=$(( SECONDS - START_GLOBAL ))
echo "========================================================="
echo "Terminé ! Temps total d'insertion : ${TOTAL_DURATION} secondes."
echo "========================================================="