
<#
.Synopsis
    This script returns if WSUS is active or not.
.DESCRIPTION
    This script retrieves registry value 'UseWUServer' from Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'.
    If the registry value returns '1', WSUS is active, otherwise it's not.
.NOTES
    Author - Zack Flowers
.LINK
    GitHub - https://github.com/ZacksHomeLab
.OUTPUTS
    System.boolean
#>
[cmdletbinding()]
param()

begin {
    Write-Debug "Get-WSUSStatus: Retrieving Regkey value 'UseWUServer' to determine if WSUS is active or not.."
    $wsusActive = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" `
        -ErrorAction SilentlyContinue | Select-Object -ExpandProperty UseWUServer) -as [bool]

    Write-Debug "Get-WSUSStatus: Wsus Enabled = $wsusActive"
}

end {
    return $wsusActive
}