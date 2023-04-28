@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'ZHLSampleADUsers.psm1'

    # Version number of this module.
    ModuleVersion     = '0.1.0'

    # ID used to uniquely identify this module
    GUID              = '36fac494-f17d-497e-a98a-54ff760a6cfe'

    # Author of this module
    Author            = 'Zack Flowers'

    # Company or vendor of this module
    #CompanyName       = 'ZHL'

    # Copyright statement for this module
    Copyright         = '(c) 2023 Zack Flowers. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Generates sample Active Directory users using PowerShell module NameIT'

    # Minimum version of the Windows PowerShell engine required by this module
    # PowerShellVersion = ''

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module
    FunctionsToExport = @('New-ZHLSampleADUser')

    # Cmdlets to export from this module
    # CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module
    # AliasesToExport   = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{

        PSData = @{

            # Keyword tags to help users find this module via navigations and search.
            Tags       = @("Active Directory", "AD", "Random", "Generator", "Sample", "Users")

            # The web address of an icon which can be used in galleries to represent this module
            # IconUri   = ""

            # The web address of this module's project or support homepage.
            ProjectUri = "https://github.com/ZacksHomeLab/ZHLSampleADUsers"

            # The web address of this module's license. Points to a page that's embeddable and linkable.
            LicenseUri = "https://github.com/ZacksHomeLab/ZHLSampleADUsers/blob/main/LICENSE"

            ReleaseNotes = @"
0.1.0 20230423
* initial creation
"@
        }
    }

    # HelpInfo URI of this module
    HelpInfoURI = 'https://github.com/ZacksHomeLab/ZHLSampleADUsers'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}