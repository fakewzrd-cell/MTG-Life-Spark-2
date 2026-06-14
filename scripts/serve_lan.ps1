# Serve a release web build on your LAN for phone preview.
# Usage: .\scripts\serve_lan.ps1 [port]

$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

$port = if ($args.Count -gt 0) { [int]$args[0] } else { 5555 }

Write-Host "Building web release..."
flutter pub get | Out-Null
flutter build web --release

$webRoot = Join-Path (Get-Location) "build/web"
if (-not (Test-Path $webRoot)) {
  throw "Missing build/web — build failed."
}

$ip = (
  Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object {
    $_.IPAddress -notmatch '^127\.' -and
    $_.InterfaceAlias -match 'Wi-?Fi|Ethernet' -and
    $_.PrefixOrigin -ne 'WellKnown'
  } |
  Select-Object -First 1 -ExpandProperty IPAddress
)

Write-Host ""
Write-Host "Serving release build on port $port"
if ($ip) {
  Write-Host "Phone URL: http://${ip}:$port"
} else {
  Write-Host "Phone URL: http://<your-pc-lan-ip>:$port"
}
Write-Host "Press Ctrl+C to stop."
Write-Host ""

Set-Location $webRoot
python -m http.server $port --bind 0.0.0.0
