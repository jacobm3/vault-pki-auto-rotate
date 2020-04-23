#!/bin/bash

CERT_FILE=/etc/pki/tls/certs/localhost.crt
KEY_FILE=/etc/pki/tls/private/localhost.key

VAULT_ADDR=https://vault.jacobm.azure.hashidemos.io:8200/
export VAULT_ADDR

# Vault token is taken from ~/.vault-token
# Could be expanded to grab token from cloud identity metadata service

echo
echo -n "NEW RUN: "
date

echo "Retrieving new certificate and private key from Vault"
json=$( /usr/local/bin/vault write -format=json \
          -namespace=geo-us/ops \
          pki/issue/apache-jacobm-azure-hashidemos-io \
          common_name=apache.jacobm.azure.hashidemos.io \
          format=pem)

echo "Writing new certificate to: $CERT_FILE"
echo $json | jq .data.certificate  | sed 's/\\n/\n/g' | sed 's/"//g'  > $CERT_FILE

echo "Writing new private key to: $KEY_FILE"
echo $json | jq .data.private_key  | sed 's/\\n/\n/g' | sed 's/"//g'  > $KEY_FILE

echo -n "Certificate serial number: "
echo $json | jq -C .data.serial_number

echo "Apache restart"
systemctl restart httpd

sleep 3

echo "Scrubbing private key from $KEY_FILE"
scrub -r $KEY_FILE
