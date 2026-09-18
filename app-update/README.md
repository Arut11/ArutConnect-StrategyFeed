# Arut Connect application update feed

This directory contains the signed stable-channel update manifest consumed by Arut Connect.

- `manifest.json` — current stable app version and, when a newer build is published, the installer URL and SHA-256.
- `manifest.sig` — RSA/SHA-256 signature over the exact UTF-8/LF bytes of `manifest.json`.
- `PUBLIC_KEY.xml` — public verification key pinned by Arut Connect. It is not secret.

The private app-update signing key must never be committed to this repository.
