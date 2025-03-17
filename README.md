
# 🔐 OCSP Responder — Projet IoT2 | MASI 2024-2025

Ce projet met en place une **infrastructure de certification interne (PKI)** avec support de **révocation OCSP (Online Certificate Status Protocol)** dans le cadre du projet de livraison **MASMZI / IoT2**.

## 📌 Objectif

Permettre la **vérification en temps réel du statut des certificats internes** (API, bases de données, microservices) via un **responder OCSP local**, automatisé, et exposé pour les services du projet.

---

## 📦 Technologies utilisées

| Composant | Rôle |
|----------|------|
| OpenSSL  | Génération des certificats, gestion du CA, OCSP |
| Docker   | Conteneurisation du responder OCSP |
| Bash     | Scripts d'automatisation |
| Nginx *(optionnel)* | Reverse proxy HTTP pour exposer le responder |

---

## 📂 Structure du projet

```
.
├── ca/
│   ├── certs/           → Certificats de la CA
│   ├── private/         → Clé privée CA
│   ├── crl/             → Liste de révocation (CRL)
│   ├── index.txt        → Base de données des certificats
│   ├── servers/         → Certificats internes (test-server, webmasmzi, etc.)
│   ├── revoke_and_reload.sh → Script de révocation
│   └── openssl.cnf      → Fichier de configuration CA
│
├── ocsp-docker/
│   ├── Dockerfile              → Image OCSP Responder
│   ├── docker-entrypoint.sh   → Lance le responder OCSP
│   ├── build_and_run.sh       → Build & start rapide
│   ├── ocsp_check.sh          → Script pour vérifier le statut d'un certificat
│   └── README.md              → Ce fichier
```

---

## 🛠 Scripts disponibles

### ▶ `ca/revoke_and_reload.sh <cert_name>`
> Révoque un certificat et régénère la CRL.
```bash
./revoke_and_reload.sh test-server
```

### ▶ `ocsp-docker/build_and_run.sh`
> Build l’image et démarre le responder OCSP.
```bash
./build_and_run.sh
```

### ▶ `ocsp-docker/ocsp_check.sh <cert_name>`
> Vérifie le statut d’un certificat via OCSP.
```bash
./ocsp_check.sh test-server
```

---

## 🧪 Exemple de test complet

1. Générer un certificat :
```bash
cd ~/ca/servers/
mkdir fake-api && cd fake-api
openssl genrsa -out fake-api.key 2048
openssl req -new -key fake-api.key -out fake-api.csr \
  -subj "/C=BE/ST=Liege/L=Liege/O=ProjetIoT2/OU=INTERNAL/CN=fake-api.iot.local"
openssl ca -config ~/ca/openssl.cnf -in fake-api.csr -out fake-api.crt -batch
```

2. Vérifier son statut :
```bash
cd ~/ocsp-docker
./ocsp_check.sh fake-api
```

3. Révoquer :
```bash
cd ~/ca
./revoke_and_reload.sh fake-api
```

4. Re-tester :
```bash
./ocsp_check.sh fake-api
```

---

## 🌐 Mise à disposition réseau (OCSP as a Service)

> Voir section suivante "Exposition via NGINX"

---

## ✍️ Auteur

- Hugo, Projet IoT2 | MASMZI 2024-2025
