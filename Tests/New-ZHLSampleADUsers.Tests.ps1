# Arrange
<#
    BeforeAll can be placed at the top of the test file to give access to
    all of the Describe, Context (if added), and It sections. 
    
    Otherwise, you can place BeforeAll within 'Describe' to control the scope of said call.
#>
BeforeAll {

    # Arrange
    $projectRoot = Resolve-Path -Path "$PSScriptRoot\.."
    $moduleRoot = Split-Path -Path (Resolve-Path "$projectRoot\*\*.psd1")
    $moduleName = Split-Path -Path $moduleRoot -Leaf

    <#
        As New-ZHLSampleADUsers is an exported 'Public' function, we can access
        said function by importing our downloaded module.

        If this function was a 'private' function and NOT exported, we would have 
        to dot source the script file New-ZHLSampleADUsers.ps1 in order to access
        said function to run tests.

        For example, dot sourcing a private function would look like this:
            . "$PSScriptRoot\..\Private\New-ZHLSampleADUsers.ps1"

        (Note: the above dot sourcing example assumes New-ZHLSampleADUsers.ps1 resides
        in the 'Private' folder)
    #>

    # Import our PowerShell module so we'll have access to New-ZHLSampleADUsers.ps1
    Remove-Module -Name $moduleName -ErrorAction SilentlyContinue
    Import-Module -Name $moduleRoot -Force

    # Generate Organizational Unit data that can be used by all unit tests. 
    # This will be used for the -OUs parameter for the function.
    # Test OU
    $ou1 = [PSCustomObject]@{
        Name = "Test"
        DistinguishedName = "OU=Test,OU=Azure,DC=zackshomelab,DC=com"
        ObjectClass = "organizationalUnit"
        ObjectGUID = "016666e5-1234-1234-1234-092d28a9bad4"
    }
    # Azure OU
    $ou2 = [PSCustomObject]@{
        Name = "Azure"
        DistinguishedName = "OU=Azure,DC=zackshomelab,DC=com"
        ObjectClass = "organizationalUnit"
        ObjectGUID = "5cc29dd7-1234-1234-1234-8fcb166636ec"
    }
    # IT OU
    $ou3 = [PSCustomObject]@{
        Name = "IT"
        DistinguishedName = "OU=IT,OU=Azure,DC=zackshomelab,DC=com"
        ObjectClass = "organizationalUnit"
        ObjectGUID = "5b97bdb7d-1234-1234-1234-8ef69c219f7"
    }
    # Add all OUs to an array
    $OUs = @()
    $OUs += $ou1
    $OUs += $ou2
    $OUs += $ou3

    # Set a domain to be used for New-ZHLSampleData
    $domain = "zackshomelab.com"
}

<#
    'Describe' is a logical group of tests. 
    
    All our tests for New-ZHLSampleADUsers will reside in a single 'Describe' group. 
    
    You may have more than one describe in a tests file, but in our case, we only need one.
