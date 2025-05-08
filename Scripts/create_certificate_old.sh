#!/bin/bash

# Create Certificates directory if it doesn't exist
mkdir -p Certificates

# Generate private key
openssl genrsa -out Certificates/private.key 2048

# Generate Certificate Signing Request (CSR)
openssl req -new -key Certificates/private.key -out Certificates/certificate.csr -subj "/CN=ProfileCreator/O=Your Organization/C=US"

# Generate self-signed certificate
openssl x509 -req -days 365 -in Certificates/certificate.csr -signkey Certificates/private.key -out Certificates/certificate.crt

# Create PKCS#12 (.p12) file
openssl pkcs12 -export -out Certificates/profile_creator.p12 -inkey Certificates/private.key -in Certificates/certificate.crt -password pass:development

# Clean up intermediate files
rm Certificates/private.key Certificates/certificate.csr Certificates/certificate.crt

echo "Certificate created successfully at Certificates/profile_creator.p12"
echo "Password: development" 