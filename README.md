# machin - setup wsl
With machin you can easily manage wsl instances.\
Before you begin read through the scripts 'wsl/cattle.ps1'.

## 1. PowerShell prechecks (admin)
- `PS C:\> wsl --version`
- `PS C:\> wsl --update`
- `PS C:\> wsl --list --online`
- `PS C:\> git version`

## 2. Clone this project to your windows file system
- `PS C:\> cd ~`
- `PS C:\> mkdir projects`
- `PS C:\> cd projects`
- `PS C:\> git clone `

## 3. Create your wsl instance
The script "cattle.ps-1" need "RemoteSigned" privilages.\

- `PS C:\> Get-ExecutionPolicy -List`
- `PS C:\> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- `PS C:\> cd wsl`
- `PS C:\> .\cattle.ps-1`
