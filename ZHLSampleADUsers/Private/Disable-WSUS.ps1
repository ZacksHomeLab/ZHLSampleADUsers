
<#
.Synopsis
    This script disables WSUS.
.DESCRIPTION
    This script sets registry value 'UseWUServer' from Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' to value '0'.
    Once set, Windows service 'wuauserv' will be restarted.
.NOTES
    Author - Zack Flowers
.LINK
    GitHub - https://github.com/ZacksHomeLab
#>
function Disable-WSUS {
    [cmdletbinding()]
    param (
    )

    process {
        try {
            Write-Debug "Disable-WSUS: Set registry value 'UseWUServer' to '0'."
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0 -Force -ErrorAction Stop
        } catch {
            Throw "Disable-WSUS: Failed to set Registry Key 'UseWUServer' to value '0' due to error $_."
        }

        try {
            Write-Debug "Disable-WSUS: Restarting Windows service 'wuauserv'."
            Restart-Service -Name 'wuauserv' -Force -ErrorAction Stop
        } catch {
            Throw "Disable-WSUS: Failure restarting Windows service 'wuauserv' due to error $_."
        }
    }
}