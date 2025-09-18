
$ErrorActionPreference = 'Stop'

$packageName = 'oxipng'
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

Install-ChocolateyZipPackage `
    -PackageName "$packageName" `
    -UnzipLocation "$toolsDir" `
    -Url64bit "https://github.com/shssoichiro/oxipng/releases/download/v9.1.5/oxipng-9.1.5-x86_64-pc-windows-msvc.zip" `
    -Checksum64 "d53981683d8b76f3f3e45410158b4bc3bd78f7d936e3620de4b1ea56c9dffa38" `
    -ChecksumType64 'sha256' `
    -Url "https://github.com/oxipng/oxipng/releases/download/v9.1.5/oxipng-9.1.5-i686-pc-windows-msvc.zip" `
    -Checksum "711afbaa0b3995e27513acc1a77f4828de17632a830c1017ecfff9b76dbbbe3a" `
    -ChecksumType 'sha256'    

$unzipLocation = Get-UnzipFolder

Write-Output "Check installed files ..."
foreach ($executable in $executables) {
    $exePath = Join-Path "$unzipLocation" "$executable.exe"
    if (-Not (Test-Path "$exePath")) {
        Write-Error "File not found: $exePath"
        Exit 1
    }
    & "$exePath" --version # test command
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Test failed: $LASTEXITCODE"
        Exit $LASTEXITCODE
    }
    Write-Output "$executable : OK"    
}

Write-Output "Installing shim files..."
foreach ($executable in $executables) {
    $exePath = Join-Path "$unzipLocation" "$executable.exe"
    Install-BinFile -Name "$executable" -Path "$exePath"
}