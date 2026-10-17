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

## Paramétrage et Sécurisation (Ajouts de 16 octobre )

- **Sécurisation de l'accès distant (SSH) :**
  - Redirection du port externe 2222 vers le port interne 22 (NAT/PAT) pour limiter les scans automatisés.
  - Désactivation totale de l'authentification par mot de passe (`PasswordAuthentication no` dans `sshd_config`).
  - Authentification exclusive par clés (formats ED25519).
- **Gestion des droits et cloisonnement :**
  - Création de comptes utilisateurs Linux nominatifs isolés pour chaque membre de l'équipe (Tom, Thomas, Lissam et theo-dev(theo etant deja l'administrateur )).
  - Création du groupe `sae-dev` regroupant l'ensemble des utilisateurs développeurs.
  - Application d'un `chmod 775` et du bit SetGID (`chmod g+s`) sur le répertoire source de développement. Ainsi, tout nouveau fichier hérite automatiquement des droits d'écriture pour l'ensemble du groupe.
  - Mise en place de liens symboliques dans les répertoires `/home/` des utilisateurs pour un accès direct au dossier de développement dès la connexion SSH.
