#!/bin/bash

# === CONFIGURATION ===
CA_DIR="$HOME/ca"
CERT_NAME="$1"
DOCKER_IMAGE="my-ocsp"
CONTAINER_NAME="ocsp-check"
REQ_DIR="$HOME/ocsp-docker"

CERT_PATH="$CA_DIR/servers/$CERT_NAME/$CERT_NAME.crt"
ISSUER_PATH="$CA_DIR/certs/ca.crt"
REQ_FILE="$REQ_DIR/req_${CERT_NAME}.ocsp"
RESP_FILE="$REQ_DIR/resp_${CERT_NAME}.ocsp"

# === Vérifications ===
if [ -z "$CERT_NAME" ]; then
  echo "❌ Usage: $0 <cert_name>"
  exit 1
fi

if [ ! -f "$CERT_PATH" ]; then
  echo "❌ Certificat $CERT_PATH introuvable."
  exit 1
fi

# === 1. Génération de la requête OCSP ===
echo "🔧 Génération de la requête OCSP pour '$CERT_NAME'..."
openssl ocsp -issuer "$ISSUER_PATH" -cert "$CERT_PATH" -reqout "$REQ_FILE"
if [ $? -ne 0 ]; then
  echo "❌ Erreur lors de la génération de la requête OCSP"
  exit 1
fi

# === 2. Génération de la réponse OCSP via le conteneur ===
echo "📦 Lancement du responder pour générer la réponse..."
docker run --rm \
  --name "$CONTAINER_NAME" \
  --entrypoint sh \
  -v "$CA_DIR":/root/ca \
  -v "$REQ_DIR":/req \
  "$DOCKER_IMAGE" -c "\
openssl ocsp -index /root/ca/index.txt \
  -CA /root/ca/certs/ca.crt \
  -rkey /root/ca/private/ca.key \
  -rsigner /root/ca/certs/ca.crt \
  -reqin /req/req_${CERT_NAME}.ocsp \
  -respout /req/resp_${CERT_NAME}.ocsp \
  && echo ✅ Réponse OCSP générée"

# === 3. Lecture de la réponse ===
echo "🔍 Lecture du statut OCSP..."
openssl ocsp -respin "$RESP_FILE" -text -VAfile "$ISSUER_PATH"