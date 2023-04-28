<#
.Synopsis
    This script will install and/or import PowerShell module 'NameIT'. 
.DESCRIPTION
    This script will install and/or import PowerShell module 'NameIT'.
.PARAMETER InstallModule
    Add this switch to install the PowerShell module if it does not exist.
.EXAMPLE
    ./Import-NameIT.ps1

    Import PowerShell module 'NameIT" but do NOT install it if it does not exist.
.EXAMPLE
    ./Import-NameIT.ps1 -InstallModule

    Install PowerShell module 'NameIT' if it does not exist. Once installed, import the module.
.NOTES
    Author - Zack Flowers
.LINK
    GitHub - https://github.com/ZacksHomeLab
#>
function Import-NameIT {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$false)]
        [switch]$InstallModule
    )

    Begin {

        # Exit if PowerShell Module 'NameIT' was already imported
        if (Get-Module -Name 'NameIT' -ErrorAction SilentlyContinue) {
            Write-Verbose "Import-NameIT: PowerShell Module 'NameIT' was already imported."
            break
        }

        Write-Debug "Import-NameIT: Verifying if PowerShell Module 'NameIT' is already installed."
        $moduleInstallStatus = Get-InstalledModule -Name 'NameIT' -ErrorAction SilentlyContinue
        Write-Debug "Import-NameIT: moduleInstallStatus = $moduleInstallStatus"
    }
    Process {

        # Install the PowerShell Module if it does not exist and parameter 'InstallModule' is present
        if ($null -eq $moduleInstallStatus -or $moduleInstallStatus -eq "") {
            if (-not ($InstallModule)) {
                Throw "Import-NameIT: PowerShell Module is not installed. Please pass parameter '-InstallModule' and run the cmdlet again."
            }
            try {
                Write-Verbose "Import-NameIT: Attempting to install PowerShell module 'NameIT'..."
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Install-Module -Name 'NameIT' -MinimumVersion '2.3.3' -Repository PSGallery -Force -Scope CurrentUser -ErrorAction Stop
            } catch {
                Throw "Import-NameIT: Error installing PowerShell Module 'NameIT' due to error $_."
            }
        }
        
        # Module is installed, attempt to import it
        try {
            Write-Verbose "Import-NameIT: Importing Module NameIT"
            Import-Module -Name 'NameIT' -Force -ErrorAction Stop
        } catch {
            Throw "Import-NameIT: Failure importing PowerShell Module 'NameIT' due to error $_."
        }
    }
}