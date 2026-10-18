# Livrable 3 : Architecture et Configuration du Serveur

## Configuration initiale (Mi-Octobre 2026)

- **Machine hôte :** Serveur physique Dell OptiPlex 7050 sous Debian GNU/Linux.
- **Réseau & Reverse Proxy :**
  - Nginx Proxy Manager (image Docker `jc21/nginx-proxy-manager:latest`).
  - Redirection HTTPS forcée avec génération de certificats SSL Let's Encrypt.
  - Sous-domaines configurés : `devs301.tbd-tkp.fr` (Développement) et `apps301.tbd-tkp.fr` (Production).
- **Serveurs Web (Conteneurs Docker isolés) :**
  - Image Docker utilisée : `php:8.2-apache`.
  - Apache 2 en configuration standard avec module PHP intégré.
  - Conteneur `sae301_dev` : sur le port interne 80 (localement sur 8081).
  - Conteneur `sae301_prod` : sur le port interne 80 (localement sur 8082).
- **Interface Client :**
  - JavaScript.

## Paramétrage et Sécurisation (Ajouts du 16 octobre)

- **Sécurisation de l'accès distant (SSH) :**
  - Redirection du port externe 2222 vers le port interne 22 (NAT/PAT) pour limiter les scans automatisés.
  - Désactivation totale de l'authentification par mot de passe (`PasswordAuthentication no` dans `sshd_config`).
  - Authentification exclusive par clés (formats ED25519).
- **Gestion des droits et cloisonnement :**
  - Création de comptes utilisateurs Linux nominatifs isolés pour chaque membre de l'équipe (Tom, Thomas, Lissam et theo-dev, Théo étant déjà l'administrateur principal).
  - Création du groupe `sae-dev` regroupant l'ensemble des utilisateurs développeurs.
  - Application d'un `chmod 775` et du bit SetGID (`chmod g+s`) sur le répertoire source de développement. Ainsi, tout nouveau fichier hérite automatiquement des droits d'écriture pour l'ensemble du groupe.
  - Mise en place de liens symboliques dans les répertoires `/home/` des utilisateurs pour un accès direct au dossier de développement dès la connexion SSH.
  - **Configuration ciblée des privilèges sudo :** Modification du fichier `sudoers` pour accorder au groupe `sae-dev` l'exécution de commandes Docker précises, sans mot de passe :
    - Redémarrage et lecture des logs du conteneur web `sae301_dev`.
    - Accès sécurisé au terminal `psql` du conteneur `db_dev` (en tant qu'admin `sae_user`) pour l'injection de scripts SQL de création de base.

## Architecture des données (Ajouts du 18 octobre)

- **Serveurs de Base de Données (PostgreSQL) :**
  - Déploiement de deux conteneurs de bases de données distincts (image `postgres:16`) pour garantir la séparation des environnements.
  - Conteneur `db_dev` : dédié exclusivement à l'environnement de développement (tests, modifications de schémas).
  - Conteneur `db_prod` : dédié exclusivement à la production.
- **Réseau et Sécurité :**
  - Utilisation du réseau interne Docker unifié (`mon_reseau`) pour la communication entre les serveurs Apache/PHP, le Reverse Proxy et les bases de données.
  - Sécurité : Le port 5432 (PostgreSQL) n'est exposé sur aucune interface extérieure, empêchant tout accès direct depuis internet.
- **Gestion des privilèges (Principe de moindre privilège) :**
  - Création d'un utilisateur PostgreSQL restreint (`sae_reader`) utilisé exclusivement par l'application web.
  - Restriction stricte des droits accordés à la simple consultation (`GRANT SELECT`).
  - Blocage de toute tentative d'altération ou de destruction des données (`INSERT`, `UPDATE`, `DELETE`, `DROP`) depuis l'interface web, limitant l'impact de failles de sécurité (injections SQL).
