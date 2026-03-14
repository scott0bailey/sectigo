#!/bin/bash

#############################################
# CONFIGURATION
#############################################
CLIENT_ID=''
CLIENT_SECRET=''
INSTANCE=''
TASK_ID=

# Discovery URL as defined by your instance and task ID
DISCOVERY_URL="https://admin.enterprise.sectigo.com/api/discovery/v4/net_task/$TASK_ID"
AUTH_URL='https://auth.sso.sectigo.com/auth/realms/apiclients/protocol/openid-connect/token'

#############################################
# 1. AUTHENTICATION
#############################################
# Get the Bearer token
TOKEN_DATA=$(curl -s -X POST "$AUTH_URL" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=client_credentials" \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET")

ACCESS_TOKEN=$(echo "$TOKEN_DATA" | jq -r '.access_token')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo "Auth Failed. Response: $TOKEN_DATA"
    exit 1
fi

#############################################
# 2. QUERY DISCOVERY TASK
#############################################
# We pass the Bearer token AND the explicit Client credentials as headers
# This handles the "Invalid Credentials" (-16) error common in Admin APIs
echo "Querying: $DISCOVERY_URL"

RESPONSE=$(curl -s -X GET "$DISCOVERY_URL" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "customerUri: $INSTANCE" \
    -H "X-Client-Id: $CLIENT_ID" \
    -H "X-Client-Secret: $CLIENT_SECRET" \
    -H "accept: application/json")

#############################################
# 3. DISPLAY RESULTS
#############################################
# Check if the response contains the error code -16
ERROR_CODE=$(echo "$RESPONSE" | jq -r '.code // 0')

if [ "$ERROR_CODE" == "-16" ]; then
    echo "--- Error ---"
    echo "Access Denied: Your API Client does not have 'Network Discovery' permissions."
    echo "Please check: Settings > Admins > API Clients > [Your Client] > Permissions."
else
    echo "--- API Response ---"
    echo "$RESPONSE" | jq .
fi
