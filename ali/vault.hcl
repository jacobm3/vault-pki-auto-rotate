listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/tls/vault-cert.crt"
  tls_key_file  = "/opt/vault/tls/vault-key.pem"
}

storage "file" {
  path = "/opt/vault/data"
}

ui = "true"
