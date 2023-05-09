<#
.Synopsis
    This script creates random Active Directory Users within an on-premise Active Directory Domain.
.DESCRIPTION
    This script utilizes PowerShell Module NameIT to generate a provided number of users within specific Organizational Units.
.PARAMETER Domain
    The name of the domain (e.g., ad.example.com, domain.com)
.PARAMETER Server
    Specifies the AD DS instance to connect to, by providing one of the following values for a corresponding domain name or directory server. 

    The service may be any of the following: AD LDS, AD DS, or Active Directory snapshot instance.
.PARAMETER Count
    The amount of users to be created.
.PARAMETER InstallModule
    Use this switch if you want to install PowerShell module 'ActiveDirectory' and 'NameIT'. Note, this is only applicable if you're running this script locally.
.PARAMETER Session
    The PSSession of the machine that has access to Active Directory. Active Directory commands will run from said session.
.PARAMETER OUs
    The Active Directory Organizational Units to place said generated Users in. The script will randomize the provided OUs.

    NOTE: If you provide a 'Session' that connects to your server that has access to Active Directory, it will retrieve
    the Organizational Units from said server using the provided Session.
.PARAMETER Enabled
    Specifies if an account is enabled. An enabled account requires a password. 
    
    This parameter sets the Enabled property for an account object. 
    
    This parameter also sets the ADS_UF_ACCOUNTDISABLE flag of the Active Directory User Account Control (UAC) attribute. 
    
    The acceptable values for this parameter are:

        $False or 0
        $True or 1
.PARAMETER LDAPFilter
    Specifies an LDAP query string that is used to filter Active Directory objects. 

    You can use this parameter to run your existing LDAP queries. 

    The Filter parameter syntax supports the same functionality as the LDAP syntax. 

    For more information, see the Filter parameter description or type Get-Help about_ActiveDirectory_Filter.
.PARAMETER OUProperties
    Specifies the properties of the output object to retrieve from the server. Use this parameter to retrieve properties that are not included in the default set.

    Specify properties for this parameter as a comma-separated list of names. To display all of the attributes that are set on the object, specify * (asterisk).

    To specify an individual extended property, use the name of the property. 
    
    For properties that are not default or extended properties, you must specify the LDAP display name of the attribute.

    To retrieve properties and display them for an object, you can use the Get-* cmdlet associated with the object and pass the output to the Get-Member cmdlet.
.PARAMETER SearchScope
    Specifies the scope of an Active Directory search. The acceptable values for this parameter are:
        Base or 0
        OneLevel or 1
        Subtree or 2
    A Base query searches only the current path or object. A OneLevel query searches the immediate children of that path or object. A Subtree query searches the current path or object and all children of that path or object.
.PARAMETER OUFilter
    Specifies a query string that retrieves Active Directory objects. This string uses the PowerShell Expression Language syntax. The PowerShell Expression Language syntax provides rich type-conversion support for value types received by the Filter parameter. The syntax uses an in-order representation, which means that the operator is placed between the operand and the value. For more information about the Filter parameter, type Get-Help about_ActiveDirectory_Filter.

    Syntax:

    The following syntax uses Backus-Naur form to show how to use the PowerShell Expression Language for this parameter.

        <filter> ::= "{" <FilterComponentList> "}"
        <FilterComponentList> ::= <FilterComponent> | <FilterComponent> <JoinOperator> <FilterComponent> | <NotOperator> <FilterComponent>
        <FilterComponent> ::= <attr> <FilterOperator> <value> | "(" <FilterComponent> ")"
        <FilterOperator> ::= "-eq" | "-le" | "-ge" | "-ne" | "-lt" | "-gt"| "-approx" | "-bor" | "-band" | "-recursivematch" | "-like" | "-notlike"
        <JoinOperator> ::= "-and" | "-or"
        <NotOperator> ::= "-not"
        <attr> ::= <PropertyName> | <LDAPDisplayName of the attribute>
        <value>::= <compare this value with an <attr> by using the specified <FilterOperator>>

    For a list of supported types for <value>, type Get-Help about_ActiveDirectory_ObjectModel.

    Note: PowerShell wildcards other than *, such as ?, are not supported by the Filter syntax.

    Note: To query using LDAP query strings, use the LDAPFilter parameter.
