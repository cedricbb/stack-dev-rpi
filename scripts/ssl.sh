#!/bin/bash

# Supprimer les anciens certificats
rm -rf *.pem *.crt *.csr *.srl

# Créer le fichier de configuration pour OpenSSL
cat > domain.cnf << EOF
[req]
days                   = 365
serial                 = 1
distinguished_name     = req_distinguished_name
req_extensions         = v3_req
x509_extensions        = v3_ca

[req_distinguished_name]
countryName            = FR
stateOrProvinceName    = France
localityName           = Local
organizationName       = LocalDev
organizationalUnitName = Development
commonName             = localhost

[ v3_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical, CA:TRUE, pathlen:3
keyUsage              = critical, cRLSign, keyCertSign

[ v3_req ]
basicConstraints       = CA:FALSE
keyUsage              = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName        = @alt_names

[alt_names]
DNS.1  = localhost
DNS.2  = *.localhost
DNS.3  = traefik.localhost
DNS.4  = mailhog.localhost
DNS.5  = phpmyadmin.localhost
EOF

# Générer la clé privée du CA (Certificate Authority)
openssl genrsa -out ca.key.pem 2048
chmod 400 ca.key.pem

# Générer le certificat CA auto-signé
openssl req -new -x509 \
    -subj "/C=FR/ST=France/L=Local/O=LocalDev/OU=Development/CN=localhost" \
    -extensions v3_ca \
    -days 365 \
    -key ca.key.pem \
    -sha256 \
    -out ca.pem \
    -config domain.cnf

# Générer la clé privée du domaine
openssl genrsa -out domain.key.pem 2048

# Générer la demande de signature de certificat (CSR)
openssl req \
    -subj "/C=FR/ST=France/L=Local/O=LocalDev/OU=Development/CN=localhost" \
    -extensions v3_req \
    -sha256 \
    -new \
    -key domain.key.pem \
    -out domain.csr

# Signer le certificat avec notre CA
openssl x509 -req \
    -extensions v3_req \
    -days 365 \
    -sha256 \
    -in domain.csr \
    -CA ca.pem \
    -CAkey ca.key.pem \
    -CAcreateserial \
    -out domain.crt \
    -extfile domain.cnf

# Déplacer les fichiers dans le dossier traefik
mkdir -p traefik
mv domain.crt traefik/
mv domain.key.pem traefik/
mv ca.pem traefik/

echo "Certificats générés avec succès dans le dossier traefik/"
echo "Fichiers générés:"
echo "- traefik/domain.crt (certificat)"
echo "- traefik/domain.key.pem (clé privée)"
echo "- traefik/ca.pem (certificat racine)"
EOF