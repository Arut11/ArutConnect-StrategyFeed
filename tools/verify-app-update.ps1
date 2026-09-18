param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)
$ErrorActionPreference = 'Stop'
$dir = Join-Path $Root 'app-update'
$manifestPath = Join-Path $dir 'manifest.json'
$sigPath = Join-Path $dir 'manifest.sig'
$pubPath = Join-Path $dir 'PUBLIC_KEY.xml'
$m = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if ($m.Schema -ne 1 -or $m.FeedId -ne 'arut-connect-app-update' -or $m.Channel -ne 'stable') { throw 'Unexpected app update manifest.' }
if ([string]$m.LatestVersion -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid LatestVersion.' }
if ($m.InstallerSha256 -and [string]$m.InstallerSha256 -notmatch '^[0-9a-fA-F]{64}$') { throw 'Invalid InstallerSha256.' }
[byte[]]$data = [IO.File]::ReadAllBytes($manifestPath)
[byte[]]$sig = [Convert]::FromBase64String((Get-Content -LiteralPath $sigPath -Raw).Trim())
$rsa = New-Object Security.Cryptography.RSACryptoServiceProvider
try {
    $rsa.FromXmlString((Get-Content -LiteralPath $pubPath -Raw).Trim())
    if (-not $rsa.VerifyData($data, [Security.Cryptography.CryptoConfig]::MapNameToOID('SHA256'), $sig)) { throw 'App update signature invalid.' }
} finally { $rsa.Dispose() }
Write-Host ('APP_UPDATE_FEED_VERIFY_PASS: version=' + $m.LatestVersion + ' signature=RSA/SHA-256') -ForegroundColor Green
