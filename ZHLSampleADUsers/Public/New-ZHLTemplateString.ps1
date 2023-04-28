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

    Begin {
        # Start building the sample data query
        $sampleDataTemplate = "Person=[Person]"
    }
    Process {
        
        # I just needed something simple, I know there's better ways of doing this:
        $sampleDataTemplate += "`nJob=[Job]"
        $sampleDataTemplate += "`nManager=[Person]"
        $sampleDataTemplate += "`nCompany=[Company]"
        $sampleDataTemplate += "`nAddress=[Address]"
        $sampleDataTemplate += "`nCity=[City]"
        $sampleDataTemplate += "`nZIP=[PostalCode]"
        $sampleDataTemplate += "`nState=[State]"
        $sampleDataTemplate += "`nCountry=USA"
        <#
            # If I want to expand this script to add only specific data, I would have something like this:
            foreach ($paramName in $ParamNames) {
                if ($paramName -match "^add") {
                    # Skip item if param matches addEmail
                    if ($paramName -eq "addEmail") {
                        continue
                    }

                    # Set the country to USA if 'addStates' exists, otherwise, add it onto the query
                    # Will be useful if I decide to add non-USA supported countries.
                    if ($paramName -eq "addCountry") {
                        if ($ParamNames -contains "addState") {
                            $sampleDataTemplate += "`nCountry=USA"
                            continue
                        }
                    }
                    # Generate a person's name if -addManager was provided
                    if ($paramName -eq "addManager") {
                        $sampleDataTemplate += "`nManager=[Person]"
                        continue
                    }
                    # Remove 'add' from the parameter Name
                    $sampleDataTemplate += "`n$($paramName.Replace('add',''))=[$($paramName.Replace('add',''))]"
                }
            }
        #>
        # Output the query to pipeline
        return $sampleDataTemplate
    }
}