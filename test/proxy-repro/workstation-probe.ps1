# Batch-probe GitLab sign_in assets via edge
$ErrorActionPreference = "Continue"
$Host_ = "gitlab.lilangverse.xyz"
$EdgeIP = "192.168.10.33"
$Runs = 3
$HtmlPath = "$env:TEMP\gitlab_sign_in.html"

# Fetch sign_in
curl.exe -sk --ssl-no-revoke --http1.1 --resolve "${Host_}:443:${EdgeIP}" `
  -o $HtmlPath -w "sign_in: %{http_code} %{size_download}`n" `
  "https://${Host_}/users/sign_in"

$html = Get-Content $HtmlPath -Raw
$urls = [regex]::Matches($html, '(?:href|src)="(/assets/[^"]+)"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
Write-Host "`n=== $($urls.Count) unique /assets URLs ==="

$failures = @()
$total = 0
$passed = 0

foreach ($path in $urls) {
  $ext = [System.IO.Path]::GetExtension($path)
  if ($ext -notin @('.css', '.js')) { continue }
  Write-Host "`n--- $path ---"
  $clenExpected = $null
  for ($r = 1; $r -le $Runs; $r++) {
    $outFile = "$env:TEMP\probe_$([guid]::NewGuid().ToString('N')).bin"
    $hdrFile = "$env:TEMP\probe_hdr.txt"
    $meta = curl.exe -sk --ssl-no-revoke --http1.1 --no-keepalive --resolve "${Host_}:443:${EdgeIP}" `
      -D $hdrFile -o $outFile -w "%{http_code} %{size_download} %{content_type}" `
      --max-time 120 "https://${Host_}${path}" 2>$null
    $parts = $meta -split ' ', 3
    $code = $parts[0]; $dl = [int]$parts[1]; $ctype = $parts[2]
    $clenLine = Select-String -Path $hdrFile -Pattern '^content-length:' -CaseSensitive:$false | Select-Object -Last 1
    $clen = if ($clenLine) { ($clenLine.Line -replace 'content-length:\s*','').Trim() } else { '?' }
    if (-not $clenExpected -and $clen -ne '?') { $clenExpected = [int]$clen }
    $bytes = if (Test-Path $outFile) { [System.IO.File]::ReadAllBytes($outFile) } else { @() }
    $first = if ($bytes.Length -ge 4) { [BitConverter]::ToString($bytes[0..3]) } else { 'short' }
    $last = if ($bytes.Length -ge 4) { [BitConverter]::ToString($bytes[($bytes.Length-4)..($bytes.Length-1)]) } else { 'short' }
    $isHtml = ($bytes.Length -gt 0 -and $bytes[0] -eq 0x3C)  # '<'
    $ok = ($code -eq '200') -and ($clen -eq '?' -or $dl -eq [int]$clen) -and (-not $isHtml)
    $total++
    if ($ok) { $passed++ } else { $failures += [pscustomobject]@{path=$path; run=$r; code=$code; clen=$clen; dl=$dl; isHtml=$isHtml} }
    Write-Host "  run$r : code=$code clen=$clen dl=$dl ctype=$ctype first=$first isHtml=$isHtml ok=$ok"
    Remove-Item $outFile, $hdrFile -ErrorAction SilentlyContinue
  }
}

Write-Host "`n=== SUMMARY edge: $passed/$total passed ==="
if ($failures.Count -gt 0) {
  Write-Host "FAILURES:"
  $failures | Format-Table -AutoSize
}
