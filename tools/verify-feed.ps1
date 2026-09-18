param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [string]$PublicKeyPath = ''
)
$ErrorActionPreference = 'Stop'
if (-not $PublicKeyPath) { $PublicKeyPath = Join-Path $Root 'PUBLIC_KEY.xml' }
$manifest = Join-Path $Root 'manifest.json'
$sigFile = Join-Path $Root 'manifest.sig'
if (-not (Test-Path -LiteralPath $manifest)) { throw 'manifest.json missing' }
if (-not (Test-Path -LiteralPath $sigFile)) { throw 'manifest.sig missing' }
$m = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
if ($m.Schema -ne 1 -or $m.FeedId -ne 'arut-connect-strategy-feed') { throw 'Unexpected manifest schema/feed id' }
if ($m.Strategies.Count -gt 20) { throw 'Too many strategies in feed' }
foreach ($s in $m.Strategies) {
    $path = Join-Path $Root ($s.File -replace '/', '\')
    if (-not (Test-Path -LiteralPath $path)) { throw ('Missing strategy: ' + $s.File) }
    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne ([string]$s.Sha256).ToLowerInvariant()) { throw ('SHA mismatch: ' + $s.File) }
    $d = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    if ($d.Schema -ne 1 -or $d.Id -ne $s.Id -or $d.Version -ne $s.Version) { throw ('Definition mismatch: ' + $s.File) }
    if (-not ([string]$d.OutputName).StartsWith('general (ARUT ONLINE ')) { throw ('Unsafe output name: ' + $s.File) }
}
if ($PublicKeyPath) {
    [byte[]]$data = [IO.File]::ReadAllBytes($manifest)
    [byte[]]$sig = [Convert]::FromBase64String((Get-Content -LiteralPath $sigFile -Raw).Trim())
    $rsa = New-Object Security.Cryptography.RSACryptoServiceProvider
    try {
        $rsa.FromXmlString((Get-Content -LiteralPath $PublicKeyPath -Raw).Trim())
        if (-not $rsa.VerifyData($data, [Security.Cryptography.CryptoConfig]::MapNameToOID('SHA256'), $sig)) { throw 'Manifest signature invalid' }
    } finally { $rsa.Dispose() }
}
Write-Host ("STRATEGY_FEED_VERIFY_PASS: version={0} strategies={1}" -f $m.PackVersion, $m.Strategies.Count) -ForegroundColor Green
