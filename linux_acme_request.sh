## STANDALONE
export CN="<CN>"
export LOC="/path/to/certificates"
mkdir -p "${LOC}"
acme.sh --issue \
  --nginx \
  -d "${CN}" \
  --fullchain-file "${LOC}/fullchain.pem" \
  --key-file "${LOC}/privkey.pem" \
  -k 2048


## MULTI-DOMAIN
export CN="<CN>"
export SAN1="<SAN1>"
export SAN2="<SAN2>"
export LOC="/path/to/certificates"
mkdir -p "${LOC}"
acme.sh --issue \
  --nginx \
  -d "${CN}" \
  -d "${SAN1}" \
  -d "${SAN2}" \
  --fullchain-file "${LOC}/fullchain.pem" \
  --key-file "${LOC}/privkey.pem" \
  -k 2048


## WITH POST-HOOK
export CN="<CN>"
export SAN1="<SAN1>"
export SAN2="<SAN2>"
export RESTART_CMD="<restart_cmd>"
export TLS_OUT="/home/tls/tls.pem"
acme.sh --issue \
  --nginx \
  -d "${CN}" \
  -d "${SAN1}" \
  -d "${SAN2}" \
  --post-hook "cat \"${HOME}/.acme.sh/${CN}/${CN}.cer\" \"${HOME}/.acme.sh/${CN}/${CN}.key\" > \"${TLS_OUT}\" && ${RESTART_CMD}" \
  -k 2048


