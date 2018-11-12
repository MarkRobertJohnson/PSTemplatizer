gci "$PSScriptRoot\..\*.psm1" | Import-Module  -force

Describe 'Import-TemplateConfiguration' {
    Context 'When configuration has template expansions' {
        $workingFile = "$PSScriptRoot\TestData\temp_template_properties.json"
        $expandedWorkingFile = "$PSScriptRoot\TestData\temp_template_properties.pstemplate_expanded.json"
        $origFile = "$PSScriptRoot\TestData\template_properties.json"
        Copy-Item $origFile $workingFile -force
        Import-TemplateConfiguration -Path $workingFile -DoNotDeleteExpandedConfigFiles 
        $expandedConfig = Get-Content $expandedWorkingFile -Raw
        #Write-Host -ForegroundColor Cyan $expandedConfig
        
        It 'expands all template tokens' {
            $expandedConfig | Should Not Match '\[\[.*?\]\]'          
        }
        
        It 'can evaluate powershell method calls' {
            $conf = $expandedConfig | ConvertFrom-Json
            $conf.OctopusProjectNameSlug | Should Match 'ComponentProjectTemplate'
        }
    }
}

