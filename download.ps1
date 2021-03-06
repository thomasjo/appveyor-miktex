$TickMark = [Char]0x2713

function Expand-ZipFile($FilePath, $DestinationPath) {
  New-Item -ItemType Directory -Path $DestinationPath -WarningAction SilentlyContinue -Force | Out-Null

  $Shell = New-Object -ComObject Shell.Application
  $ZipFile = $Shell.Namespace($FilePath)

  # vOption flags: http://msdn.microsoft.com/en-us/library/windows/desktop/bb787866(v=vs.85).aspx
  $Shell.Namespace($DestinationPath).CopyHere($ZipFile.Items(), 0x14) | Out-Null
}

$DownloadUrl = "http://mirrors.ctan.org/systems/win32/miktex/setup/miktexsetup.zip"
$FilePath = "$PSScriptRoot\miktexsetup.zip"
$DestinationPath = "$PSScriptRoot"

Write-Host "Downloading $DownloadUrl... " -NoNewline
(New-Object Net.WebClient).DownloadFile($DownloadUrl, $FilePath)
Write-Host $TickMark

Write-Host "Extracting $FilePath... " -NoNewline
Expand-ZipFile -FilePath $FilePath -DestinationPath $DestinationPath
Write-Host $TickMark

$AsyDownloadUrl = "http://heanet.dl.sourceforge.net/project/asymptote/2.38/asymptote-2.38-setup.exe"
$AsyFilePath = "$PSScriptRoot\asymptote-setup.exe"

Write-Host "Downloading $AsyDownloadUrl... " -NoNewline
(New-Object Net.WebClient).DownloadFile($AsyDownloadUrl, $AsyFilePath)
Write-Host $TickMark
