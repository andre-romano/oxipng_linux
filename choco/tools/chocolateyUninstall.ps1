
$ErrorActionPreference = 'Stop'

# $packageName = 'oxipng'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$executables = @('oxipng')

function Get-UnzipFolder {
    $unzipLocation = Get-ChildItem -Directory -Path "$toolsDir\oxipng-*" | Select-Object -First 1
    if (-not $unzipLocation) {
        Write-Error "Unzip folder NOT FOUND in $toolsDir"
        Get-ChildItem "$toolsDir"
        Exit 1
    }
    return $unzipLocation.FullName
}

$unzipLocation = Get-UnzipFolder

Write-Output "Remove shim files..."
foreach ($executable in $executables) {
    Uninstall-BinFile -Name "$executable"
}

Write-Output "Removing extracted files ..."
Remove-Item -Recurse -Force "$unzipLocation"
if (Test-Path "$unzipLocation") {
    Write-Error "Unzip folder still exists: $unzipLocation"
    Exit 1
}
