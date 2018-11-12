. "$PSScriptRoot\CommonTestUtil.ps1"

Describe 'Expand-TemplatesInDirectoryNames' {
    Context 'When a directory has static tokens to replace in the path name' {
        . $setup
        Expand-TemplatesInDirectoryNames -SearchDirectory $testDataBasePath -StaticReplacements $replacements -TotalReplacements ([ref]$totalReplacements)
        
        It 'expands all static template tokens in the name and renames the directory properly ' {
            "$testDataBasePath\3_$($config.'DYNAMICTOKEN')" | Should Exist 
            "$testDataBasePath\2_TokenIsStaticReplaced_StaticReplaced" | Should Exist 
            "$testDataBasePath\1_TokenIsStaticReplaced_StaticReplaced" | Should Exist 
        }
        
        It 'does not leave old folders behind' {
            "$testDataBasePath\1 _STATICTOKEN" | Should Not Exist
            "$testDataBasePath\2_STATICTOKEN" | Should Not Exist
            "$testDataBasePath\3_[[`$DYNAMICTOKEN]]" | Should Not Exist
        }
        
        It 'returns the actual number of replacements performed' {
            $totalReplacements | Should Be 3
        }
    }
    
    Context 'When replacing directory names, and another directory already exists with the new name' {
        . $setup
        Expand-TemplatesInDirectoryNames -SearchDirectory $testDataBasePath -StaticReplacements $replacements -TotalReplacements ([ref]$totalReplacements)
        . $setup
        Expand-TemplatesInDirectoryNames -SearchDirectory $testDataBasePath -StaticReplacements $replacements -TotalReplacements ([ref]$totalReplacements)
        It 'does not create nested folders' {
            "$testDataBasePath\3_$($config.'DYNAMICTOKEN')\3_$($config.'DYNAMICTOKEN')" | Should Not Exist 
            "$testDataBasePath\2_TokenIsStaticReplaced_StaticReplaced\2_TokenIsStaticReplaced_StaticReplaced" | Should Not Exist 
            "$testDataBasePath\1_TokenIsStaticReplaced_StaticReplaced\1_TokenIsStaticReplaced_StaticReplaced" | Should Not Exist       
        }
    }
    
    Context 'When replacing directory names, and no static content replacments are specified' {
        . $setup
        Expand-TemplatesInDirectoryNames -SearchDirectory $testDataBasePath -TotalReplacements ([ref]$totalReplacements)
         
        It 'it only performs dynamic replacements' {
           "$testDataBasePath\3_$($config.'DYNAMICTOKEN')" | Should Exist 
            "$testDataBasePath\2_TokenIsStaticReplaced_StaticReplaced" | Should Not Exist 
            "$testDataBasePath\1_TokenIsStaticReplaced_StaticReplaced" | Should Not Exist
        }
    }

}

