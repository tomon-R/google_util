#!/bin/bash

# Default values for the options
KEY_PATH=""
OUT_DIR=""
OUT_FILE="access_token.json"
CLIENT_SECRETS=""
REFRESH_TOKEN_FILE=""

# Function to display usage information
usage() {
    echo "Usage: $0 <client_secrets_json> <refresh_token_json> [-k key] [-od outdir] [-of outfile] [-cf client_secrets_json] [-rf refresh_token_json]"
    echo "  -k, --key          Key path for client id, client secret, and redirect uri."
    echo "  -od, --outdir      Output directory path."
    echo "  -of, --outfile     Output file name."
    echo "  -cf, --clientfile  Path to the client secrets JSON file."
    echo "  -rf, --refreshfile Path to the refresh token JSON file."
    exit 1
}

# Loop through all inputs and classify them
while [[ $# -gt 0 ]]; do
    if [[ "$1" =~ ^- ]]; then
        # If the argument starts with '-', it's an option flag
        case "$1" in
        -k | --key)
            KEY_PATH="$2"
            shift 2
            ;;
        -od | --outdir)
            OUT_DIR="$2"
            shift 2
            ;;
        -of | --outfile)
            OUT_FILE="$2"
            shift 2
            ;;
        -cf | --clientfile)
            CLIENT_SECRETS="$2"
            shift 2
            ;;
        -rf | --refreshfile)
            REFRESH_TOKEN_FILE="$2"
            shift 2
            ;;
        *)
            echo "Invalid option: $1"
            usage
            ;;
        esac
    else
        # Otherwise, it's a positional argument
        POSITIONAL_ARGS+=("$1")
        shift
    fi
done

# Assign positional arguments if not set by flags
if [ -z "$CLIENT_SECRETS" ] && [ -n "${POSITIONAL_ARGS[0]}" ]; then
    CLIENT_SECRETS="${POSITIONAL_ARGS[0]}" # The first positional argument is the client_secrets.json file
fi

if [ -z "$REFRESH_TOKEN_FILE" ] && [ -n "${POSITIONAL_ARGS[1]}" ]; then
    REFRESH_TOKEN_FILE="${POSITIONAL_ARGS[1]}" # The second positional argument is the refresh_token.json file
fi

# Ensure client_secrets.json and refresh_token.json are provided
if [ -z "$CLIENT_SECRETS" ]; then
    echo "Error: Missing client secrets file."
    usage
fi

if [ -z "$REFRESH_TOKEN_FILE" ]; then
    echo "Error: Missing refresh token file."
    usage
fi

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    echo "jq is required but not installed. Please install jq."
    exit 1
fi

# Extract client_id, client_secret, and redirect_uris from CLIENT_SECRETS.json
if [ -z "$KEY_PATH" ]; then
    CLIENT_ID=$(jq -r ".client_id" "$CLIENT_SECRETS")
    CLIENT_SECRET=$(jq -r ".client_secret" "$CLIENT_SECRETS")
    REDIRECT_URI=$(jq -r ".redirect_uris[0]" "$CLIENT_SECRETS")
else
    CLIENT_ID=$(jq -r ".${KEY_PATH}.client_id" "$CLIENT_SECRETS")
    CLIENT_SECRET=$(jq -r ".${KEY_PATH}.client_secret" "$CLIENT_SECRETS")
    REDIRECT_URI=$(jq -r ".${KEY_PATH}.redirect_uris[0]" "$CLIENT_SECRETS")
fi

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ] || [ -z "$REDIRECT_URI" ]; then
    echo "Error: Unable to extract client_id, client_secret, or redirect_uris from client_secrets.json"
    exit 1
fi

# Extract the refresh token from the refresh token file
REFRESH_TOKEN=$(jq -r '.refresh_token' "$REFRESH_TOKEN_FILE")
if [ -z "$REFRESH_TOKEN" ]; then
    echo "Error: Unable to extract refresh_token from $REFRESH_TOKEN_FILE"
    exit 1
fi

# Debugging: Show the extracted values
echo "Client ID: $CLIENT_ID"
echo "Client Secret: $CLIENT_SECRET"
echo "Redirect URI: $REDIRECT_URI"
echo "Refresh Token: $REFRESH_TOKEN"

# Construct the request to get the access token
RESPONSE=$(curl -s -X POST "https://oauth2.googleapis.com/token" \
    -d "client_id=${CLIENT_ID}" \
    -d "client_secret=${CLIENT_SECRET}" \
    -d "refresh_token=${REFRESH_TOKEN}" \
    -d "grant_type=refresh_token")

# Check if the response contains the access token
if echo "$RESPONSE" | jq -e '.access_token' >/dev/null; then
    # Only create the directory if OUT_DIR is set
    if [ -n "$OUT_DIR" ]; then
        mkdir -p "$OUT_DIR"
        OUTPUT_PATH="${OUT_DIR}/${OUT_FILE}"
    else
        OUTPUT_PATH="${OUT_FILE}"
    fi

    # Write the full response to the output file
    echo "$RESPONSE" >"$OUTPUT_PATH"
    echo "Access token response saved to $OUTPUT_PATH"
else
    echo "Error: Unable to obtain access token. Response: $RESPONSE"
    exit 1
fi
