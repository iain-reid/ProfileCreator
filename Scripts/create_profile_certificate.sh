#!/bin/bash

# Create Certificates directory if it doesn't exist
mkdir -p Certificates

# Generate private key
openssl genrsa -out Certificates/private.key 2048

# Create a configuration file for the certificate
cat > Certificates/cert.conf << EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = US
ST = California
L = Cupertino
O = Your Organization
OU = Mobile Device Management
CN = ProfileCreator

[v3_req]
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth, codeSigning, emailProtection, 1.2.840.113549.1.9.16.3.9
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
subjectAltName = email:profilecreator@example.com
EOF

# Generate Certificate Signing Request (CSR)
openssl req -new -key Certificates/private.key -out Certificates/certificate.csr -config Certificates/cert.conf

# Generate self-signed certificate with the proper extensions
openssl x509 -req -days 365 -in Certificates/certificate.csr -signkey Certificates/private.key -out Certificates/certificate.crt -extfile Certificates/cert.conf -extensions v3_req

# Create PKCS#12 (.p12) file with AES-256 encryption
openssl pkcs12 -export -out Certificates/profile_creator.p12 -inkey Certificates/private.key -in Certificates/certificate.crt -password pass:development -aes256

# Clean up intermediate files
rm Certificates/private.key Certificates/certificate.csr Certificates/certificate.crt Certificates/cert.conf

echo "Certificate created successfully at Certificates/profile_creator.p12"
echo "Password: development" 