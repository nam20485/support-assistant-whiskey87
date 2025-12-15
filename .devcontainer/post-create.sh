#!/bin/bash

# Copy GPG keys from host mount to container's .gnupg directory
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
cp -r ~/.gnupg-host/* ~/.gnupg/ 2>/dev/null || true
chmod 600 ~/.gnupg/* 2>/dev/null || true
chmod 700 ~/.gnupg/private-keys-v1.d 2>/dev/null || true

echo "GPG keys copied from host"
gpg --list-keys 2>/dev/null || echo "No GPG keys found"