.PARAMETER DryRun
    Specifies a hypothetical run without creatin any actual Active Directory Users. 
    
    This hypothetically run WILL attempt to connect to Active Directory to retrieve the Organizational Units but will skip if it cannot. 
    
    This switch will test your provided parameters and it's recommended to use said switch before running this script without it.
.PARAMETER Passthru
    Specifies passing the generated sample Active Directory User's data to the pipeline.
.PARAMETER ExportCSV
    Specifies the path of the CSV file which will contain the generated Active Directory User data.

    This is useful if you need to keep track of changes.
.PARAMETER Credential
    Specifies the user account credentials to use to perform this task. The default credentials are the credentials of the currently logged on user unless the cmdlet is run from an Active Directory module for Windows PowerShell provider drive. If the cmdlet is run from such a provider drive, the account associated with the drive is the default.

    To specify this parameter, you can type a user name, such as User1 or Domain01\User01 or you can specify a PSCredential object. If you specify a user name for this parameter, the cmdlet prompts for a password.

    You can also create a PSCredential object by using a script or by using the Get-Credential cmdlet. You can then set the Credential parameter to the PSCredential object.

    If the acting credentials do not have directory-level permission to perform the task, Active Directory module for Windows PowerShell returns a terminating error.
.EXAMPLE
    New-ZHLSampleADUsers -Domain 'zackshomelab.com' -Count 5 -DryRun -Passthru

    The above example will accomplish the following:
        * Generate 5 random users that have a domain of zackshomelab.com
        * Skip adding the person to Active Directory as -DryRun was added.
        * Output the generated users' to console

.EXAMPLE
    New-ZHLSampleADUsers -Domain 'zackshomelab.com' -count 5 -Enabled

    The above example will accomplish the following:
        * Generate 5 random users that have a domain of zackshomelab.com
        * Generate 5 random passwords for said users as -Enabled was added
        * Uses local credentials to access Active Directory
        * Adds the 5 random users as active account to Active Directory 
.EXAMPLE
    $session = New-PSSession -ComputerName 'dc01.zackshomelab.com' -Credential (Get-Credential) -Name 'DC01'

    $OUs = Invoke-Command -Session $session -ScriptBlock { 
        Import-Module -Name 'ActiveDirectory' -ErrorAction SilentlyContinue
        Get-ADOrganizationalUnit -Filter "Name -ne 'Domain Controllers'"
    }

    $params = @{
        Domain = 'zackshomelab.com'
        Count = 5
        Enabled = $True
        OUs = $OUs
        Session = $session
        ExportCSV = "$($ENV:TEMP)\ad_users.csv)"
    }

    New-ZHLSampleADUsers @params

    The above example will accomplish the following:
        * Creates a PSSession connecting to dc01.zackshomelab.com
        * Retrieve all Organizational Units that do NOT have a name like 'Domain Controllers'
        * Generates 5 random users that have a domain of zackshomelab.com
        * Generates 5 random passwords for said users as -Enabled was added
        * Uses the provided session to remote into DC01 to add the users in Active Directory
        * Passes the generated user data to the provided path.
.EXAMPLE
    $params = @{
        Domain = 'zackshomelab.com'
        Server = 'dc01.zackshomelab.com'
        Credential = (Get-Credential)
        Count = 5
        Enabled = $True
    }

    New-ZHLSampleADUsers @params

    The above example will accomplish the following:
        * Generates 5 random users that have a domain of zackshomelab.com
        * Generates 5 random passwords for said users as -Enabled was added
        * Connects to server 'dc01.zackshomelab.com' with the provided credentials to retrieve Organizational Units
        * Connects to server 'dc01.zackshomelab.com' to add the users in Active Directory
.NOTES
    Author - Zack Flowers
.LINK
    GitHub - https://github.com/ZacksHomeLab
