#!/bin/bash

CERT_FILE=/etc/ssl/certs/web.crt
KEY_FILE=/etc/ssl/private/web.key

export WEB_CN=web.jacobm.ali.hashidemos.io

export VAULT_NAMESPACE=ali-web
export VAULT_ADDR=https://vault.jacobm.ali.hashidemos.io:8200

export VAULT_TOKEN=`cat ~vault-agent/.vault-token`

echo
echo -n "NEW RUN: "
date

echo "Retrieving new certificate and private key from Vault"
json=$( /usr/local/bin/vault write -format=json \
          pki/issue/$WEB_CN \
          common_name=$WEB_CN \
          format=pem)

echo "Writing new certificate to: $CERT_FILE"
echo $json | jq .data.certificate  | sed 's/\\n/\n/g' | sed 's/"//g'  > $CERT_FILE

echo "Writing new private key to: $KEY_FILE"
echo $json | jq .data.private_key  | sed 's/\\n/\n/g' | sed 's/"//g'  > $KEY_FILE

echo -n "Certificate serial number: "
echo $json | jq -C .data.serial_number

echo "Apache restart"
systemctl restart apache2

sleep 3

echo "Scrubbing private key from $KEY_FILE"
scrub -r $KEY_FILE
