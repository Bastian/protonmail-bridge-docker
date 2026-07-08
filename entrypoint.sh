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
  # Get the key fingerprint and initialize pass with it
  GPG_KEY_ID=$(gpg --list-keys --with-colons "vault@local" | awk -F: '/^fpr/{print $10; exit}')
  pass init "$GPG_KEY_ID"
fi

# Start socat to forward external connections to localhost
# Bridge only listens on 127.0.0.1, socat makes it accessible from other containers
# Uses ports 1144/1026 externally, forwarding to bridge's 1143/1025
socat TCP-LISTEN:1144,fork,reuseaddr,bind=0.0.0.0 TCP:127.0.0.1:1143 &
socat TCP-LISTEN:1026,fork,reuseaddr,bind=0.0.0.0 TCP:127.0.0.1:1025 &

exec "$@"