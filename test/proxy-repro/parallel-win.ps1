$Host_ = "gitlab.lilangverse.xyz"
$EdgeIP = "192.168.10.33"
$tmpdir = Join-Path $env:TEMP "gitlab_parallel_$(Get-Random)"
New-Item -ItemType Directory -Path $tmpdir -Force | Out-Null
$html = Get-Content "$env:TEMP\gitlab_sign_in.html" -Raw -ErrorAction SilentlyContinue
if (-not $html) {
  curl.exe -sk --ssl-no-revoke --http1.1 --resolve "${Host_}:443:${EdgeIP}" -o "$env:TEMP\gitlab_sign_in.html" "https://${Host_}/users/sign_in"
  $html = Get-Content "$env:TEMP\gitlab_sign_in.html" -Raw
}
$urls = [regex]::Matches($html, '(?:href|src)="(/assets/[^"]+\.(css|js))"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
Write-Host "Parallel fetch $($urls.Count) assets..."
$procs = @()
$i = 0
foreach ($path in $urls) {
  $out = Join-Path $tmpdir "out_$i.bin"
  $hdr = Join-Path $tmpdir "hdr_$i.txt"
  $url = "https://${Host_}${path}"
  $p = Start-Process -FilePath "curl.exe" -ArgumentList @(
    "-sk","--ssl-no-revoke","--http1.1","--resolve","${Host_}:443:${EdgeIP}",
    "-D",$hdr,"-o",$out,"-w","%{http_code} %{size_download}","--max-time","120",$url
  ) -PassThru -NoNewWindow -Wait
  $i++
}
# Actually parallel - restart without -Wait
$procs = @()
$i = 0
foreach ($path in $urls) {
  $out = Join-Path $tmpdir "out_$i.bin"
  $hdr = Join-Path $tmpdir "hdr_$i.txt"
  $meta = Join-Path $tmpdir "meta_$i.txt"
  $url = "https://${Host_}${path}"
  $script = @"
& curl.exe -sk --ssl-no-revoke --http1.1 --resolve '${Host_}:443:${EdgeIP}' -D '$hdr' -o '$out' -w '%{http_code} %{size_download}' --max-time 120 '$url' | Out-File '$meta'
"@
  $procs += Start-Process powershell -ArgumentList "-NoProfile","-Command",$script -PassThru -NoNewWindow
  $i++
}
$procs | ForEach-Object { $_.WaitForExit() }
$pass = 0; $fail = 0
for ($j = 0; $j -lt $urls.Count; $j++) {
  $path = $urls[$j]
  $out = Join-Path $tmpdir "out_$j.bin"
  $hdr = Join-Path $tmpdir "hdr_$j.txt"
  $meta = (Get-Content (Join-Path $tmpdir "meta_$j.txt") -Raw).Trim()
  $parts = $meta -split ' '
  $code = $parts[0]; $dl = [int]$parts[1]
  $clenLine = Select-String -Path $hdr -Pattern '^content-length:' -CaseSensitive:$false -ErrorAction SilentlyContinue | Select-Object -Last 1
  $clen = if ($clenLine) { ($clenLine.Line -replace 'content-length:\s*','').Trim() } else { '?' }
  $bytes = if (Test-Path $out) { [System.IO.File]::ReadAllBytes($out) } else { @() }
  $isHtml = ($bytes.Length -gt 0 -and $bytes[0] -eq 0x3C)
  $ok = ($code -eq '200') -and ($clen -ne '?') -and ($dl -eq [int]$clen) -and (-not $isHtml)
  if ($ok) { $pass++ } else { $fail++; Write-Host "FAIL $path code=$code dl=$dl clen=$clen html=$isHtml" }
}
Write-Host "PARALLEL: $pass/$($urls.Count) ok fail=$fail"
Remove-Item -Recurse -Force $tmpdir -ErrorAction SilentlyContinue
