#!/bin/bash

# Default values for the options
KEY_PATH=""
OUT_DIR=""
OUT_FILE="refresh_token.json"
SCOPES=()
POSITIONAL_ARGS=()

# Function to display usage information
usage() {
    echo "Usage: $0 [-k key] [-od outdir] [-of outfile] [-s scope] <client_secrets_json>"
    echo "  -k, --key      Key path for client id, client secret, and redirect uri."
    echo "  -od, --outdir  Output directory path."
    echo "  -of, --outfile Output file name."
    echo "  -s, --scope    Google API scope. You can input multiple scopes."
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
        -s | --scope)
            if [[ -n "$2" ]]; then
                SCOPES+=("$2")
                shift 2
            else
                echo "Error: -s/--scope option requires a value."
                usage
            fi
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

# Ensure at least one positional argument (the client_secrets.json) is provided
if [ ${#POSITIONAL_ARGS[@]} -lt 1 ]; then
    echo "Error: Missing client secrets file."
    usage
fi

CLIENT_SECRETS="${POSITIONAL_ARGS[0]}" # The first positional argument is the client_secrets.json file

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    echo "jq is required but not installed. Please install jq."
    exit 1
fi

# Extract client_id, client_secret, and redirect_uris from client_secrets.json
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

# Join scopes into a single string with "+" separator (needed for the URL)
SCOPE_STRING=$(
    IFS="+"
    echo "${SCOPES[*]}"
)

# Construct the authorization URL
AUTH_URL="https://accounts.google.com/o/oauth2/auth?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&response_type=code&scope=${SCOPE_STRING}&access_type=offline&prompt=consent"

# Inform the user to visit the URL
echo "Please visit the following URL to authorize the application:"
echo "$AUTH_URL"
echo "After authorization, please paste the authorization code here:"

# Read the authorization code from user input
read -p "Authorization code: " AUTH_CODE

# Request the access token and refresh token
RESPONSE=$(curl -s -X POST "https://www.googleapis.com/oauth2/v4/token" \
    -d "code=${AUTH_CODE}" \
    -d "client_id=${CLIENT_ID}" \
    -d "client_secret=${CLIENT_SECRET}" \
    -d "redirect_uri=${REDIRECT_URI}" \
    -d "grant_type=authorization_code")

# Check if the response contains the refresh token
if echo "$RESPONSE" | jq -e '.refresh_token' >/dev/null; then
    # Only create the directory if OUT_DIR is set
    if [ -n "$OUT_DIR" ]; then
        mkdir -p "$OUT_DIR"
        OUTPUT_PATH="${OUT_DIR}/${OUT_FILE}"
    else
        OUTPUT_PATH="${OUT_FILE}"
    fi

    # Write the full response to the output file
    echo "$RESPONSE" >"$OUTPUT_PATH"

    echo "Response saved to $OUTPUT_PATH"
else
    echo "Error: Unable to obtain refresh token. Response: $RESPONSE"
    exit 1
fi
