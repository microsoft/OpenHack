#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Install Software
choco install microsoft-edge -y
choco install zoom -y
choco install obs-studio -y
choco install obs-ndi -y
choco install webex-meetings -y
choco install gotomeeting -y
choco install bluejeansapp -y
choco install microsoft-teams.install -y