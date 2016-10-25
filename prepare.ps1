$RepoDir = "$PSScriptRoot\miktex-repo"
$TargetDir = "$PSScriptRoot\miktex-portable"
Remove-Item -Path $TargetDir -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Recurse -Force

$Date = ((Get-Date).ToUniversalTime()).ToString("ddd MMM  d HH:mm:ss yyyy UTC")
$PosixTargetDir = $TargetDir -replace "\\","/"

Write-Host "Downloading repository..."
Invoke-Expression ".\miktexsetup --local-package-repository=$RepoDir --package-set=essential download"
Write-Host "Installing..."
Invoke-Expression ".\miktexsetup --local-package-repository=$RepoDir --package-set=essential --portable=$TargetDir install"
Invoke-Expression "initexmf --set-config-value=[MPM]AutoInstall=0"

Write-Host "Removing packages..."
$Packages = Get-Content -Path .\packages-remove
ForEach ($Package In $Packages) {
  Invoke-Expression "mpm --uninstall=$Package"
}

Write-Host "Installing packages..."
Set-Item env:Path "$TargetDir\texmfs\install\miktex\bin;$env:Path"
Invoke-Expression "mpm --install-some=packages-add"

Write-Host "Installing Asymptote..."
Start-Process -FilePath ".\asymptote-setup" -Wait -ArgumentList "/S /D=$TargetDir\asymptote"
New-Item "$TargetDir\texmfs\install\tex\latex\asymptote" -type directory
Copy-Item "$TargetDir\asymptote\asymptote.sty" -Destination "$TargetDir\texmfs\install\tex\latex\asymptote"
Invoke-Expression "initexmf --update-fndb"

Write-Host "Creating tarball..."
$TarballPath = "$PSScriptRoot\miktex-portable.tar"
$PackagePath = "$TarballPath.xz"
Remove-Item -Path $PackagePath -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Force
Invoke-Expression "7z a -ttar $TarballPath $TargetDir"
Invoke-Expression "7z a -txz -mx9 $PackagePath $TarballPath"
Remove-Item -Path $TarballPath
