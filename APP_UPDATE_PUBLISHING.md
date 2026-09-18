# Publishing an Arut Connect application update

Keep the private app-update signing key outside GitHub. It is intentionally a different key from the Strategy Feed key.

For a real release, build the final `ArutConnectSetup.exe`, upload it as a GitHub Release asset, then run PowerShell 5.1:

```powershell
.\tools\sign-app-update.ps1 `
  -PrivateKeyPath "D:\secure\ArutConnect_AppUpdate_PRIVATE_KEY_DO_NOT_COMMIT.xml" `
  -InstallerPath "C:\path\ArutConnectSetup.exe" `
  -InstallerUrl "https://github.com/Arut11/<app-repo>/releases/download/v1.2.0/ArutConnectSetup.exe" `
  -ReleasePageUrl "https://github.com/Arut11/<app-repo>/releases/tag/v1.2.0" `
  -Version "1.2.0" `
  -Notes "Arut Connect 1.2.0"

.\tools\verify-app-update.ps1
```

Commit `app-update/manifest.json` and `app-update/manifest.sig` together.
