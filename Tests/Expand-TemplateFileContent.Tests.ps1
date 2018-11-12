. "$PSScriptRoot\CommonTestUtil.ps1"
$fileExtensions = '.xml','.json'
#$TestDatabasePath = "c:\temp\testing"
mkdir $TestDataBasePath -Force -ErrorAction SilentlyContinue
del $TestDatabasePath\* -Recurse -ErrorAction SilentlyContinue
function Create-TestFolders {
    mkdir $testDataBasePath\1_STATICTOKEN -Force -ErrorAction SilentlyContinue
    mkdir "$testDataBasePath\2_[[`$DYNAMICTOKEN]]" -Force -ErrorAction SilentlyContinue
}

function Create-TestFiles {
    Get-ChildItem $testDataBasePath -Recurse -Directory | foreach {
        $dirName = Split-Path  $_.FullName -Leaf
        
        foreach($ext in $fileExtensions) {
            $newFile = Join-Path $_.FullName ("$dirName$ext")
            "Lorem ipsum $ext [[`$DYNAMICTOKEN]] STATICTOKEN" | Out-File -LiteralPath $newFile -Force
            Write-Host "Created file: $newFile"
        }
        
        "No tokens here" | Out-File -literalpath "$($_.FullName)\NoTemplateFile.txt" -Force
    }
}

Describe 'Expand-TemplateFileContent' {
    Context 'When expanding template file content' {
        . $setup
        $totalExpansions = 0
        (gci $testDatabasePath -Recurse).FullName
        Expand-TemplateFileContent -SearchDirectory $testDatabasePath -Extension $fileExtensions -ExcludeFiles ('*1_STATICTOKEN.json') -TotalExpansions ([ref]$TotalExpansions)  
        (gci $testDatabasePath -Recurse).FullName|Write-Host -ForegroundColor Green
        It 'can exclude processing specific files' {
            $totalExpansions | Should Be 7
        }
        
        It 'moves renamed folders' {
            (gci $testDataBasePath -Directory -Recurse).Count | Should Be 2
        }
    }
}