$defaultDistro="Ubuntu-24.04"
$wslConfigFile = "$env:USERPROFILE\.wslconfig"
$wslBackupFolder = "$env:USERPROFILE\.wslbackups"
$wslBackupDays = 30

if (-not (Test-Path -Path "$wslConfigFile")) {
    New-Item -Path "$wslConfigFile" -ItemType File
    Add-Content -Path "$wslConfigFile" -Value "[wsl2]"
    Add-Content -Path "$wslConfigFile" -Value "memory=8GB"
    Add-Content -Path "$wslConfigFile" -Value "processors=4"
    Add-Content -Path "$wslConfigFile" -Value "swap=0"
    Write-Host "Created wsl configuration $wslConfigFile"
}

if (-not (Test-Path -Path $wslBackupFolder -PathType Container)) {
    New-Item -Path "$wslBackupFolder" -ItemType Directory
    Write-Host "Created wsl backup directory $wslBackupFolder"
}

$backups = Get-ChildItem -Path $wslBackupFolder | Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-$wslBackupDays) }
foreach ($backup in $backups) {
    Write-Host "Delete backup $backup because its older than $wslBackupDays days."
    $confirmation = Read-Host "Are you sure you want to delete the backup '$backup'? (Y/N)"
    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
        Remove-Item -Path $backup.FullName -Force
        Write-Host "Backup deleted."
    }
    else {
        Write-Host "Skipped."
    }
}

function wslWithWait {
    param(
        [string]$ArgumentList
    )    
    $process = Start-Process -PassThru -Wait -NoNewWindow -FilePath "wsl" -ArgumentList $ArgumentList
    if ($process.ExitCode -eq 0) {
        Write-Host "Executed command 'wsl $ArgumentList' with success."
    } else {
        Write-Host "Executed command 'wsl $ArgumentList' with failure."
    }
}

$backupDistro=$null
$currentDistro = wsl -l -v | ForEach-Object { if ($_ -ne "" -and $_ -replace '[\x00-\x1F\x7F]' -like "*$defaultDistro*" ){Write-Output $_ }}
if ($currentDistro) {
    if ($currentDistro -match "\*"){
        $backupDistro = $currentDistro.ToString().Trim().Split(' ')[1]
    } else
    {
        $backupDistro = $currentDistro.ToString().Trim().Split(' ')[0]
    }
    $backupDistro = $backupDistro -replace '[\x00-\x1F\x7F]'
}


if ($backupDistro) {
    $confirmation = Read-Host "Backup current distro '$backupDistro'? (Y/N)"
    if ($confirmation -eq "Y" -or $confirmation -eq "y") {
    $currentDate = Get-Date -Format "yyMMdd"
    $backup = $wslBackupFolder + "\" + $currentDate + "_" + $backupDistro + ".tar"
    Write-Host "Startup backup current distro '$backupDistro' as $backup"
    wslWithWait "--terminate $backupDistro"
    wslWithWait "--export $backupDistro $backup"
    wslWithWait "--unregister $backupDistro"
    }
}
Write-Host "Install distro '$defaultDistro' as new Default"
wslWithWait "--install $defaultDistro"
wslWithWait "--set-default $defaultDistro"
Write-Host "$defaultDistro installed."
