# ArutConnect Strategy Feed

Official online strategy feed for **Arut Connect**.

This repository contains only declarative strategy definitions. Arut Connect does **not** download or replace `ArutConnect.exe`, `winws.exe`, WinDivert drivers, DLLs or SYS files from this feed.

## Files

- `manifest.json` — feed index with SHA-256 for every strategy definition.
- `manifest.sig` — RSA/SHA-256 signature of the exact `manifest.json` bytes.
- `PUBLIC_KEY.xml` — public verification key pinned by Arut Connect (not secret).
- `strategies/*.json` — declarative `winws` argument templates validated by Arut Connect before activation.
- `tools/verify-feed.ps1` — maintainer-side validation helper.

The private signing key must never be committed to this repository.
