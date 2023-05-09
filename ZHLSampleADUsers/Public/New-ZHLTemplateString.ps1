<#
.Synopsis
    This script will return the string query to pass to command Invoke-Generate.
.DESCRIPTION
    This script will return the string query to pass to command Invoke-Generate.
.OUTPUTS
    System.String
.NOTES
    Author - Zack Flowers
.LINK
    GitHub - https://github.com/ZacksHomeLab
#>
function New-ZHLTemplateString {
    [cmdletbinding()]
    param (
    )

    End {
        
        return "Person=[Person]" `
            + "`nJob=[Job]" `
            + "`nCompany=[Company]" `
            + "`nAddress=[Address]" `
            + "`nCity=[City]" `
            + "`nZIP=[PostalCode]" `
            + "`nState=[State]" `
            + "`nCountry=US"
    }
}