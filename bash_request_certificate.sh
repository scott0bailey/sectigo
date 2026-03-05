#!/usr/bin/env bash
set -euo pipefail

#############################################
#  CONFIGURATION - EDIT THESE VARIABLES
#############################################
CLIENT_ID='<client_id>'
CLIENT_SECRET='<client_secret>'

CUSTOMER_NAME='<uri>'   # e.g., 'sectigose-na'

TOKEN_URL='https://auth.sso.sectigo.com/auth/realms/apiclients/protocol/openid-connect/token'
ENROLL_URL="https://${CUSTOMER_NAME}.enroll.enterprise.sectigo.com/api/v1/certificates"

#############################################
#  USER INPUT
#############################################
read -p "Primary domain (CN), e.g., example.com: " DOMAIN
read -p "SANs (comma-separated), e.g., www.example.com,api.example.com (leave blank if none): " ALT_NAMES_RAW

# Normalize SAN string
ALT_NAMES=$(echo "$ALT_NAMES_RAW" | tr -d ' ')

#############################################
#  OUTPUT PATHS
#############################################
OUTPUT_DIR="$DOMAIN"
mkdir -p "$OUTPUT_DIR"

PRIVATE_KEY="${OUTPUT_DIR}/private.key"
CSR_FILE="${OUTPUT_DIR}/request.csr"
CSR_JSON_FILE="${OUTPUT_DIR}/csr.json"
TOKEN_FILE="${OUTPUT_DIR}/token.txt"
CERT_CRT="${OUTPUT_DIR}/certificate.crt"
FULLCHAIN_CRT="${OUTPUT_DIR}/fullchain.crt"

#############################################
#  STEP 1: Request Token
#############################################
echo
echo "===== STEP 1: Request Token ====="
TOKEN_RESP=$(curl -sS \
  -X POST "$TOKEN_URL" \
  -H 'accept: application/json' \
  -H 'content-type: application/x-www-form-urlencoded' \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "client_id=${CLIENT_ID}" \
  --data-urlencode "client_secret=${CLIENT_SECRET}")

if command -v jq >/dev/null 2>&1; then
  ACCESS_TOKEN=$(printf '%s' "$TOKEN_RESP" | jq -r '.access_token // empty')
else
  ACCESS_TOKEN=$(printf '%s' "$TOKEN_RESP" | sed -nE 's/.*"access_token"\s*:\s*"([^"]+)".*/\1/p')
fi

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "❌ Failed to obtain access token"
  echo "$TOKEN_RESP"
  exit 1
fi

printf '%s\n' "$ACCESS_TOKEN" > "$TOKEN_FILE"
echo "Token saved to $TOKEN_FILE"

#############################################
#  STEP 2 & STEP 3: Generate Private Key and CSR (single command)
#############################################
echo
echo "===== STEP 2 and 3: Generate KEY and CSR ====="
openssl req -new -newkey rsa:2048 -nodes \
  -keyout "$PRIVATE_KEY" -out "$CSR_FILE" \
  -subj "/CN=${DOMAIN}" \
  -addext "subjectAltName=DNS:${DOMAIN}$( [[ -n "$ALT_NAMES" ]] && printf ',DNS:%s' "${ALT_NAMES//,/,DNS:}" )"
echo "Private key created: $PRIVATE_KEY"
echo "CSR saved: $CSR_FILE"

#############################################
#  STEP 4: Build CSR JSON Payload
#############################################
echo
echo "===== STEP 4: Build CSR JSON Payload ====="
# Keep CSR as-is, no need to escape newlines
CSR_CONTENT=$(awk 'NF {sub(/\r/, ""); print}' "$CSR_FILE")

cat > "$CSR_JSON_FILE" <<EOF
{
  "csr": "${CSR_CONTENT}"
}
EOF

echo "CSR JSON saved: $CSR_JSON_FILE"

#############################################
#  STEP 5: Submit CSR for Certificate Issuance
#############################################
echo
echo "===== STEP 5: Submit CSR for Certificate Issuance ====="
RESPONSE=$(curl -sS \
  --request POST \
  --url "$ENROLL_URL" \
  --header 'accept: application/json' \
  --header "authorization: Bearer ${ACCESS_TOKEN}" \
  --header 'content-type: application/json' \
  --data @"${CSR_JSON_FILE}")

echo "Server Response: $RESPONSE"

# Extract certificate ID
if command -v jq >/dev/null 2>&1; then
  CERT_ID=$(echo "$RESPONSE" | jq -r '.id // .certId // empty')
else
  CERT_ID=$(echo "$RESPONSE" | sed -nE 's/.*"id":([0-9]+).*/\1/p')
fi

if [[ -z "$CERT_ID" ]]; then
  echo "❌ Unable to extract certificate ID"
  exit 1
fi

echo "Certificate ID: $CERT_ID"

#############################################
#  STEP 6: Download Certificate & Decode
#############################################
echo
echo "===== STEP 6: Download Certificate & Full Chain ====="
# Request the full PEM chain directly
curl -sS \
  --request GET \
  --url "${ENROLL_URL}/${CERT_ID}" \
  --header "Accept: application/pem-certificate-chain" \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --output "$FULLCHAIN_CRT"

echo "Full chain (server + intermediates) saved: $FULLCHAIN_CRT"

# Extract leaf certificate only
awk 'BEGIN {c=0} /-----BEGIN CERTIFICATE-----/{c++} c==1{print} /-----END CERTIFICATE-----/{if(c==1) exit}' "$FULLCHAIN_CRT" > "$CERT_CRT"
echo "Leaf certificate saved: $CERT_CRT"

echo
echo "===== COMPLETE ====="
echo "  Domain:         $DOMAIN"
echo "  Private key:    $PRIVATE_KEY"
echo "  CSR:            $CSR_FILE"
echo "  CSR JSON:       $CSR_JSON_FILE"
echo "  Token:          $TOKEN_FILE"
echo "  Certificate:    $CERT_CRT"
echo "  Full Chain:     $FULLCHAIN_CRT"
echo
echo "All files are saved inside: $OUTPUT_DIR"
