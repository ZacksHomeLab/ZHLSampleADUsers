
<#
.Synopsis
    This script enables WSUS.
.DESCRIPTION
    This script sets registry value 'UseWUServer' from Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' to value '1'.
    Once set, Windows service 'wuauserv' will be restarted.
.NOTES
    Author - Zack Flowers
.LINK
    GitHub - https://github.com/ZacksHomeLab
#>
[cmdletbinding()]
param (
)

process {
    try {
        Write-Debug "Enable-WSUS: Set registry value 'UseWUServer' to '1'."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 1 -Force -ErrorAction Stop
    } catch {
        Throw "Enable-WSUS: Failed to set Registry Key 'UseWUServer' to value '1' due to error $_."
    }

    try {
        Write-Debug "Enable-WSUS: Restarting Windows service 'wuauserv'."
        Restart-Service -Name 'wuauserv' -Force -ErrorAction Stop
    } catch {
        Throw "Enable-WSUS: Failure restarting Windows service 'wuauserv' due to error $_."
    }
}