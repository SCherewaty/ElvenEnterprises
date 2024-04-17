# PowerShell script to configure system policies and settings
# Require administrative privileges to run this script
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Please run this script as an Administrator." -ForegroundColor Red
    exit
}
# Configuring Password Policies
Write-Host "Configuring Password Policies..."
secedit /export /cfg "$env:TEMP\secpol.cfg"
(gc "$env:TEMP\secpol.cfg").replace("PasswordComplexity = 0", "PasswordComplexity = 1") | sc "$env:TEMP\secpol.cfg"
(gc "$env:TEMP\secpol.cfg").replace("MinimumPasswordLength = 0", "MinimumPasswordLength = 8") | sc "$env:TEMP\secpol.cfg"
secedit /import /cfg "$env:TEMP\secpol.cfg" /db secedit.sdb
secedit /configure /db secedit.sdb
Remove-Item "$env:TEMP\secpol.cfg"
# Configuring Account Lockout Policies
Write-Host "Configuring Account Lockout Policies..."
secedit /export /cfg "$env:TEMP\secpol.cfg"
(gc "$env:TEMP\secpol.cfg").replace("LockoutBadCount = 0", "LockoutBadCount = 5") | sc "$env:TEMP\secpol.cfg"
(gc "$env:TEMP\secpol.cfg").replace("ResetLockoutCount = 30", "ResetLockoutCount = 30") | sc "$env:TEMP\secpol.cfg"
secedit /import /cfg "$env:TEMP\secpol.cfg" /db secedit.sdb
secedit /configure /db secedit.sdb
Remove-Item "$env:TEMP\secpol.cfg"
# Configuring Windows Firewall
Write-Host "Configuring Windows Firewall..."
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)" -Enabled True
# Configuring Windows Update Settings
Write-Host "Configuring Windows Update Settings..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 4
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "ScheduledInstallDay" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "ScheduledInstallTime" -Value 3
Write-Host "All configurations have been applied successfully." -ForegroundColor Green
