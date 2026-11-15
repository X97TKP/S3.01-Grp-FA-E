#!/usr/bin/env python3
"""
Télécharge toutes les archives IMDb disponibles sur https://datasets.imdbws.com/
"""

import os
import sys
import time
from pathlib import Path
from urllib.request import urlretrieve
from urllib.error import URLError, HTTPError

# Liste des fichiers disponibles (Correction : ajout du '#')
FILES = [
    "name.basics.tsv.gz",
    "title.akas.tsv.gz",
    "title.basics.tsv.gz",
    "title.crew.tsv.gz",
    "title.episode.tsv.gz",
    "title.principals.tsv.gz",
    "title.ratings.tsv.gz",
]

BASE_URL = "https://datasets.imdbws.com/"
DOWNLOAD_DIR = Path("imdb_datasets")  # Dossier de destination

def download_file(filename: str, dest_dir: Path) -> bool:
    url = BASE_URL + filename
    dest_path = dest_dir / filename

    print(f"→ Téléchargement de {filename} ...", end=" ", flush=True)
    
    start_time = time.perf_counter()
    try:
        urlretrieve(url, dest_path)
        end_time = time.perf_counter()
        
        size_mb = dest_path.stat().st_size / (1024 * 1024)
        duration = end_time - start_time
        print(f"OK ({size_mb:.1f} Mo en {duration:.1f} sec)")
        return True
    except (URLError, HTTPError) as e:
        print(f"ÉCHEC : {e}")
        return False
    except Exception as e:
        print(f"Erreur inattendue : {e}")
        return False

def main():
    print("=" * 60)
    print("  Téléchargeur des datasets IMDb avec indicateurs de perf")
    print("=" * 60)
    print(f"Destination : {DOWNLOAD_DIR.resolve()}\n")

    # Création du dossier de destination
    DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)

    global_start = time.perf_counter()
    success = 0
    for filename in FILES:
        if download_file(filename, DOWNLOAD_DIR):
            success += 1
    global_end = time.perf_counter()

    print("\n" + "=" * 60)
    print(f"Terminé : {success}/{len(FILES)} fichiers téléchargés avec succès.")
    print(f"Temps total de récupération : {global_end - global_start:.2f} secondes.")
    print(f"Fichiers disponibles dans : {DOWNLOAD_DIR.resolve()}")
    print("=" * 60)

    if success < len(FILES):
        sys.exit(1)

# Correction : vrais underscores pour __name__ et __main__
if __name__ == "__main__":
    main()