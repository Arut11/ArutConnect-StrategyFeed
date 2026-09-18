param(
    [Parameter(Mandatory=$true)][string]$PrivateKeyPath,
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)
$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $Root 'manifest.json'
$m = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
foreach ($s in $m.Strategies) {
    $path = Join-Path $Root ($s.File -replace '/', '\')
    if (-not (Test-Path -LiteralPath $path)) { throw ('Missing strategy: ' + $s.File) }
    $s.Sha256 = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
}
# Preserve a deterministic property order compatible with the repository format.
$ordered = [ordered]@{
    Schema = [int]$m.Schema
    FeedId = [string]$m.FeedId
    PackVersion = [string]$m.PackVersion
    MinAppVersion = [string]$m.MinAppVersion
    GeneratedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    KeyId = [string]$m.KeyId
    Strategies = @($m.Strategies | ForEach-Object { [ordered]@{ Id=[string]$_.Id; Version=[int]$_.Version; File=[string]$_.File; Sha256=[string]$_.Sha256 } })
}
$json = $ordered | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText($manifestPath, $json + "`n", (New-Object Text.UTF8Encoding($false)))
[byte[]]$data = [IO.File]::ReadAllBytes($manifestPath)
$rsa = New-Object Security.Cryptography.RSACryptoServiceProvider
try {
    $rsa.FromXmlString((Get-Content -LiteralPath $PrivateKeyPath -Raw).Trim())
    [byte[]]$sig = $rsa.SignData($data, [Security.Cryptography.CryptoConfig]::MapNameToOID('SHA256'))
    [IO.File]::WriteAllText((Join-Path $Root 'manifest.sig'), [Convert]::ToBase64String($sig) + "`n", [Text.Encoding]::ASCII)
} finally { $rsa.Dispose() }
Write-Host 'Feed manifest signed successfully.' -ForegroundColor Green
