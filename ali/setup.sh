# With a Vault root token
ns=ali-web
vault namespace create $ns

export VAULT_NAMESPACE=$ns
vault auth enable alicloud

# Create a RAM role
# RAM -> RAM Roles -> Create RAM Role -> Ali svc -> ECS
# Create one a RAM ECS instance role granting Vault permission to create tokens (Ali secrets engine)
# Create another RAM ECS instance role for the client so it can authenticate to Vault using
# its local instance metadata

# client metadata role
vault write auth/alicloud/role/web-instance-role \
  token_policies="space-admin" \
  arn='acs:ram::5657185762276978:role/web-instance-role'


# On the web server get STS token from instance metadata service:
curl 'http://100.100.100.200/latest/meta-data/ram/security-credentials/web-instance-role'
 {
  "AccessKeyId" : "STS.NUvuKYpeAcTxxxxxxxdGxHnz",
  "AccessKeySecret" : "ACGQ7u1syAHjxxxxxxxxxxxxxxxxxxxxxxxxxxxKrKQvoJA",
  "Expiration" : "2020-04-23T09:22:05Z",
  "SecurityToken" : "CAISjQJ1q6Ft5B2yfSjIrxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxgEzBMopYhLomADd/iRfbxJ92PCTmd5AIRrJL+cTK9JS/HVbSClZ9gaPkOQwC8dkAoLdxKJwxk2qR4XDmrQpTLCBPxhXfKB0dFoxd1jXgFiZ6y2cqB8BHT/jaYo60339mvf8f9P5QzYs0lDInkg7xMG/CfgH4A2X9j77xriaFIwzDDs+yGDkNZixf8avMD6VHJ6dOFjgUY1fiIFSC+YVNN2AzD7RVWJYz7Cuy9Ij/PPY7tJARuTvaJm5Cw9fuifLxEtPfJvzxRvtDc8OopNuqCBGVXikYRup9yI1iyZbct1fxDZIZZRSMTG3nezzvXOCxLtzmLnPkV07UHZoLXmpsqppP1KW",
  "LastUpdated" : "2020-04-23T03:22:05Z",
  "Code" : "Success"
}

Use STS token to get Vault token:
vault login -method=alicloud \
  access_key=STS.xxxxxxxxxxxxxxxxxxxxxx \
  secret_key=ACGQ7u1xxxxxxxxxxxxxxxxxxxxxxxppjKrKQvoJA \
  security_token=CAISjQJ1q6Ft5B2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx+aWloLs1x9LNuwQSSPbSZASCB4JqFYcXBqAAX5zAzRXqIhvMD6VHJ6dOFjgUY1fiIFSC+YVNN2AzD7RVWJYz7Cuy9Ij/PPY7tJARuTvaJm5Cw9fuifLxEtPfJvzxRvtDc8OopNuqCBGVXikYRup9yI1iyZbct1fxDZIZZRSMTG3nezzvXOCxLtzmLnPkV07UHZoLXmpsqppP1KW \
  region=cn-qingdao

That will generate a Vault token scoped to the matching Vault role:

Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                         Value
---                         -----
token                       s.fuxxxxxxxxxxxxxxxxxxxxxKQ.tv22s
token_accessor              6MVMtggguuEac3JMovfvMs3Z.tv22s
token_duration              768h
token_renewable             true
token_policies              ["default"]
identity_policies           []
policies                    ["default"]
token_meta_arn              acs:ram::5657185762276978:assumed-role/web-instance-role/vm-ram-i-m5e8z2q1jg4gnsdfkomb
token_meta_identity_type    AssumedRoleUser
token_meta_principal_id     345377512072480607:vm-ram-i-m5e8z2q1jg4gnsdfkomb
token_meta_request_id       A3D1B64A-F30D-41F8-A03E-5448CA35B160
token_meta_role_id          345377512072480607
token_meta_role_name        web-instance-role
token_meta_user_id          n/a
token_meta_account_id       5657185762276978

Use the Vault token to access secrets engines per Vault policies you received.


With Vault root token, create a policy in the ali-web namespace for the web server to be assigned with it authenticates.

vault policy write -namespace=ali-web space-admin - <<EOF
path "*" {
capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF



Cron entry for DIY token agent:
*/5 * * * * ~/bin/ram-vault-token.sh >> ~/.ram-vault-token.sh.log 2>&1

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



# Vault root token cmds
export VAULT_ADDR=https://vault.jacobm.ali.hashidemos.io:8200
export VAULT_NAMESPACE=ali-web
export VAULT_CN=vault.jacobm.ali.hashidemos.io
export WEB_CN=web.jacobm.ali.hashidemos.io

vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
vault write pki/root/generate/internal common_name=$VAULT_CN ttl=87600h
vault write pki/config/urls \
    issuing_certificates="${VAULT_ADDR}/v1/pki/ca" \
    crl_distribution_points="${VAULT_ADDR}/v1/pki/crl"
vault write pki/roles/$WEB_CN \
    allowed_domains=$WEB_CN \
    allow_bare_domains=true \
    allow_subdomains=true max_ttl=72h
    

# Run from web server to obtain new certificate and key:
export VAULT_ADDR=https://vault.jacobm.ali.hashidemos.io:8200
export VAULT_NAMESPACE=ali-web
export WEB_CN=web.jacobm.ali.hashidemos.io
export VAULT_TOKEN=`cat ~vault-agent/.vault-token`
vault write pki/issue/$WEB_CN common_name=$WEB_CN



