param(
    [Parameter(Mandatory=$true)][string]$PrivateKeyPath,
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [string]$InstallerPath = '',
    [string]$InstallerUrl = '',
    [string]$ReleasePageUrl = '',
    [string]$Version = '',
    [string]$Notes = ''
)
$ErrorActionPreference = 'Stop'
$dir = Join-Path $Root 'app-update'
$manifestPath = Join-Path $dir 'manifest.json'
$m = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if ($Version) { $m.LatestVersion = $Version }
if ($ReleasePageUrl) { $m.ReleasePageUrl = $ReleasePageUrl }
if ($Notes) { $m.Notes = $Notes }
if ($InstallerPath) {
    if (-not (Test-Path -LiteralPath $InstallerPath)) { throw 'InstallerPath does not exist.' }
    if (-not $InstallerUrl) { throw 'InstallerUrl is required when InstallerPath is supplied.' }
    $m.InstallerUrl = $InstallerUrl
    $m.InstallerSha256 = (Get-FileHash -LiteralPath $InstallerPath -Algorithm SHA256).Hash.ToLowerInvariant()
}
$m.PublishedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$ordered = [ordered]@{
    Schema = [int]$m.Schema
    FeedId = [string]$m.FeedId
    Channel = [string]$m.Channel
    LatestVersion = [string]$m.LatestVersion
    PublishedUtc = [string]$m.PublishedUtc
    ReleasePageUrl = [string]$m.ReleasePageUrl
    InstallerUrl = [string]$m.InstallerUrl
    InstallerSha256 = [string]$m.InstallerSha256
    Notes = [string]$m.Notes
}
$json = $ordered | ConvertTo-Json -Depth 4
[IO.File]::WriteAllText($manifestPath, $json + "`n", (New-Object Text.UTF8Encoding($false)))
[byte[]]$data = [IO.File]::ReadAllBytes($manifestPath)
$rsa = New-Object Security.Cryptography.RSACryptoServiceProvider
try {
    $rsa.FromXmlString((Get-Content -LiteralPath $PrivateKeyPath -Raw).Trim())
    [byte[]]$sig = $rsa.SignData($data, [Security.Cryptography.CryptoConfig]::MapNameToOID('SHA256'))
    [IO.File]::WriteAllText((Join-Path $dir 'manifest.sig'), [Convert]::ToBase64String($sig) + "`n", [Text.Encoding]::ASCII)
} finally { $rsa.Dispose() }
Write-Host ('APP_UPDATE_SIGN_PASS: version=' + $ordered.LatestVersion) -ForegroundColor Green
