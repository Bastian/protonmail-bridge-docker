#!/usr/bin/env bash
set -euo pipefail
# Initialize a headless password store once (used by Bridge as its keychain)
if [ ! -f "$HOME/.password-store/.gpg-id" ]; then
  cat >/tmp/genkey <<'EOF'
%no-protection
Key-Type: RSA
Key-Length: 2048
Subkey-Type: RSA
Subkey-Length: 2048
Name-Real: Proton Bridge Vault
Name-Email: vault@local
Expire-Date: 0
%commit
EOF
  gpg --batch --gen-key /tmp/genkey
  rm -f /tmp/genkey
  # Get the key ID and initialize pass with it
  GPG_KEY_ID=$(gpg --list-keys --keyid-format LONG "vault@local" | grep -E "^      " | head -1 | tr -d ' ')
  pass init "$GPG_KEY_ID"
fi
exec "$@"