#>
Describe "Function New-ZHLSampleADUsers" -Tag "Unit" {

    Context 'Generate Active Directory Users' {

        It 'Generate one person for Active Directory' {

            # Arrange
            $count = 1
            
            # Act 
            # Generate an Active Directory person but do a dry run so it doesn't attempt to
            # communicate with Active Directory
            $results = New-ZHLSampleADUsers -Domain $domain -OUs $OUs -Count $count -DryRun -Passthru
            
            # Assert
            # We should have a person
            $results.Person | Should -Not -BeNullOrEmpty

            # The person should contain an address
            $results.Address | Should -Not -BeNullOrEmpty

            # The person should contain a Company
            $results.Company | Should -Not -BeNullOrEmpty

            # The person should contain a city
            $results.City | Should -Not -BeNullOrEmpty

            # The person should contain a country named USA
            $results.Country | Should -BeExactly "US"

            # The person should contain this description
            $results.Description | Should -BeExactly "New-ZHLSampleADUsers_dont_remove"

            # The person should have an Email
            $results.Email | Should -Match -RegularExpression "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
            # The person's email should contain $domain
            $results.Email | Should -Match $domain

            # The person should contain a First Name
            $results.FirstName | Should -Not -BeNullOrEmpty

            # The person should contain a job
            $results.Job | Should -Not -BeNullOrEmpty

            # The person should contain a Last Name
            $results.LastName | Should -Not -BeNullOrEmpty

            # The person should belong to an OU
            $results.OU | Should -BeIn @("OU=Test,OU=Azure,DC=zackshomelab,DC=com", "OU=Azure,DC=zackshomelab,DC=com", "OU=IT,OU=Azure,DC=zackshomelab,DC=com")

            # The person should contain a SAMAccountName
            $results.SAMAccountName | Should -Not -BeNullOrEmpty

            # The person should contain a state
            $results.State | Should -Not -BeNullOrEmpty

            # The person should contain a ZIP code
            $results.ZIP | Should -Not -BeNullOrEmpty
        }

        It 'Generate at least 5 people for Active Directory' {

            # Arrange
            $count = 10
            
            # Act 
            # Generate an Active Directory person but do a dry run so it doesn't attempt to
            # communicate with Active Directory
            $results = New-ZHLSampleADUsers -Domain $domain -OUs $OUs -Count $count -DryRun -Passthru

            # Assert
            # We should have at least five generated people
            $results.Count | Should -BeGreaterOrEqual 5
        }
    }
    Context 'Test parameters' {
        It 'Should export one person to CSV' {
            # Arrange
            $count = 1
            
            # Create File Name
            $fileName = "$($ENV:TEMP)\$((Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')).csv"
            # Act 
            # Generate an Active Directory person but do a dry run so it doesn't attempt to
            # communicate with Active Directory
            New-ZHLSampleADUsers -Domain $domain -OUs $OUs -Count $count -DryRun -ExportCSV $fileName
            Test-Path -Path $fileName | Should -BeTrue

            # If file exists, retrieve its contents and validate we have data
            $getData = Import-Csv -Path $fileName
            
            # Verify the export was a success
            $getData.Person | Should -Not -BeNullOrEmpty

            # The person should contain an address
            $getData.Address | Should -Not -BeNullOrEmpty

            # The person should contain a Company
            $getData.Company | Should -Not -BeNullOrEmpty

            # The person should contain a city
            $getData.City | Should -Not -BeNullOrEmpty

            # The person should contain a country named USA
            $getData.Country | Should -BeExactly "US"

            # The person should contain this description
            $getData.Description | Should -BeExactly "New-ZHLSampleADUsers_dont_remove"

            # The person should have an Email
            $getData.Email | Should -Match -RegularExpression "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
            # The person's email should contain $domain
            $getData.Email | Should -Match $domain

            # The person should contain a Last Name
            $getData.FirstName | Should -Not -BeNullOrEmpty

            # The person should contain a job
            $getData.Job | Should -Not -BeNullOrEmpty

            # The person should contain a Last Name
            $getData.LastName | Should -Not -BeNullOrEmpty

            # The person should belong to an OU
            $getData.OU | Should -BeIn @("OU=Test,OU=Azure,DC=zackshomelab,DC=com", "OU=Azure,DC=zackshomelab,DC=com", "OU=IT,OU=Azure,DC=zackshomelab,DC=com")

            # The person should contain a SAMAccountName
            $getData.SAMAccountName | Should -Not -BeNullOrEmpty

            # The person should contain a state
            $getData.State | Should -Not -BeNullOrEmpty

            # The person should contain a ZIP code
            $getData.ZIP | Should -Not -BeNullOrEmpty

            # Remove the CSV file we created
            AfterAll {
                Remove-Item -Path $fileName
            }
        }

        It 'Should export more than one person to CSV' {
            # Arrange
            $count = 10
            
            # Create File Name
            $fileName = "$($ENV:TEMP)\$((Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')).csv"
            # Act 
            # Generate an Active Directory person but do a dry run so it doesn't attempt to
            # communicate with Active Directory
            New-ZHLSampleADUsers -Domain $domain -OUs $OUs -Count $count -DryRun -ExportCSV $fileName
            Test-Path -Path $fileName | Should -BeTrue

            # If file exists, retrieve its contents and validate we have data
            $getData = Import-Csv -Path $fileName
            
            # Verify we have more than one person in our CSV
            $getData.Count | Should -BeGreaterThan 1

            # Remove the CSV file we created
            AfterAll {
                Remove-Item -Path $fileName
            }
        }

        It 'Should return null if PassThru was NOT provided' {
            # Arrange
            $count = 1
            
            # Act 
            # Generate an Active Directory person but do a dry run so it doesn't attempt to
            # communicate with Active Directory
            $results = New-ZHLSampleADUsers -Domain $domain -OUs $OUs -Count $count -DryRun

            # As -PassThru was not provided, the pipeline should be empty
            $results | Should -BeNullOrEmpty
        }
    }
}