#!/bin/sh
echo "[✔] Lancement du OCSP responder..."

# Vérification que les fichiers existent bien
if [ ! -f /root/ca/certs/ca.crt ] || [ ! -f /root/ca/private/ca.key ]; then
  echo "❌ Fichiers CA manquants : /root/ca/certs/ca.crt ou /root/ca/private/ca.key"
  sleep infinity
  exit 1
fi

openssl ocsp -port 2560 -text \
  -index /root/ca/index.txt \
  -CA /root/ca/certs/ca.crt \
  -rkey /root/ca/private/ca.key \
  -rsigner /root/ca/certs/ca.crt || sleep infinity