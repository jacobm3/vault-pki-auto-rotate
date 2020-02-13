# Easy single node Vault config with local file storage. Not for production.

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/vault/ssl/vault-cert.crt"
  tls_key_file  = "/vault/ssl/vault-key.pem"
}

storage "file" {
  path = "/vault/data"
}

ui = "true"
api_addr = "https://vault.jacobm.azure.hashidemos.io:8200/"
plugin_directory = "/etc/vault.d/plugins"
