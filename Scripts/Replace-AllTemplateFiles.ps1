<#
        .SYNOPSIS
        Recursively gets all files matching the specified file extension.  The default template extension is ".pstemplate"

        .EXAMPLE
        .\Replace-AllTemplateFiles.ps1 -SearchDirectory c:\ws\git_repos\ProjectScaffold -whatif 

        .EXAMPLE
        .\Replace-AllTemplateFiles.ps1 -SearchDirectory c:\ws\git_repos\ProjectScaffold  -DoNotDeleteTemplateFiles

        .EXAMPLE
        .\Replace-AllTemplateFiles.ps1 -SearchDirectory c:\temp\test-template -Extension '.pstemplate','.?sproj','.cs','.sln','.fsx'  -DoNotDeleteTemplateFiles:$true -ConfigJsonPath .\Load-ComponentCOnfig.ps1 -verbose:$false

        .EXAMPLE
        .\Replace-AllTemplateFiles.ps1 -SearchDirectory C:\ws\git_repos\TestCompTemplate2 -verbose:$true -Extension '.pstemplate','.?sproj','.cs','.sln','.fsx','.md','.nuspec','.xml'  -DoNotDeleteTemplateFiles:$false -ConfigJsonPath C:\ws\git_repos\TestCompTemplate2\template_properties.json 

        .EXAMPLE
        .\Replace-AllTemplateFiles.ps1 -SearchDirectory C:\ws\git_repos\TestCompTemplate2 -verbose:$true -Extension '.csproj'  -DoNotDeleteTemplateFiles:$false -ConfigJsonPath C:\ws\git_repos\TestCompTemplate2\template_properties.json 


        .EXAMPLE
        .\Replace-AllTemplateFiles.ps1 -SearchDirectory C:\ws\git_repos\TestCompTemplate2 -verbose:$true -Extension '.pstemplate','.?sproj','.cs','.sln','.fsx','.md','.nuspec','.xml','.json' -Exclude '*template_properties.json'  -DoNotDeleteTemplateFiles:$false -ConfigJsonPath C:\ws\git_repos\TestCompTemplate2\template_properties.json 
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$true)]
    #The base directory to start searching in
    [string[]]$SearchDirectory, 
    #If set, then template files are not deleted after the template file is expanded and written to a new file
    [switch]$DoNotDeleteTemplateFiles,
    #The file extension of files to treat as templates
    [array]$Extension = ('.pstemplate','.?sproj','.cs','.sln','.fsx','.json','.md','.nuspec','.xml'),
    [string[]]$ExtensionsToStrip = '.pstemplate',
    #File patterns to exclude from template expansion operations
    [string[]]$ExcludeFiles,
    #Path to file containing PowerShell code. This file could contain variable values to use when evaluating templates
    [string[]]$ConfigJsonPath
)


$errorActionPreference= 'stop'
gci "$PSScriptRoot\..\*.psm1" | Import-Module  -force


#Load the configuration
if ($ConfigJsonPath) {
    if (!(Test-Path -Path $ConfigJsonPath)) { throw "Replace-AllTemplateFiles: JSON configuration file(s) `'$ConfigJsonPath`' can't be found" }
    Write-Verbose "Loading JSON Configuration file: $ConfigJsonPath"
    Import-TemplateConfiguration -Path $ConfigJsonPath
}

$config = Get-Content $ConfigJsonPath -Raw | ConvertFrom-Json

Write-Host "Expanding all template files matching $Extension rescursively in folder '$SearchDirectory' ..."
#First perform replacements on folder names themselves

Expand-TemplatesInDirectoryNames -SearchDirectory $SearchDirectory -StaticReplacements (Convert-ObjectToHashtable $config.RegExDynamicReplacements)

Expand-TemplateFileContent -SearchDirectory $SearchDirectory -DoNotDeleteTemplateFiles:$DoNotDeleteTemplateFiles -Extension $Extension -ExcludeFiles $ExcludeFiles -ExtensionsToStrip $ExtensionsToStrip

Expand-TemplateFileContent -SearchDirectory $SearchDirectory -DoNotDeleteTemplateFiles:$DoNotDeleteTemplateFiles -Extension $Extension -ExcludeFiles $ExcludeFiles -ExtensionsToStrip $ExtensionsToStrip `
                             -Transform {
                                            param([Parameter(ValueFromPipeline=$true)][string]$Text, [string]$Path, [string]$Destination, [ref]$TotalExpansions)                                                                          
                                            $PSBoundparameters.Remove('TotalExpansions')|out-null
                                                                               
                                            $expansions = 0
                                            Replace-RegExDynamicContent -Replacements (Convert-ObjectToHashtable $config.RegExDynamicReplacements)  -TotalExpansions ([ref]$expansions) @PSBoundPArameters
                                            if($totalexpansions) {
                                                $TotalExpansions.value = $expansions
                                            }
                                                                                 
                                        }