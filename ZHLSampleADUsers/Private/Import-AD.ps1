<#
.Synopsis
    This script will install and/or import PowerShell module ActiveDirectory.
.DESCRIPTION
    If PowerShell module 'ActiveDirectory' does not exist and '-InstallModule' is present, the script will determine if the appropriate
    RSAT tool(s) are installed. If they are NOT installed, the script will disable WSUS (if present), and proceed with the install. 
    Once installed, the script will enable WSUS again. Once said RSAT tool(s) are installed, the PowerShell module 'ActiveDirectory'
    will be imported.

    If '-InstallModule' was NOT passed, this script will ONLY import the module and NOT install it. 
.PARAMETER InstallModule
    Add this switch to install the appropriate RSAT Tool(s) to access PowerShell module 'ActiveDirectory'
.EXAMPLE
    ./Import-AD.ps1

    Import PowerShell module 'ActiveDirectory' onto the local machine. This assumes the module already exists.
.EXAMPLE
    ./Import-AD.ps1 -InstallModule

    Install PowerShell module 'ActiveDirectory' if it does not exist. Once installed, import the module.
.NOTES
    Author - Zack Flowers
.LINK
    GitHub - https://github.com/ZacksHomeLab
#>
function Import-AD {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$false)]
        [switch]$InstallModule
    )

    Begin {

        # Throw an error if we're trying to run this on Linux/Unix
        if ($PSVersionTable.Platform -eq "Unix") {
            Throw "Import-AD: You cannot manage Active Directory from this operating system. Pass a computerName that has access to RSAT / Active Directory PowerShell Modules."
        }

        # Exit if the module is already imported.
        if (Get-Module -Name 'ActiveDirectory' -ErrorAction SilentlyContinue) {
            Write-Verbose "Import-AD: PowerShell Module 'ActiveDirectory' was already imported."
            break
        }

        # Only do all of this work if -InstallModule is present
        if ($InstallModule) {

            # Assume WSUS is not enabled
            $wsusActive = $false

            # Assume we're not on a Server OS
            $isServer = $false

            Write-Debug "Import-AD: -InstallModule was present. Determining which Operating System we're running."
            # Determine the type of system we're running this script on
            $computerInfo = Get-CimInstance ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Caption

            if ($null -eq $computerInfo -or $computerInfo -eq "") {
                Throw "Import-AD: This operating system is not supported."
            }

            # We're running Windows Server
            if ($computerInfo -like "*server*") {

                # Set isServer to true
                $isServer = $true

                Write-Debug "Import-AD: The following operating system matches variant 'Server'."
                Write-Debug "Import-AD: Verifying if Windows Feature 'RSAT-AD-PowerShell' is installed."

                $moduleInstallStatus = (Get-WindowsFeature -Name "RSAT-AD-PowerShell" -ErrorAction SilentlyContinue `
                    | Select-Object -ExpandProperty Installed) -as [bool]

                
            # We're running a variant of Windows Workstation (e.g., 10/11)
            } else {
                Write-Debug "Import-AD: The following operating system matches variant 'Workstation'."
                Write-Debug "Import-AD: Verifying if Windows Capability 'Rsat.ActiveDirectory.DS-LDS.Tools*' is already installed."

                $moduleInstallStatus = ((Get-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools*" -ErrorAction SilentlyContinue `
                    | Select-Object -ExpandProperty State) -eq 'Installed') -as [bool]
            }

            Write-Debug "Import-AD: RSAT Tools installed = $moduleInstallStatus"
        }
    }

    Process {
        
        # Install the module if told to
        if (-not ($moduleInstallStatus)) {
            if (-not ($InstallModule)) {
                Write-Debug "Import-AD: RSAT Tool(s) are not installed. Exiting this script."
                Throw "Import-AD: PowerShell Module 'ActiveDirectory' is not installed. `nImport-AD: Please install said module or pass switch parameter '-installModules' and run the script again"
            }


            # Verify WSUS is disabled before installing said feature or we'll encounter an error
            $wsusActive = Get-WSUSStatus -ErrorAction SilentlyContinue

            # Disable WSUS if it's enabled
            if ($wsusActive) {
                Write-Debug "Import-AD: WSUS was enabled, disabling now."
                Disable-WSUS -ErrorAction Stop
            }

            try {

                # Attempt to install Active Directory PowerShell module via RSAT
                if ($isServer) {
                    Write-Verbose "Import-AD: Installing Windows Feature 'RSAT-AD-PowerShell'."
                    Install-WindowsFeature -Name 'RSAT-AD-PowerShell' -ErrorAction Stop
                } else {
                    Write-Verbose "Import-AD: Adding Windows Capability 'Rsat.ActiveDirectory.DS-LDS.Tools*'."
                    Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools*" -ErrorAction Stop
                }

            } catch {
                Throw "Import-AD: Failure installing Active Directory RSAT tool due to error $_."
            }

            # If WSUS was active previously, enable it again
            if ($wsusActive) {
                Write-Debug "Import-AD: As WSUS was active before the install, we'll need to activate it again."
                Enable-WSUS -ErrorAction Stop
            }
        }

        # Import the Active Directory Module
        try {
            Write-Verbose "Import-NameIT: Importing PowerShell Module 'ActiveDirectory'."
            Import-module -Name "ActiveDirectory" -Force -ErrorAction Stop
        } catch {
            Throw "Import-AD: Failure importing PowerShell Module 'ActiveDirectory' due to error $_."
        }
    }
}