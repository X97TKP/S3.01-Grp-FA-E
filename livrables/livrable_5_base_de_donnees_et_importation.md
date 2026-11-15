# Livrable 5 : Analyse, Schémas et Automatisation des données IMDb

**Date de rendu :** 15 novembre 2026
**Équipe :** Thomas Chandellier (manager), Tom Peyredieu, Théo Bordes-Da Silva, Lissam Loufti

## 1. Analyse de la base de données fournie

Les données brutes d'IMDb sont réparties dans 7 fichiers compressés (`.tsv.gz`). Chaque fichier contient des millions de lignes nécessitant une structuration rigoureuse dans un SGBDR pour garantir les performances et l'intégrité référentielle.

**Choix techniques :**

- **SGBD :** PostgreSQL 16 (Conteneur Docker `db_dev`).

- **Types de données :** Utilisation intensive du type `TEXT` pour les titres et les noms afin de prévenir les erreurs de dépassement (`VARCHAR` trop courts).

- **Tableaux (Arrays) :** Les listes fournies par IMDb (comme `genres`, `directors`, `primaryProfession`) sont stockées sous forme de `TEXT` brut délimité par des virgules pour optimiser la vitesse d'importation, et seront traitées de manière applicative (PHP) ou par des vues SQL ultérieures.

## 2. Diagramme UML de la base de données

Voici la modélisation de notre base de données. Les relations respectent strictement les dépendances identifiées dans les fichiers sources.
![Diagramme UML de la base de données](./image_pour_md/uml.png)

## 3. Scripts d'automatisation (Téléchargement et Chargement)

Afin de maintenir la base de données à jour de manière automatisée, nous avons développé deux scripts distincts (disponibles à la racine de notre dépôt Git) :

1. **`download_imdb.py`** : Script Python qui interroge les serveurs `datasets.imdbws.com`, télécharge les 7 archives `.tsv.gz` de manière sécurisée (gestion des erreurs HTTP) et calcule la taille et le temps de téléchargement de chaque fichier.

2. **`load_imdb.sh`** : Script Bash s'exécutant directement sur le serveur Debian. Il décompresse les données à la volée (`zcat`) et les injecte dans le conteneur PostgreSQL via la commande native `COPY`. L'ordre d'insertion est strictement défini pour respecter les contraintes de clés étrangères (ex: `title_basics` avant `title_akas`).

_(Le script de création des tables est disponible dans le fichier `schema_imdb.sql`)_.

## 4. Indicateurs de performance

Lors de notre exécution sur le serveur (Debian / PostgreSQL 16) le 15 novembre 2026, les performances relevées par nos scripts ont été les suivantes :

### A. Phase de récupération (Téléchargement HTTP)

- `name.basics` (298.5 Mo) : 18.9 sec

- `title.akas` (499.0 Mo) : 31.9 sec

- `title.basics` (219.7 Mo) : 14.3 sec

- `title.crew` (80.2 Mo) : 5.4 sec

- `title.episode` (52.9 Mo) : 3.4 sec

- `title.principals` (754.2 Mo) : 48.3 sec

- `title.ratings` (8.3 Mo) : 0.7 sec

- **Temps total de téléchargement : 122.90 secondes.**

### B. Phase de chargement (Insertion PostgreSQL - COPY)

- Insertion dans `name_basics` : _\[Temps à relever dans le tmux\]_

- Insertion dans `title_basics` : _\[Temps à relever dans le tmux\]_

- Insertion dans `title_akas` : _\[Temps à relever dans le tmux\]_

- Insertion dans `title_crew` : _\[Temps à relever dans le tmux\]_

- Insertion dans `title_episode` : _\[Temps à relever dans le tmux\]_

- Insertion dans `title_principals` : _\[Temps à relever dans le tmux\]_

- Insertion dans `title_ratings` : _\[Temps à relever dans le tmux\]_

- **Temps total d'insertion en BDD : _\[Temps final à relever\]_ secondes.**
