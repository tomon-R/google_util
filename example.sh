./get_oauth_refresh_token.sh ../secrets/client_secrets.json \
    -k web \
    -od ../secrets \
    -of refresh_token.json \
    -s https://www.googleapis.com/auth/drive \
    -s https://www.googleapis.com/auth/forms \
    -s https://www.googleapis.com/auth/spreadsheets \
    -s https://www.googleapis.com/auth/userinfo.email \
    -s https://www.googleapis.com/auth/documents \
    -s https://www.googleapis.com/auth/script.scriptapp

./get_oauth_access_token.sh ../secrets/client_secrets.json ../secrets/refresh_token.json \
    -k web \
    -od ../secrets \
    -of access_token.json
