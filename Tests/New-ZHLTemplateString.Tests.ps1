# Arrange
BeforeAll {

    # Arrange
    $projectRoot = Resolve-Path -Path "$PSScriptRoot\.."
    $moduleRoot = Split-Path -Path (Resolve-Path "$projectRoot\*\*.psd1")
    $moduleName = Split-Path -Path $moduleRoot -Leaf
    <#
        As New-ZHLTemplateString is an exported 'Public' function, we can access
        said function by importing our downloaded module.

        If this function was a 'private' function and NOT exported, we would have 
        to dot source the script file New-ZHLTemplateString.ps1 in order to access
        said function to run tests.

        For example, dot sourcing a private function would look like this:
            . "$PSScriptRoot\..\Private\New-ZHLTemplateString.ps1"

        (Note: the above dot sourcing example assumes New-ZHLTemplateString.ps1 resides
        in the 'Private' folder)
    #>

    # Import our PowerShell module so we'll have access to New-ZHLTemplateSTring.ps1
    Remove-Module -Name $moduleName -ErrorAction SilentlyContinue
    Import-Module -Name $moduleRoot -Force
}

<#
    'Describe' is a logical group of tests. 
    
    All our tests for New-ZHLTemplateString will reside in a single 'Describe' group. 
    
    You may have more than one describe in a tests file, but in our case, we only need one.
#>
Describe "Function New-ZHLTemplateString" -Tag "Unit" {

    It 'Returns the correct template string' {

        # Arrange
        $expected = "Person=[Person]" `
            + "`nJob=[Job]" `
            + "`nCompany=[Company]" `
            + "`nAddress=[Address]" `
            + "`nCity=[City]" `
            + "`nZIP=[PostalCode]" `
            + "`nState=[State]" `
            + "`nCountry=US"


        # Act 
        $result = New-ZHLTemplateString

        # Assert
        $result | Should -BeExactly $expected
    }
}