#>
#requires -RunAsAdministrator
function New-ZHLSampleADUsers {
    [cmdletbinding(DefaultParameterSetName="default")]
    param (
        [parameter(Mandatory,
            Position=0,
            ValueFromPipelineByPropertyName)]
            [ValidateScript({$_ -Match "^(?=.{1,255}$)([a-zA-Z0-9](?:(?:[a-zA-Z0-9\-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$"})]
        [string]$Domain,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName)]
            [Alias("ComputerName", "cn", "computer")]
            [ValidateNotNullOrEmpty()]
        [string]$Server,

        [parameter(Mandatory,
            Position=1)]
            [ValidateScript({$_ -gt 0})]
        [int]$Count,

        [parameter(Mandatory=$false)]
        [switch]$InstallModule,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments)]
        [System.Management.Automation.Runspaces.PSSession]$Session,

        [parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments,
            ParameterSetName="ProvidedOUs")]
        [Alias("Identity")]
        [Object[]]$OUs,

        [parameter(Mandatory=$false)]
        [switch]$Enabled,

        [parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName="LDAPFilter")]
        [string]$LDAPFilter,

        [parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName="OUFilter")]
        [Alias("Filter")]
        [string]$OUFilter,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments)]
            [ValidateSet("Base", 0, "OneLevel", 1, "Subtree", 2)]
        [string]$SearchScope,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
        [Alias("Properties")]
        [string[]]$OUProperties,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments)]
            [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential,

        [parameter(Mandatory=$false)]
        [switch]$DryRun,

        [parameter(Mandatory=$false)]
        [switch]$Passthru,

        [parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
        [string]$ExportCSV
    )

    Begin {

        #region Variables

        # Create an empty array to hold our sample data upon creation
        $sampleData = $null

        # Create a variable to hold the organization unit names from the domain
        $orgUnits = $null

        # Create a variable to hold our Get-ADOrganizationalUnit Parameter splatter
        $getOUSplatter = @{}

        # Create a variable to hold our New-ZHLSampleData Parameter splatter
        $newZHLSampleDataSplatter = @{}

        # Create a variable to hold our New-ADUser connection parameters
        $newADUserCredentialSplatter = @{}

        # Create a variable to hold individual person data
        $person = $null
        #endregion

        #region exitcodes
        $exitcode_NotRoot = 10
        $exitcode_CannotRunOnLinux = 11
        $exitcode_FailImportLocalADModule = 12
        $exitcode_FailGenerateSampleData = 13
        $exitcode_SampleDataEmpty = 14
        $exitcode_FailGatherOUs = 15
        $exitcode_FailAddingADUsers = 16
        $exitcode_FailSendFunction = 17
        #endregion

        #region Pre-Checks
        # Stop the script if the user isn't running as root
        if ($PSVersionTable.Platform -eq "Unix") {
            if ($(whoami) -ne "root") {
                Throw "ErrorCode $exitcode_NotRoot - You must run this script as root, stopping."
            }

            # If remote connection is NOT SSH, stop script,
            if ($null -eq $Session) {
                if (-not $DryRun) {
                    Throw "ErrorCode $exitcode_CannotRunOnLinux - You cannot run this script locally on Linux. You may run it on Linux if you create a PSSession and pass parameter 'Session'."
                }
                Write-Warning "New-ZHLSampleADUsers: You MUST pass 'Session' onto this script if you want to run this script on Linux."
            }
        }
        #endregion
    }

    Process {

        #region Install Active Directory PowerShell Module
        if ($PSVersionTable.Platform -ne "Unix") {
            if ($PSBoundParameters.ContainsKey('Server') -and ($Server -match $(hostname) -or $Server -eq 'localhost')) {
                # Install / Import PowerShell module 'ActiveDirectory'
                try {
                    if ($InstallModule) {
                        Write-Debug "New-ZHLSampleADUsers: Installing/Importing PowerShell module 'ActiveDirectory'."
                        Import-AD -InstallModule -ErrorAction Stop
                    } else {
                        Write-Debug "New-ZHLSampleADUsers: Importing PowerShell module 'ActiveDirectory'."
                        Import-AD -ErrorAction Stop
                    }
                    
                } catch {
                    # Stop the script if this is NOT a dryrun
                    if (-not $DryRun) {
                        Throw "ErrorCode $exitcode_FailImportLocalADModule - Failed installing/importing PowerShell module 'ActiveDirectory' due to error $_"
                    }
                    Write-Warning "New-ZHLSampleADUsers: Failed installing/importing PowerShell module 'ActiveDirectory' due to error $_"
                }
            }
        }
        #endregion

        #region Retrieve Organization Units
        try {
            Write-Debug "New-ZHLSampleADUsers: Building parameter splat for Get-ADOrganizationalUnit..."
            # Build the parameter splat for Get-ADOrganizationalUnit!
            # This will return true if we're running on a Windows System but want to use psremoting
            if (-not ($PSBoundParameters.ContainsKey('Session')) -and $PSVersionTable.Platform -ne "Unix") {

                if ($PSBoundParameters.ContainsKey('Server') -and ($Server -notmatch $(hostname) -and $Server -ne 'localhost')) {
                    Write-Debug "New-ZHLSampleADUsers: Adding 'Server' with value $Server to our parameter splat"
                    $getOUSplatter.Add('Server', $Server)
                }
                if ($PSBoundParameters.ContainsKey('Credential')) {
                    Write-Debug "New-ZHLSampleADUsers: Adding 'Credential' to our parameter splat"
                    $getOUSplatter.Add('Credential', $Credential)
                }
            }
            
            # These parameters will need added regardless of the parameter set name
            # Add the type of search scope if provided. Default is to search at the base level
            if ($PSBoundParameters.ContainsKey('SearchScope')) {
                Write-Debug "New-ZHLSampleADUsers: Adding 'SearchScope' with value $SearchScope to our parameter splat"
                $getOUSplatter.Add('SearchScope', $SearchScope)
            }

            # Add OUProperties if they were provided in the search
            if ($PSBoundParameters.ContainsKey('OUProperties')) {
                Write-Debug "New-ZHLSampleADUsers: Adding 'Properties' with value $OUProperties to our parameter splat"
                $getOUSplatter.Add('Properties', $OUProperties)
            }

            # Add ErrorAction to the splatter
            $getOUSplatter.Add('ErrorAction', 'Stop')

            # Check what parameter set name we're running to add additional parameters to our splatter
            switch ($PSCmdlet.ParameterSetName) {
                'ProvidedOUs' {
                    # Proceed with further filtering if -Properties or -SearchScope were added, otherwise store $OUs in $orgUnits
                    if ($PSBoundParameters.ContainsKey('Properties') -or $PSBoundParameters.ContainsKey('SearchScope')) {
                        Write-Debug "New-ZHLSampleADUsers: Adding 'Identity' to parameter splatter."
                        $getOUSplatter.Add('Identity', $OUs)
                    }
                }
        
                'LDAPFilter' { 
                    Write-Debug "New-ZHLSampleADUsers: Adding 'LDAPFilter' with value $LDAPFilter to our parameter splatter."
                    $getOUSplatter.Add('LDAPFilter', $LDAPFilter)
                }

                'OUFilter' {
                    Write-Debug "New-ZHLSampleADUsers: Adding 'Filter' with value $OUFilter to our parameter splatter."
                    $getOUSplatter.Add('Filter', $OUFilter)
                }

                default {
                    # Default option is to retrieve the base level OUs
                    Write-Debug "New-ZHLSampleADUsers: The default filter of '*' has been added to our parameter splatter."
                    $getOUSplatter.Add("Filter", "Name -ne 'Domain Controllers'")
                }
            }

            # Our parameter splatter has been built, we can not retrieve OUs from Active Directory
            # Perform an OU Query against Active Directory if any of these conditions match
            if ($PSCmdlet.ParameterSetName -ne 'ProvidedOUs' -or `
                ($PSCmdlet.ParameterSetName -eq "ProvidedOUs" -and ($PSBoundParameters.ContainsKey('Properties') -or $PSBoundParameters.ContainsKey('SearchScope')))) {
                
                Write-Verbose "New-ZHLSampleADUsers: Retrieving Organizational Units from Active Directory..."

                Write-Debug "New-ZHLSampleADUsers: Attempting to run Get-ADOrganizationalUnit locally or remotely..."
                # Run command locally or run it via Invoke-Command
                if (-not ($PSBoundParameters.ContainsKey('Session'))) {
                    Write-Debug "New-ZHLSampleADUsers: Running Get-ADOrganizationalUnit locally."
                    $orgUnits = Get-ADOrganizationalUnit @getOUSplatter
                } else {
                    Write-Debug "New-ZHLSampleADUsers: Running Get-ADOrganizationalUnit remotely."
                    $orgUnits = Invoke-Command -Session $Session -ScriptBlock {
                        if (-not (Get-Module -Name 'ActiveDirectory')) {
                            Import-Module -Name 'ActiveDirectory'
                        }
                        Get-ADOrganizationalUnit $using:getOUSplatter
                    } -ErrorAction Stop
                }
            } else {
                Write-Debug "New-ZHLSampleADUsers: User provided OUs already with no additional filters, storing provided OUs into orgUnits."
                # We get here if $OUs were provided and -Properties or -SearchScope were NOT provided.
                $orgUnits = $OUs
            }
            
        } catch {
            if (-not $DryRun) {
                Throw "ErrorCode $exitcode_FailGatherOUs - Failure gathering OUs from AD due to error $_."
            }
            Write-Warning "New-ZHLSampleADUsers: Received an error gathering Organizational Units from AD. Error was $_."
            Write-Warning "New-ZHLSampleADUsers: As this is a -DryRun, continue."
        }
        #endregion

        #region Generate User Data
        try {
            
            $newZHLSampleDataSplatter.Add('Count', $Count)
            if ($PSBoundParameters.ContainsKey('Domain')) {
                $newZHLSampleDataSplatter.Add('Domain', $Domain)
            }
            $newZHLSampleDataSplatter.Add('Template', (New-ZHLTemplateString))
            if ($null -ne $orgUnits -and $orgUnits -ne "") {
                $newZHLSampleDataSplatter.Add('OUs', $orgUnits)
            }

            $newZHLSampleDataSplatter.Add('Unique', $true)
            $newZHLSampleDataSplatter.Add('ErrorAction', 'Stop')

            Write-Verbose "New-ZHLSampleADUsers: Creating sample data..."
            $sampleData = New-ZHLSampleData @newZHLSampleDataSplatter

            # Check if we have 'something'
            if ($null -eq $sampleData -or $sampleData -eq "") {
                Throw "ErrorCode $exitcode_SampleDataEmpty - Sample Data returned empty somehow."
            }
        } catch {
            Throw "ErrorCode $exitcode_FailGenerateSampleData - Failure generating sample data due to error $_."
        }
        #endregion

        #region Add Users to Active Directory
        if (-not $DryRun) {
            try {

                if (-not ($PSBoundParameters.ContainsKey('Session'))) {

                    # Create credential param splatter for New-ADUser
                    if ($PSBoundParameters.ContainsKey('Server') -and 
                        ($Server -notmatch $(hostname) -and $Server -ne 'localhost')) {
                            $newADUserCredentialSplatter.Add('Server', $Server)
                    }
                    if ($PSBoundParameters.ContainsKey('Credential')) {
                        $newADUserCredentialSplatter.Add('Credential', $Credential)
                    }

                    Write-Verbose "New-ZHLSampleADUsers: Attempting to add users to Active Directory..."

                    # Add Users to Active Directory
                    foreach ($person in $sampleData) {
                        # Reset the parameter splatter
                        $newADUserSplatter = @{}
                        Write-Debug "New-ZHLSampleADUsers: Attempting to add person $($Person.SamAccountName) in Active Directory."
                        $newADUserSplatter = @{
                            'City' = $person.City
                            'Company' = $person.Company
                            'Country' = $person.Country
                            'Description' = $person.Description
                            'DisplayName' = $person.Person
                            'EmailAddress' = $person.Email
                            'GivenName' = $person.FirstName
                            'Name' = $person.Person
                            'OtherAttributes' = @{'title' = $person.Job}
                            'Path' = $person.OU
                            'PostalCode' = $person.ZIP
                            'SamAccountName' = $person.SamAccountName
                            'State' = $person.State
                            'StreetAddress' = $person.Address
                            'SurName' = $person.LastName
                            'UserPrincipalName' = $person.Email
                            'ErrorAction' = 'Stop'
                        }
                        # Add the credential splatter onto $newADUserSplatter
                        if ($null -ne $newADUserCredentialSplatter) {
                            $newADUserSplatter += $newADUserCredentialSplatter
                        }
                        
                        # If $Enabled is true, we'll need to create a password for the user account
                        if ($Enabled) {
                            $newADUserSplatter.Add('Enabled', $true)
                            # Reset accountPassword just in case
                            $null = $accountPassword

                            # Generate a random password for said individual
                            $accountPassword = (New-RandomPassword -length 40) | ConvertTo-SecureString -AsPlainText
                            $newADUserSplatter.Add('AccountPassword', $accountPassword)
                        }
                        New-ADUser @newADUserSplatter
                    }
                } else {

                    # If $Enabled is true, New-RandomPassword must be sent over to the remote session so that the script can access it
                    if ($Enabled) {
                        try {
                            Write-Verbose "New-ZHLSampleADUsers: Sending function New-RandomPassword to remote session..."
                            Send-Function -Functions "New-RandomPassword" -Session $Session -ErrorAction Stop
                        } catch {
                            Throw "ErrorCode $exitcode_FailSendFunction - Failure sending function to remote session due to error $_."
                        }
                    }
                    
                    # Add Users to Active Directory via Invoke-Command
                    Write-Verbose "New-ZHLSampleADUsers: Attempting to add users to Active Directory via Invoke-Command."
                    Invoke-Command -Session $Session -ScriptBlock {
                        foreach ($person in $using:sampleData) {

                            # Create parameter splatter
                            $newADUserSplatter = @{}

                            # Populate parameter splatter
                            $newADUserSplatter = @{
                                'City' = $person.City
                                'Company' = $person.Company
                                'Country' = $person.Country
                                'Description' = $person.Description
                                'DisplayName' = $person.Person
                                'EmailAddress' = $person.Email
                                'GivenName' = $person.FirstName
                                'Name' = $person.Person
                                'OtherAttributes' = @{'title' = $person.Job}
                                'Path' = $person.OU
                                'PostalCode' = $person.ZIP
                                'SamAccountName' = $person.SamAccountName
                                'State' = $person.State
                                'StreetAddress' = $person.Address
                                'SurName' = $person.LastName
                                'UserPrincipalName' = $person.Email
                                'ErrorAction' = 'Stop'
                            }

                            # If $Enabled is true, we'll need to create a password for the user account
                            if ($using:Enabled) {
                                $newADUserSplatter.Add('Enabled', $true)
                                # Reset accountPassword just in case
                                $accountPassword = $null

                                # Generate a random password for said individual
                                $accountPassword = (New-RandomPassword -length 40)
                                $newADUserSplatter.Add('AccountPassword', ($accountPassword | ConvertTo-SecureString -AsPlainText -Force))
                            }
                            New-ADUser @newADUserSplatter
                        }
                    } -ErrorAction Stop
                }
            } catch {
                Throw "ErrorCode $exitcode_FailAddingADUsers - Failure adding users to Active Directory due to error $_."
            }
        }
        #endregion

        #region Export to CSV
        if ($ExportCSV) {
            Write-Verbose "New-ZHLSampleADUsers: Exporting sample data to location $ExportCSV."
            try {
                $sampleData | Export-Csv -Path $ExportCSV -Append -Force -ErrorAction Stop
            } catch {
                Write-Warning "New-ZHLSampleADUsers: Failure exporting to CSV due to error $_."
            }
            
        }
        #endregion

        #region Output data if -PassThru
        if ($Passthru) {
            return $sampleData
        }
        #endregion
    }
}