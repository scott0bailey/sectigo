## Install ACME.sh
## Getting started with acme.sh client:
##   https://github.com/acmesh-official/acme.sh
## Recommended: run under sudo -i OR as a dedicated acme user.

## Environment variables for EAB and Sectigo ACME endpoint
export EAB_KID="<eab_kid>"
export EAB_HMAC_KEY="<eab_hmac_key>"
export SECTIGO_ACME="<sectigo_acme_directory_url>"
## Register ACME Account with EAB
acme.sh --register-account \
  --server "${SECTIGO_ACME}" \
  --eab-kid "${EAB_KID}" \
  --eab-hmac-key "${EAB_HMAC_KEY}" \
  --force
## Set Sectigo as the default CA
acme.sh --set-default-ca --server "${SECTIGO_ACME}"
