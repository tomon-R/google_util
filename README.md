# **Google Util**

- [**Google Util**](#google-util)
  - [**get\_oauth\_refresh\_token.sh**](#get_oauth_refresh_tokensh)
    - [**Usage**](#usage)
    - [**Requirement**](#requirement)
    - [**Example**](#example)
  - [**get\_oauth\_access\_token.sh**](#get_oauth_access_tokensh)
    - [**Usage**](#usage-1)
    - [**Requirement**](#requirement-1)
    - [**Example**](#example-1)

## **get_oauth_refresh_token.sh**

It gets google OAuth 2.0 refresh token by your client secrets json.

### **Usage**

**Input**:

    1. Json file path that includes `client id`, `client secret`, and `redirect uri`.

**Output**:

    1. Json file that includes `refresh token`.

**Option**:

-   `-k` or `--key`: Json key path for `client id`, `client secret`, and `redirect uri`.
-   `-od` or `--outdir`: Output directory path.
-   `-of` or `--outfile`: Output file name.
-   `-s` or `--scope`: Google scope. You can input multiple scopes. You can see the list of scopes [here](https://developers.google.com/identity/protocols/oauth2/scopes?hl=ja).

### **Requirement**

It requires `jq` to be installed.

### **Example**

You can authorize and get refresh token by this:

```bash
./get_oauth_refresh_token.sh ./client_secrets.json \
    -k web \
    -od secret \
    -of refresh_token.json \
    -s https://www.googleapis.com/auth/bigquery \
    -s https://www.googleapis.com/auth/userinfo.email
```

The output should be like this:

```json
// ./refresh_token.json
{
	"refresh_token": "your_refresh_token",
	"access_token": "your_access_token",
	"scope": "your_scope",
	"token_type": "your_token_type",
	"expires_in": "second",
	"token_type": "Bearer"
}
```

In above case Your `client_secrets.json` should be like this:

```json
// ./client_secrets.json
{
    " web": {
        "client_id": "your_client_id",
        "project_id": "your_project_id",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_secret": "your_client_secret"
        "redirect_uris": [
            "your_redirect_uri"
        ]
    }
}
```

## **get_oauth_access_token.sh**

It gets google OAuth 2.0 access token by your client secrets json.

### **Usage**

**Input**:

    1. Json file path that includes `client id`, `client secret`, and `redirect uri`.
    2. Json file path that includes `refresh token`.

**Output**: Json file that includes `refresh token`.

**Option**:

-   `-k` or `--key`: Json key path for `client id`, `client secret`, and `redirect uri`.
-   `-od` or `--outdir`: Output directory path.
-   `-of` or `--outfile`: Output file name.
-   `-cf` or `--clientfile`: Client file path.
-   `-rf` or `--refreshfile`: Refresh file path.

### **Requirement**

It requires `jq` to be installed.

### **Example**

You can authorize and get refresh token by this:

```bash
./get_oauth_access_token.sh ./client_secrets.json ./refresh_token.json \
    -k web \
    -od secret \
    -of access_token.json

# or

./get_oauth_access_token.sh \
    -k web \
    -od secret \
    -of access_token.json \
    -cf ./client_secrets.json \
    -rf ./refresh_token.json
```

The output should be like this:

```json
// ./refresh_token.json
{
	"access_token": "your_access_token",
	"scope": "your_scope",
	"token_type": "your_token_type",
	"expires_in": "second",
	"token_type": "Bearer"
}
```

In above case Your `client_secrets.json` and `refresh_token.json` should be like this:

```json
// ./client_secrets.json
{
    " web": {
        "client_id": "your_client_id",
        "project_id": "your_project_id",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_secret": "your_client_secret"
        "redirect_uris": [
            "your_redirect_uri"
        ]
    }
}

// ./refresh_token.json
{
	"refresh_token": "your_refresh_token"
}
```
