## Install ACME.sh
## Getting started with acme.sh client
##  https://github.com/acmesh-official/acme.sh
## Recommend always using "sudo -i" to run all acme.sh commands

## Register ACME Account:
export EAB_KID=<eab>
export EAB_HMAC_KEY=<hmac>
export SECTIGO_ACME=<sectigo_acme_url>
acme.sh --register-account --insecure --force --eab-kid $EAB_KID --eab-hmac-key $EAB_HMAC_KEY --server $SECTIGO_ACME && acme.sh --set-default-ca --server $SECTIGO_ACME
