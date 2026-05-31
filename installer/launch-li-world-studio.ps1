# Installed Li World Studio launcher (invoked from Launch-LiWorldStudio.cmd).
param(
    [string]$Profile,
    [switch]$HostPresent
)

$ErrorActionPreference = "Stop"
$InstallRoot = $PSScriptRoot
. (Join-Path $InstallRoot "LiWorldStudio-Runtime.ps1")

$exitCode = Invoke-LiWorldStudioDemo -InstallRoot $InstallRoot -Profile $Profile -HostPresent:$HostPresent
exit $exitCode
