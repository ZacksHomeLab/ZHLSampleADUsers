<#
.Synopsis
    This script generates sample Active Directory data.
.DESCRIPTION
    This script utilizes PowerShell module 'NameIT' to generate sample Active Directory User data.
.PARAMETER Count
    The amount of sample users to be generated.
.PARAMETER Template
    The template string to be used with PowerShell module 'NameIT'.
.PARAMETER Domain
    The name of the Active Directory domain.
.PARAMETER OUs
    The Active Directory Organizational Units.
.PARAMETER Unique
    Use this switch if you want to retrieve unique values as there's a chance to get duplicates.
.PARAMETER InstallModule
    Use this switch if you want to install PowerShell module 'NameIT'.
.EXAMPLE
    $OUs = (Get-ADOrganizationalUnit -Filter "Name -ne 'Domain Controllers'")
    $Template = (New-ZHLTemplateString)

    New-ZHLSampleData -Count 50 -Template $Template -Domain 'zackshomelab.com' -OUs $OUs -Unique

    The above example will generate 50 sample data users for domain 'zackshomelab.com'. Once generated, this script will randomize the
    provided OUs for each user. Once that's complete, the script will retrieve the Unique individuals from said data (there's a chance for duplicates).
.INPUTS
    ADOrganizationalUnit
.OUTPUTS
    PSCustomObject
.NOTES
    Author - Zack Flowers
.LINK
    GitHub - https://github.com/ZacksHomeLab
#>
function New-ZHLSampleData {
    [cmdletbinding()]
    param (
        [parameter(Mandatory,
            Position=0,
            ValueFromPipelineByPropertyName)]
            [ValidateScript({$_ -gt 0})]
        [int]$Count,

        [parameter(Mandatory,
            Position=1,
            ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
        [string]$Template,

        [parameter(Mandatory,
            Position=2,
            ValueFromPipelineByPropertyName)]
            [ValidateScript({$_ -Match "^(?=.{1,255}$)([a-zA-Z0-9](?:(?:[a-zA-Z0-9\-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$"})]
        [string]$Domain,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments)]
        [ValidateNotNullOrEmpty()]
        [Object[]]$OUs,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName)]
        [switch]$InstallModule,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName)]
        [switch]$Unique
    )

    Begin {
        # Create empty PSObjects
        $data = New-Object -TypeName 'System.Management.Automation.PSObject'
        $dataModified = New-Object -TypeName 'System.Management.Automation.PSObject'
        $dataModifiedUnique = New-Object -TypeName 'System.Management.Automation.PSObject'

        
        $email = $null
        $sAMAccountName = $null
        $oU = $null
    }

    Process {
        #region Import PowerShell Module 'NameIT'
        try {
            if ($InstallModule) {
                Write-Debug "New-ZHLSampleADUsers: Installing/Importing PowerShell module 'NameIT'."
                Import-NameIT -InstallModule -ErrorAction Stop
            } else {
                Write-Debug "New-ZHLSampleADUsers: Importing PowerShell module 'NameIT'."
                Import-NameIT -ErrorAction Stop
            }
        } catch {
            Throw "Failed installing/importing PowerShell module 'NameIT' due to error $_"
        }
        #endregion

        #region Add SamAccountName, OU, Description, and Email to each Person
        Write-Debug "New-ZHLSampleData: Begin generating $Count persons using template $Template."
        $data = Invoke-Generate -Count $Count -Template $Template -AsPSObject -ErrorAction Stop

        Write-Debug "New-ZHLSampleData: Addding SamAccountName, OU, Description, and Email to our sample data..."
        $dataModified = foreach ($person in $data) {
            Write-Debug "New-ZHLSampleData: Current Person: $($Person.person)"
            $null = $email
            $null = $sAMAccountName
            $null = $oU

            # Create the SAMAccountName for the user (e.g., john.smith)
            $sAMAccountName = $(($person.person -split ' ') -join '.').ToLower()

            # Create the Email address for the user
            $email = $("$sAMAccountName@$Domain").ToLower()

            # Select a random OU to place the user. Otherwise, leave it blank
            if ($null -ne $OUs -and $OUs -ne "") {
                $OU = Get-Random -InputObject $OUs | Select-Object -ExpandProperty DistinguishedName
                if ($null -ne $OUs -and $OUs -ne "") {
                    $person | Add-Member -MemberType NoteProperty -Name 'OU' -Value $OU -Force
                }
            } else {
                $person | Add-Member -MemberType NoteProperty -Name 'OU' -Value "" -Force
            }

            # Add SAMAccountName to our Person
            $person | Add-Member -MemberType NoteProperty -Name 'SAMAccountName' -Value $samAccountName -Force

            # Add Email to our Person
            $person | Add-Member -MemberType NoteProperty -Name 'Email' -Value $email -Force

            # Add a Description to our Person
            $person | Add-Member -MemberType NoteProperty -Name 'Description' -Value "New-ZHLSampleADUsers_dont_remove" -Force

            # Store Person into dataModified
            $person
        }
        #endregion


        #region If -Unique was provided, filter out potential duplicates
        if ($Unique) {
            Write-Debug "New-ZHLSampleData: Filtering data for duplicates..."
            $dataModifiedUnique = $dataModified | Group-Object -Property 'Email' | Foreach-Object {
                $_.Group[0]
            }
            Write-Debug "New-ZHLSampleData: Finished creating our sample data."
            return $dataModifiedUnique
        }
        #endregion

        Write-Debug "New-ZHLSampleData: Finished creating our sample data."
        # Output dataModified into the pipeline
        return $dataModified
    }
}