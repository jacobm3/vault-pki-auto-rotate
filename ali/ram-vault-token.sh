#!/bin/bash

export VAULT_ADDR=https://vault.jacobm.ali.hashidemos.io:8200
export VAULT_NAMESPACE=ali-web

# Use RAM instance metadata to authenticate to Vault

json=`curl -s 'http://100.100.100.200/latest/meta-data/ram/security-credentials/web-instance-role'`

#echo $json | jq; echo;

AccessKeyId=`echo $json | jq -r .AccessKeyId`
AccessKeySecret=`echo $json | jq -r .AccessKeySecret`
SecurityToken=`echo $json | jq -r .SecurityToken`

region=`curl -s http://100.100.100.200/latest/meta-data/region-id`

vault login -method=alicloud \
  access_key=$AccessKeyId \
  secret_key=$AccessKeySecret \
  security_token=$SecurityToken \
  region=$region >/dev/null 2>&1

chown vault-agent:vault-agent ~/.vault-token
chmod 640 ~/.vault-token
