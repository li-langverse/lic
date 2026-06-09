# Browser-like parallel asset fetch + gzip/br encoding
$Host_ = "gitlab.lilangverse.xyz"
$EdgeIP = "192.168.10.33"
$HtmlPath = "$env:TEMP\gitlab_sign_in.html"
$html = Get-Content $HtmlPath -Raw
$urls = [regex]::Matches($html, '(?:href|src)="(/assets/[^"]+\.(css|js))"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

function Probe-Asset($path, $extraHeaders) {
  $outFile = "$env:TEMP\p_$([guid]::NewGuid().ToString('N')).bin"
  $hdrFile = "$env:TEMP\p_hdr.txt"
  $args = @('-sk','--ssl-no-revoke','--http1.1','--resolve',"${Host_}:443:${EdgeIP}",
    '-D',$hdrFile,'-o',$outFile,'-w','%{http_code} %{size_download}','--max-time','120',
    "https://${Host_}${path}")
  if ($extraHeaders) { $args = $extraHeaders + $args }
  $meta = & curl.exe @args 2>$null
  $parts = $meta -split ' '
  $code = $parts[0]; $dl = [int]$parts[1]
  $clenLine = Select-String -Path $hdrFile -Pattern '^content-length:' -CaseSensitive:$false | Select-Object -Last 1
  $encLine = Select-String -Path $hdrFile -Pattern '^content-encoding:' -CaseSensitive:$false | Select-Object -Last 1
  $clen = if ($clenLine) { ($clenLine.Line -replace 'content-length:\s*','').Trim() } else { 'chunked/none' }
  $enc = if ($encLine) { ($encLine.Line -replace 'content-encoding:\s*','').Trim() } else { 'identity' }
  $bytes = if (Test-Path $outFile) { [System.IO.File]::ReadAllBytes($outFile) } else { @() }
  $isHtml = ($bytes.Length -gt 0 -and $bytes[0] -eq 0x3C)
  Remove-Item $outFile, $hdrFile -ErrorAction SilentlyContinue
  [pscustomobject]@{path=$path; code=$code; clen=$clen; dl=$dl; enc=$enc; isHtml=$isHtml}
}

Write-Host "=== PARALLEL (no encoding) ==="
$jobs = $urls | ForEach-Object {
  $p = $_
  Start-Job -ScriptBlock {
    param($Host_, $EdgeIP, $path)
    $outFile = "$env:TEMP\pj_$([guid]::NewGuid().ToString('N')).bin"
    $hdrFile = "$env:TEMP\pj_hdr.txt"
    $meta = curl.exe -sk --ssl-no-revoke --http1.1 --resolve "${Host_}:443:${EdgeIP}" `
      -D $hdrFile -o $outFile -w "%{http_code} %{size_download}" --max-time 120 "https://${Host_}${path}" 2>$null
    $parts = $meta -split ' '
    $clenLine = Select-String -Path $hdrFile -Pattern '^content-length:' -CaseSensitive:$false | Select-Object -Last 1
    $clen = if ($clenLine) { ($clenLine.Line -replace 'content-length:\s*','').Trim() } else { '?' }
    $bytes = if (Test-Path $outFile) { [System.IO.File]::ReadAllBytes($outFile) } else { @() }
    $isHtml = ($bytes.Length -gt 0 -and $bytes[0] -eq 0x3C)
  Remove-Item $outFile, $hdrFile -ErrorAction SilentlyContinue
    [pscustomobject]@{path=$path; code=$parts[0]; clen=$clen; dl=[int]$parts[1]; isHtml=$isHtml; ok=($parts[0]-eq'200' -and $clen-ne'?' -and [int]$parts[1]-eq[int]$clen -and -not $isHtml)}
  } -ArgumentList $Host_, $EdgeIP, $p
}
$parallel = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job -Force
$parPass = ($parallel | Where-Object { $_.ok }).Count
Write-Host "parallel: $parPass/$($parallel.Count) ok"
$parallel | Where-Object { -not $_.ok } | Format-Table

Write-Host "`n=== GZIP encoding (sequential) ==="
$gzipFails = @()
foreach ($path in $urls) {
  $r = Probe-Asset $path @('-H','Accept-Encoding: gzip, deflate, br')
  $ok = ($r.code -eq '200') -and (-not $r.isHtml)
  if (-not $ok) { $gzipFails += $r }
  Write-Host "$($r.path): code=$($r.code) dl=$($r.dl) enc=$($r.enc) isHtml=$($r.isHtml)"
}
Write-Host "gzip sequential: $($urls.Count - $gzipFails.Count)/$($urls.Count) ok"

Write-Host "`n=== KEEPALIVE burst (same connection style) ==="
$burstPass = 0
foreach ($path in $urls) {
  $meta = curl.exe -sk --ssl-no-revoke --http1.1 --resolve "${Host_}:443:${EdgeIP}" `
    -o NUL -w "%{http_code} %{size_download}" --max-time 120 "https://${Host_}${path}" 2>$null
  $parts = $meta -split ' '
  if ($parts[0] -eq '200') { $burstPass++ }
}
Write-Host "keepalive burst: $burstPass/$($urls.Count) code=200"
