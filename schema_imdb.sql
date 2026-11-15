-- Suppression des tables si elles existent déjà (pour pouvoir relancer le script proprement)
DROP TABLE IF EXISTS title_ratings CASCADE;
DROP TABLE IF EXISTS title_principals CASCADE;
DROP TABLE IF EXISTS title_episode CASCADE;
DROP TABLE IF EXISTS title_crew CASCADE;
DROP TABLE IF EXISTS title_akas CASCADE;
DROP TABLE IF EXISTS title_basics CASCADE;
DROP TABLE IF EXISTS name_basics CASCADE;

-- 1. Table name.basics (Personnes)
CREATE TABLE name_basics (
    nconst VARCHAR(15) PRIMARY KEY,       -- Identifiant unique (ex: nm0000001)
    primaryName TEXT,                     -- Nom principal
    birthYear INTEGER,                    -- Année de naissance
    deathYear INTEGER,                    -- Année de décès (NULL si vivant)
    primaryProfession TEXT,               -- Top 3 des professions (séparées par des virgules)
    knownForTitles TEXT                   -- Titres connus (séparés par des virgules)
);

-- 2. Table title.basics (Films, Séries, etc.)
CREATE TABLE title_basics (
    tconst VARCHAR(15) PRIMARY KEY,       -- Identifiant unique (ex: tt0000001)
    titleType VARCHAR(50),                -- Type (movie, tvseries...)
    primaryTitle TEXT,                    -- Titre principal
    originalTitle TEXT,                   -- Titre original
    isAdult BOOLEAN,                      -- Titre pour adultes (0/1 converti en FALSE/TRUE)
    startYear INTEGER,                    -- Année de sortie / début
    endYear INTEGER,                      -- Année de fin (pour les séries)
    runtimeMinutes INTEGER,               -- Durée en minutes
    genres TEXT                           -- Genres (séparés par des virgules)
);

-- 3. Table title.akas (Titres alternatifs et traductions)
CREATE TABLE title_akas (
    titleId VARCHAR(15) REFERENCES title_basics(tconst),
    ordering INTEGER,
    title TEXT,
    region VARCHAR(10),
    language VARCHAR(10),
    types TEXT,
    attributes TEXT,
    isOriginalTitle BOOLEAN,
    PRIMARY KEY (titleId, ordering)
);

-- 4. Table title.crew (Réalisateurs et Scénaristes)
CREATE TABLE title_crew (
    tconst VARCHAR(15) PRIMARY KEY REFERENCES title_basics(tconst),
    directors TEXT,                       -- nconsts séparés par des virgules
    writers TEXT                          -- nconsts séparés par des virgules
);

-- 5. Table title.episode (Épisodes de séries)
CREATE TABLE title_episode (
    tconst VARCHAR(15) PRIMARY KEY REFERENCES title_basics(tconst),
    parentTconst VARCHAR(15) REFERENCES title_basics(tconst),
    seasonNumber INTEGER,
    episodeNumber INTEGER
);

-- 6. Table title.principals (Casting et équipe technique)
CREATE TABLE title_principals (
    tconst VARCHAR(15) REFERENCES title_basics(tconst),
    ordering INTEGER,
    nconst VARCHAR(15) REFERENCES name_basics(nconst),
    category VARCHAR(50),
    job TEXT,
    characters TEXT,
    PRIMARY KEY (tconst, ordering)
);

-- 7. Table title.ratings (Notes et votes)
CREATE TABLE title_ratings (
    tconst VARCHAR(15) PRIMARY KEY REFERENCES title_basics(tconst),
    averageRating NUMERIC(3,1),           -- Note moyenne (ex: 8.5)
    numVotes INTEGER                      -- Nombre de votes
);