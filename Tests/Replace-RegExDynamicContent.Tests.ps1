. "$PSScriptRoot\CommonTestUtil.ps1"

Describe 'Replace-RegExDynamicContent' {
    Context 'When expanding template file content' {
        . $setup
        $configPath = "$PSScriptRoot\TestData\template_properties.json"

        $config = gc $configPath | ConvertFrom-Json | Convert-ObjectToHashtable
        $expansions = 0
        $val =Replace-RegExDynamicContent -Replacements $config.RegExDynamicReplacements  -Text "%build.vcs.number.RAPIDGate_SecureEmailDelivery_ComponentProjectTemplateVcsRoot%" -TotalExpansions ([ref]$expansions)
        Import-TemplateConfiguration -Path $configPath
        It 'can replace regex properly' {
            $val | Should Be '%build.vcs.number.RAPIDGatePlatform_ComponentProjectTemplate_ComponentProjectTemplateVcsRoot%'    
        }
    }
}