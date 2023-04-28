[CmdletBinding()]
param()

# This variable contains folders that contain PowerShell files
$folders = 'Private', 'Public'

# Iterate through each folder and dot source said files
foreach ($folder in $folders) {

    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder

    if (Test-Path -Path $root) {
        Write-Verbose "Importing PowerShell files from folder '$folder'..."

        $files = Get-ChildItem -Path $root -Filter '*.ps1' -Recurse |
            Where-Object Name -notlike '*.Tests.ps1'

        foreach ($file in $files) {
            Write-Verbose "Dot sourcing [$($file.BaseName)]..."
            . $file.FullName
        }
    }
}

Write-Verbose 'Exporting Public PowerShell functions...'
$functions = Get-ChildItem -Path "$PSScriptRoot\Public" -Filter '*.ps1' -Recurse

Export-ModuleMember -Function $functions.BaseName