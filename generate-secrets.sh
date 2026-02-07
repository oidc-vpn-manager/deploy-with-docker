#!/bin/bash
set -euo pipefail

# Generate secure secrets for OIDC VPN Manager production deployment
# This script should be run once during initial setup

SECRETS_DIR="./secrets"

# Create secrets directory if it doesn't exist
mkdir -p "$SECRETS_DIR"

# Function to generate a secure random string
generate_secret() {
    local length=${1:-32}
    openssl rand -base64 $length | tr -d '\n'
}

# Function to generate a strong password
generate_password() {
    local length=${1:-24}
    openssl rand -base64 $length | tr -d '\n' | head -c $length
}

echo "Generating production secrets for OIDC VPN Manager..."

# Database passwords
echo "$(generate_password 32)" > "$SECRETS_DIR/postgres_frontend_password"
echo "$(generate_password 32)" > "$SECRETS_DIR/postgres_ct_password"
echo "$(generate_password 32)" > "$SECRETS_DIR/postgres_webauth_password"

# API secrets
echo "$(generate_secret 64)" > "$SECRETS_DIR/signing_api_secret"
echo "$(generate_secret 64)" > "$SECRETS_DIR/ct_api_secret"

# Flask secret keys
echo "$(generate_secret 64)" > "$SECRETS_DIR/flask_secret_key"
echo "$(generate_secret 64)" > "$SECRETS_DIR/flask_secret_key_ct"
echo "$(generate_secret 64)" > "$SECRETS_DIR/flask_secret_key_signing"
echo "$(generate_secret 64)" > "$SECRETS_DIR/flask_secret_key_webauth"

# CA key passphrase (use existing or generate new)
if [ ! -f "$SECRETS_DIR/ca_key_passphrase" ]; then
    echo "$(generate_password 32)" > "$SECRETS_DIR/ca_key_passphrase"
    echo "⚠️  Generated new CA key passphrase. Make sure to encrypt your CA key with this passphrase."
fi

# OIDC client secret (placeholder - replace with actual value from your OIDC provider)
if [ ! -f "$SECRETS_DIR/oidc_client_secret" ]; then
    echo "REPLACE_WITH_ACTUAL_OIDC_CLIENT_SECRET" > "$SECRETS_DIR/oidc_client_secret"
    echo "⚠️  Please replace the OIDC client secret with the actual value from your OIDC provider."
fi

# Set proper permissions
chmod 600 "$SECRETS_DIR"/*
chown root:root "$SECRETS_DIR"/* 2>/dev/null || true

echo "✅ Secrets generated successfully!"
echo ""
echo "📁 Secrets location: $SECRETS_DIR"
echo "🔒 File permissions set to 600 (read/write owner only)"
echo ""
echo "⚠️  IMPORTANT SECURITY NOTES:"
echo "   1. Update the OIDC client secret in $SECRETS_DIR/oidc_client_secret"
echo "   2. Backup these secrets securely (encrypted storage recommended)"
echo "   3. Never commit secrets to version control"
echo "   4. Consider using a proper secrets management system in production"
echo "   5. Rotate secrets regularly according to your security policy"
echo ""
echo "🔧 Next steps:"
echo "   1. Update .env files with your actual OIDC provider URLs"
echo "   2. Update server hostnames in configuration files"
echo "   3. Add SSL certificates to the ssl/ directory"
echo "   4. Review and customize nginx.conf for your domain"