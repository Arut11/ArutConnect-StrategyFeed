# Publishing a Strategy Feed update

1. Edit/add files under `strategies/`. Keep them declarative JSON only.
2. Update `manifest.json`: bump `PackVersion`, add/remove entries, and set each `Id`, `Version`, and `File`. Hashes and `GeneratedUtc` are refreshed by the signing tool.
3. Keep the private signing key **outside this repository**.
4. Run from PowerShell 5.1:

```powershell
.\tools\sign-feed.ps1 -PrivateKeyPath "D:\secure\ArutConnect_StrategyFeed_PRIVATE_KEY_DO_NOT_COMMIT.xml"
.\tools\verify-feed.ps1
```

5. Commit and push `manifest.json`, `manifest.sig`, and the changed strategy files together.

Arut Connect pins the corresponding public key and refuses a feed whose RSA/SHA-256 signature, per-file SHA-256, schema, paths, placeholders, or allowed `winws` options do not validate.
