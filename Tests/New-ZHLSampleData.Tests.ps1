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
        As New-ZHLSampleData is an exported 'Public' function, we can access
        said function by importing our downloaded module.

        If this function was a 'private' function and NOT exported, we would have 
        to dot source the script file New-ZHLSampleData.ps1 in order to access
        said function to run tests.

        For example, dot sourcing a private function would look like this:
            . "$PSScriptRoot\..\Private\New-ZHLSampleData.ps1"

        (Note: the above dot sourcing example assumes New-ZHLSampleData.ps1 resides
        in the 'Private' folder)
    #>

    # Import our PowerShell module so we'll have access to New-ZHLSampleData.ps1
    Remove-Module -Name $moduleName -ErrorAction SilentlyContinue
    Import-Module -Name $moduleRoot -Force

    # Generate a domain and template string for all Unit tests
    $domain = "example.com"
    $template = New-ZHLTemplateString
}

<#
    'Describe' is a logical group of tests. 
    
    All our tests for New-ZHLTemplateString will reside in a single 'Describe' group. 
    
    You may have more than one describe in a tests file, but in our case, we only need one.
#>
Describe "Function New-ZHLSampleData" -Tag "Unit" {

    It 'Returns one piece of sample data' {

        # Arrange
        $count = 1
        
        # Act
        $results = New-ZHLSampleData -Count $count -Template $template -Domain $domain

        # Assert
        $results.Count | Should -Be 1
    }

    It 'Returns three pieces of sample data' {

        # Arrange
        $count = 3

        # Act
        $results = New-ZHLSampleData -Count $count -Template $template -Domain $domain

        # Assert
        $results.Count | Should -Be 3
    }

    It 'Returns only unique sample data' {

        # Arrange
        $count = 2
        $testTemplate = "Person=Test Data" `
            + "`nJob=IT Manager" `
            + "`nCompany=My Company" `
            + "`nAddress=123 South Street" `
            + "`nCity=New York" `
            + "`nZIP=12345" `
            + "`nState=NY" `
            + "`nCountry=USA"

        # Act
        $results = New-ZHLSampleData -Count $count -Template $testTemplate -Domain $domain -Unique

        # Assert
        $results.Count | Should -Be 1
    }

    It 'Returns sample data with random Organizational Units' {

        # Arrange
        $count = 5
        $ou1 = [PSCustomObject]@{
            Name = "Test"
            DistinguishedName = "OU=Test,OU=Azure,DC=zackshomelab,DC=com"
            ObjectClass = "organizationalUnit"
            ObjectGUID = "016666e5-1234-1234-1234-092d28a9bad4"
        }
        
        $ou2 = [PSCustomObject]@{
            Name = "Azure"
            DistinguishedName = "OU=Azure,DC=zackshomelab,DC=com"
            ObjectClass = "organizationalUnit"
            ObjectGUID = "5cc29dd7-1234-1234-1234-8fcb166636ec"
        }
        
        $ou3 = [PSCustomObject]@{
            Name = "IT"
            DistinguishedName = "OU=IT,OU=Azure,DC=zackshomelab,DC=com"
            ObjectClass = "organizationalUnit"
            ObjectGUID = "5b97bdb7d-1234-1234-1234-8ef69c219f7"
        }
        
        $OUs = @()
        $OUs += $ou1
        $OUs += $ou2
        $OUs += $ou3

        # Act
        $results = New-ZHLSampleData -Count $count -Template $template -Domain $domain -OUs $OUs

        # Assert
        foreach ($result in $results) {
            $result.OU | Should -BeIn @("OU=Test,OU=Azure,DC=zackshomelab,DC=com", "OU=Azure,DC=zackshomelab,DC=com", "OU=IT,OU=Azure,DC=zackshomelab,DC=com")
        }
    }

    It "Returns as psobject" {
        # Arrange
        $count = 1

        # Act
        $results = New-ZHLSampleData -Count $count -Template $template -Domain $domain

        # Assert
        $results | Should -BeOfType System.Management.Automation.PSObject
    }

    It "Generates an email address" {

         # Arrange
         $count = 3
 
         # Act
         $results = New-ZHLSampleData -Count $count -Template $template -Domain $domain
 
         # Assert
         foreach ($result in $results) {
            # Each email address should match this typical RegEx expression
            $result.Email | Should -Match -RegularExpression "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
         }
    }
}