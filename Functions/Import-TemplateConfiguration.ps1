<#
        .SYNOPSIS
        Loads the specified configuration file.  Assumes a flat JSON object structure.

        .EXAMPLE

        Sample JSON config file
        {
        "ProjectName":  "ProjectScaffold",
        "Description":  "Description",
        "Tags":  "Tags",
        "GitHome":  "Git home",
        "Summary":  "Summary",
        "Author":  "Author",
        "GitName":  "GitName"
        }

        .\Load-ComponentConfig.ps1 -Verbose

#>
function Import-TemplateConfiguration {
    [CmdletBinding()]
    param(
        #Path to the config JSON file to load
        [Parameter(Mandatory,ValueFromPipeline)]
        [string[]]$Path ,
        #If specified, then do not load values into process environment variables
        [switch]$DoNotLoadAsEnvironmentVariables,
        #If specified, then do not load values into local variables
        [switch]$DoNotLoadAsLocalVariables,
        [switch]$DoNotExpandConfigTemplates,
        #Do not delete the expanded versions of the config files
        [switch]$DoNotDeleteExpandedConfigFiles
    )

    foreach($configPath in $Path) {
        Write-Verbose "Load config from: $configPath"
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        Write-Verbose "Config values:`n $($config|out-string)"

        $config.psobject.Properties | ForEach-Object {
            $name = $_.Name
            $value = $config."$name" -replace '"','`"'

            if($value -is [PSCustomObject]) { return; }
            if(-not $DoNotLoadAsEnvironmentVariables) {
                [environment]::SetEnvironmentVariable($name, $value)
                Write-Verbose "Set environment variable `$env:$name = '$( [environment]::GetEnvironmentVariable($name))'"
            }
    
            if(-not $DoNotLoadAsLocalVariables) {
                Invoke-Expression "`$global:$name = `"$($value)`""
                Write-Verbose "Set global variable `$global:$name = '$(Get-Variable -Name $name -ValueOnly)'"
            }
        }
         
    }
    
    #Here were apply the loaded template properties to the configuration/property files themselves to allow for using template expansion in JSON config files
    if(-not $DoNotExpandConfigTemplates) {
        $expandedConfigPaths = @()
        foreach($configPath in $Path) {
            $expandedConfigPath = Join-path  (split-path $configPath -Parent)  -Child  (([io.path]::GetFileNameWithoutExtension($configPath)) + '.pstemplate_expanded' + ([io.path]::GetExtension($configPath)))
            Expand-Template -Path $configPath -Destination $expandedConfigPath
            $expandedConfigPaths += $expandedConfigPath 
        }
        
        Import-TemplateConfiguration -Path $expandedConfigPaths `
                            -DoNotLoadAsEnvironmentVariables:$DoNotLoadAsEnvironmentVariables `
                            -DoNotLoadAsLocalVariables:$DoNotLoadAsLocalVariables `
                            -DoNotExpandConfigTemplates `
                            -DoNotDeleteExpandedConfigFiles:$DoNotDeleteExpandedConfigFiles
        if(-not $DoNotDeleteExpandedConfigFiles) {
            Remove-Item $expandedConfigPaths -Force
        }
        
    }

   
  }
  
  
