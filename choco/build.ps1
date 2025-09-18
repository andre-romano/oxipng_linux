
$dist_path = Join-Path $PSScriptRoot "dist"

$nuspec = Get-ChildItem "$PSScriptRoot\*.nuspec" | Select-Object -First 1
if (-not $nuspec) {
    Write-Error "No .nuspec file found!"
    exit 1
}

[xml]$xml = Get-Content $nuspec

$packageName = $xml.package.metadata.id
$version = $xml.package.metadata.version

if ((-not $version) -or ($version -eq "") `
        -or (-not $packageName) -or ($packageName -eq "")) {
    Write-Error "packageName or version NOT FOUND in $nuspec!"
    exit 1
}
Write-Output "Package: $packageName"
Write-Output "Version: $version"

foreach ($nupkg in Get-ChildItem "$dist_path\*.nupkg") {
    Remove-Item -Force "$nupkg"
}

choco pack -y --outdir "$dist_path" "$nuspec"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed: $LASTEXITCODE"
    Exit $LASTEXITCODE
}

choco install -y --acceptlicense "$packageName" --version="$version" --source="$dist_path;https://community.chocolatey.org/api/v2/"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Install failed: $LASTEXITCODE"
    Exit $LASTEXITCODE
}

choco uninstall -y "$packageName"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Uninstall failed: $LASTEXITCODE"
    Exit $LASTEXITCODE
}

$nupkg = Get-ChildItem "$dist_path\*.nupkg" | Select-Object -First 1
choco push "$nupkg" --source https://push.chocolatey.org/
if ($LASTEXITCODE -ne 0) {
    Write-Error "Push failed: $LASTEXITCODE"
    Exit $LASTEXITCODE
}

Write-Host "$packageName : SUCCESS"