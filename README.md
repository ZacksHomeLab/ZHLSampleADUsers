# ZHLSampleADUsers

The objective of this module is to be able to generate random accounts in Active Directory to simulate a 'real-world' scenario. This is handy if you need a lot of users to test an implementation of some sort. For example, let's say you wanted to implement Azure AD Connect but wanted to test in a test environment. However, in order to go through the 'gotchas', you'll need a few accounts to simulate said migration.

# Installation

***TODO***

# Dependencies

The following PowerShell Module must be installed:

```
Install-Module -Name 'NameIT' -MinimumVersion '2.3.3' -Repository PSGallery -Force -Scope CurrentUser -ErrorAction Stop
```

The above module is used to generate said data for our Active Directory accounts. Without it, this module will not work. I may add my own version of said module but TBD.

# How-To use this module

I highly recommend to use `-DryRun` and `-Passthru` first (See Example 1).

The parameter `-DryRun` will simulate a production run by doing the following:
* Verify the modules are installed/working
* Verify your provided credentials or PSSession work
* Connect to Active Directory to retrieve Organizational Units

The parameter `-Passthru` will output the generated Active Directory Users to your console.

## Example 1

```
New-ZHLSampleADUsers -Domain 'zackshomelab.com' -Count 5 -DryRun -Passthru
```

The above example will accomplish the following:
* As -DryRun was provided, this will simulate a production run but will NOT add the users to Active Directory.
* Verify our dependencies are installed / imported
* Verify we can connect to Active Directory with local credentials, provided credentials, or provided PSSession.
* Generates 5 random users that have a domain of zackshomelab.com
* Output said generated data to console


## Example 2

```
New-ZHLSampleADUsers -Domain 'zackshomelab.com' -count 5 -Enabled
```

The above example will accomplish the following:
* Generate 5 random users that have a domain of zackshomelab.com
* Generate 5 random passwords for said users as -Enabled was added
* Uses local credentials to access Active Directory
* Retrieve the Organizational Units from Active Directory using local credentials
* Adds 5 active users in various Organizational Units within Active Directory

## Example 3

```
# Create a PSSession
$session = New-PSSession -ComputerName 'dc01.zackshomelab.com' -Credential (Get-Credential) -Name 'DC01'

# Retreive Organizational Units from Active Directory using said PSSession
$OUs = Invoke-Command -Session $session -ScriptBlock { 
    Import-Module -Name 'ActiveDirectory' -ErrorAction SilentlyContinue
    Get-ADOrganizationalUnit -Filter "Name -ne 'Domain Controllers'"
}

# Create a parameter splat
$params = @{
    Domain = 'zackshomelab.com'
    Count = 5
    Enabled = $True
    OUs = $OUs
    Session = $session
    ExportCSV = "$($ENV:TEMP)\ad_users.csv"
}

New-ZHLSampleADUsers @params
```

The above example will accomplish the following:
* Creates a PSSession connecting to dc01.zackshomelab.com
* Uses the provided PSSession to retrieve all Organizational Units that do NOT have a name like 'Domain Controllers'
* Generates 5 random users that have a domain of zackshomelab.com
* Remotes into the provided PSSession to add the 5 users in Active Directory. As -Enabled was present, this will set the users' as active, which means they will have passwords affiliated with their accounts. 
* Exports the generated users' data to the provided path in CSV format

## Example 4

```
$params = @{
    Domain = 'zackshomelab.com'
    Server = 'dc01.zackshomelab.com'
    Credential = (Get-Credential)
    Count = 5
    Enabled = $True
}

New-ZHLSampleADUsers @params
```

The above example will accomplish the following:
* Generates 5 random users that have a domain of zackshomelab.com
* Generates 5 random passwords for said users as -Enabled was present
* Connects to server 'dc01.zackshomelab.com' with the provided credentials to retrieve Organizational Units
* Connects to server 'dc01.zackshomelab.com' with the provided credentials to add said 5 users in Active Directory