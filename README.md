# vault-pki-auto-rotate

Quick demo showing what can be easily done to rotate TLS certificates with Vault. This example rotates certs for a stock RHEL+Apache web server.

I'm running it from cron to pull a new cert and private key every minute in demos, then securely delete the key from the filesystem, so the private key only exists in Apache's memory space and completely disappears on the next rotation.

## Machine Identity Auth

![alt text](https://www.vaultproject.io/img/vault-secure-intro-2.png "Machine Auth")

Alicloud and Azure examples of machine auth in the 'ali' and 'azure' directories.


## Monitoring and Onboarding Workflow
For enterprise scalability you could wrap the Vault commands in a PKI admin script and/or a self-service developer portal where people can provision new projects. I assume any system important enough to need a valid certificate would also be included in your monitoring environment. Any modern monitoring system can check cert expiration. Example:
https://exchange.nagios.org/directory/Plugins/Network-Protocols/HTTP/check_ssl_cert/details 

When a new machine is onboarded, the admin script (or portal) does the following:
- creates a Vault role allowing the machine's identity to pull a cert with the appropriate CN/SAN
- adds the machine to your existing monitoring system 
- sets the monitoring notification target to be the requestor's team email distribution list (so the right people are notified even if the original requestor moves to another team)

## Example Timing and Scheduling
You could create 30 day certs, rotate them every night, and configure the monitoring check to notify when a cert expires in less than 28 days. That would detect rotation problems right away and give the team owning that machine 4 weeks to correct the problem.
