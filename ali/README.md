# Vault in Alibaba Cloud

This directory has essential commands to setup a demonstration of the Alicloud secrets engine in Vault. It consists of a Vault server and a Linux web server running in Alicloud. The web server authenticates to the Vault server with Vault Agent using an RAM ECS instance role and an STS token obtained through the local metadata service, obtaining a Vault token. 

The web server uses its Vault token to do the following:
- Rotate an internally trusted TLS certificate for Apache
- Generate a temporary access token based on RAM policies


It uses a RAM ECS machine role and the ECS metadata service on the web server to generate a short term STS token, allow

## Terminology

RAM = Resource Access Manager  
ECS = Elastic Compute Service  
OSS = Object Storage Service  

| AWS  | Azure  | Alicloud |
|---|---|---|
| IAM  | AAD  | RAM  |
| STS token | ? | STS token |
| EC2  | Virtual Machines  | ECS |
| S3  | Storage  |  OSS |  

## 
