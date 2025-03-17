#!/bin/bash

CERT_NAME="$1"
CA_DIR="$HOME/ca"
CERT_PATH="$CA_DIR/servers/$CERT_NAME/$CERT_NAME.crt"
OPENSSL_CONF="$CA_DIR/openssl.cnf"
CRL_PATH="$CA_DIR/crl/ca.crl"
DOCKER_CONTAINER_NAME="ocsp"

# Vérifications
if [ -z "$CERT_NAME" ]; then
  echo "❌ Usage: $0 <cert_name>"
  exit 1
fi

if [ ! -f "$CERT_PATH" ]; then
  echo "❌ Certificat $CERT_PATH introuvable."
  exit 1
fi

echo "🔐 Révocation du certificat : $CERT_NAME"
openssl ca -config "$OPENSSL_CONF" -revoke "$CERT_PATH"

echo "🔄 Génération de la nouvelle CRL"
openssl ca -config "$OPENSSL_CONF" -gencrl -out "$CRL_PATH"

echo "♻️ Redémarrage du container OCSP : $DOCKER_CONTAINER_NAME"
docker restart "$DOCKER_CONTAINER_NAME"

echo "✅ Terminé : certificat révoqué, CRL mise à jour, OCSP rechargé."

echo "$(date): Revoked $CERT_NAME and reloaded OCSP" >> "$CA_DIR/revoke.log"