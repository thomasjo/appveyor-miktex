$RepoDir = "$PSScriptRoot\miktex-repo"
$TargetDir = "$PSScriptRoot\miktex-portable"
Remove-Item -Path $TargetDir -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Recurse -Force

$Date = ((Get-Date).ToUniversalTime()).ToString("ddd MMM  d HH:mm:ss yyyy UTC")
$PosixTargetDir = $TargetDir -replace "\\","/"

#$InstallScriptPath = (Get-ChildItem .\install-tl-*\install-tl-windows.bat).FullName
Invoke-Expression ".\miktexsetup --local-package-repository=$RepoDir --package-set=essential download"
Invoke-Expression ".\miktexsetup --local-package-repository=$RepoDir --package-set=essential --portable=$TargetDir install"

# Install individual packages...
Set-Item env:Path "$TargetDir\texmfs\install\miktex\bin;$env:Path"
Invoke-Expression "mpm --install-some=packages-add"

# Remove individual packages...
$Packages = Get-Content -Path .\packages-remove
ForEach ($Package In $Packages) {
  Invoke-Expression "mpm --uninstall=$Package"
}

#Remove-Item -Path "$TargetDir\texmf-dist\doc" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Recurse -Force
#Remove-Item -Path "$TargetDir\texmf-dist\source" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Recurse -Force

$TarballPath = "$PSScriptRoot\miktex-portable.tar"
$PackagePath = "$TarballPath.xz"
Remove-Item -Path $PackagePath -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Force
Invoke-Expression "7z a -ttar $TarballPath $TargetDir"
Invoke-Expression "7z a -txz -mx9 $PackagePath $TarballPath"
Remove-Item -Path $TarballPath
