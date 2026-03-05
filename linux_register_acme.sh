## Register ACME Account:
export EAB_KID=<eab_kid>
export EAB_HMAC_KEY=<hmac_key>
acme.sh --register-account --insecure --force --eab-kid $EAB_KID --eab-hmac-key $EAB_HMAC_KEY --server https://acme.enterprise.sectigo.com && acme.sh --set-default-ca --server  https://acme.enterprise.sectigo.com
