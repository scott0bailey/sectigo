#!/bin/bash

#############################################
# CONFIGURATION
#############################################
CLIENT_ID=''
CLIENT_SECRET=''
INSTANCE=''
TASK_ID=

# Task Payload Variables
TASK_NAME="Baileys Network Scan - gateway.msft"
BUCKET_ID="d43ffb50-3c6a-435b-af39-3bc46dcbcf7f"
FREQUENCY="Manual"
TIME_ZONE="UTC-05:00"
AGENT_ID="Baileys Windows Network Agent - gateway.msft"
TIME_HOURS=1
TIME_MINUTES=30

DISCOVERY_URL="https://admin.enterprise.sectigo.com/api/discovery/v4/net_task/$TASK_ID"
AUTH_URL='https://auth.sso.sectigo.com/auth/realms/apiclients/protocol/openid-connect/token'

# 1. Get Authentication Token
TOKEN=$(curl -s -X POST "$AUTH_URL" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=client_credentials" \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$CLIENT_SECRET" | jq -r '.access_token')

# 2. Get existing ranges
EXISTING_RANGES=$(curl -s -X GET "$DISCOVERY_URL" \
    -H "Authorization: Bearer $TOKEN" \
    -H "customerUri: $INSTANCE" \
    -H "accept: application/json" | jq -c '.ranges')

echo "Enter the IP Address/Range to add:"
read NEW_ADDR
echo "Enter the Port(s) to scan:"
read NEW_PORTS

# 3. Construct Payload using all Variables
# We map all variables to jq arguments for a clean, secure construction
PAYLOAD=$(jq -nc \
    --arg name "$TASK_NAME" \
    --arg bucket "$BUCKET_ID" \
    --arg freq "$FREQUENCY" \
    --arg tz "$TIME_ZONE" \
    --arg agent "$AGENT_ID" \
    --argjson hrs "$TIME_HOURS" \
    --argjson mins "$TIME_MINUTES" \
    --arg addr "$NEW_ADDR" \
    --arg ports "$NEW_PORTS" \
    --argjson existing "$EXISTING_RANGES" \
    '{
        time: {hours: $hrs, minutes: $mins},
        ranges: ($existing + [{address: $addr, ports: $ports}]),
        name: $name,
        certBucketId: $bucket,
        frequency: $freq,
        timeZone: $tz,
        agent: $agent
    }')

echo "--- Sending Payload ---"
echo "$PAYLOAD" | jq .

# 4. Send PUT request
RESPONSE=$(curl -s -X PUT "$DISCOVERY_URL" \
    -H "Authorization: Bearer $TOKEN" \
    -H "customerUri: $INSTANCE" \
    -H "X-Client-Id: $CLIENT_ID" \
    -H "X-Client-Secret: $CLIENT_SECRET" \
    -H "Content-Type: application/json" \
    -H "accept: application/json" \
    -d "$PAYLOAD")

echo "--- Update Result ---"
echo "$RESPONSE" | jq .
