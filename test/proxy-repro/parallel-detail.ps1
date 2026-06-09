# Detailed parallel probe - show per-asset failures
$Host_ = "gitlab.lilangverse.xyz"
$EdgeIP = "192.168.10.33"
$HtmlPath = "$env:TEMP\gitlab_sign_in.html"
$html = Get-Content $HtmlPath -Raw
$urls = [regex]::Matches($html, '(?:href|src)="(/assets/[^"]+\.(css|js))"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

$scriptBlock = {
  param($Host_, $EdgeIP, $path)
  $outFile = "$env:TEMP\pd_$([guid]::NewGuid().ToString('N')).bin"
  $hdrFile = "$env:TEMP\pd_hdr.txt"
  $meta = curl.exe -sk --ssl-no-revoke --http1.1 --resolve "${Host_}:443:${EdgeIP}" `
    -D $hdrFile -o $outFile -w "%{http_code} %{size_download}" --max-time 120 "https://${Host_}${path}" 2>&1
  $parts = ($meta | Select-Object -Last 1) -split ' '
  $code = if ($parts.Count -ge 1) { $parts[0] } else { 'err' }
  $dl = if ($parts.Count -ge 2) { [int]$parts[1] } else { 0 }
  $clen = '?'
  if (Test-Path $hdrFile) {
    $cl = Select-String -Path $hdrFile -Pattern '^content-length:' -CaseSensitive:$false | Select-Object -Last 1
    if ($cl) { $clen = ($cl.Line -replace 'content-length:\s*','').Trim() }
  }
  $bytes = if (Test-Path $outFile) { [System.IO.File]::ReadAllBytes($outFile) } else { @() }
  $isHtml = ($bytes.Length -gt 0 -and $bytes[0] -eq 0x3C)
  $trunc = ($clen -ne '?' -and $dl -lt [int]$clen)
  Remove-Item $outFile, $hdrFile -ErrorAction SilentlyContinue
  [pscustomobject]@{path=$path; code=$code; clen=$clen; dl=$dl; trunc=$trunc; isHtml=$isHtml}
}

Write-Host "Round 1 parallel ($($urls.Count) assets)..."
$jobs = $urls | ForEach-Object { Start-Job -ScriptBlock $scriptBlock -ArgumentList $Host_, $EdgeIP, $_ }
$r1 = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job -Force
$r1 | Format-Table -AutoSize
$ok1 = ($r1 | Where-Object { $_.code -eq '200' -and $_.clen -ne '?' -and $_.dl -eq [int]$_.clen -and -not $_.isHtml }).Count
Write-Host "Round1: $ok1/$($urls.Count) ok`n"

Start-Sleep -Seconds 5
Write-Host "Round 2 parallel..."
$jobs2 = $urls | ForEach-Object { Start-Job -ScriptBlock $scriptBlock -ArgumentList $Host_, $EdgeIP, $_ }
$r2 = $jobs2 | Wait-Job | Receive-Job
$jobs2 | Remove-Job -Force
$ok2 = ($r2 | Where-Object { $_.code -eq '200' -and $_.clen -ne '?' -and $_.dl -eq [int]$_.clen -and -not $_.isHtml }).Count
Write-Host "Round2: $ok2/$($urls.Count) ok"

Write-Host "`nSequential sanity (3 assets)..."
foreach ($p in $urls[0..2]) {
  $m = curl.exe -sk --ssl-no-revoke --http1.1 --no-keepalive --resolve "${Host_}:443:${EdgeIP}" `
    -o NUL -w "%{http_code} %{size_download}" --max-time 60 "https://${Host_}${p}" 2>$null
  Write-Host "  $p -> $m"
}
