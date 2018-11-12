gci "$PSScriptRoot\..\*.psm1" | Import-Module  -force

function Create-Config {
    @"
{
  "RegExDynamicReplacements": {
    "STATICTOKEN": "`$DYNAMICTOKEN2 + '_StaticReplaced'"
  },
  "DYNAMICTOKEN": "TokenIsReplaced_DynamicReplaced",
  "DYNAMICTOKEN2": "TokenIsStaticReplaced"
}
"@
}

Remove-Variable TestDrive -ErrorAction SilentlyContinue
$testDataBasePath = 'TestDrive:\TestData\Expand-TemplatesInDirectoryNames'
$fileExtensions = '.pstemplate','.csproj','.cs','.sln','.fsx','.md','.nuspec','.xml','.json'
function Create-TestFolders {
    mkdir $testDataBasePath\1_STATICTOKEN -Force -ErrorAction SilentlyContinue
    mkdir $testDataBasePath\2_STATICTOKEN -Force -ErrorAction SilentlyContinue
    mkdir "$testDataBasePath\3_[[`$DYNAMICTOKEN]]" -Force -ErrorAction SilentlyContinue
}

function Create-TestFiles {
    Get-ChildItem $testDataBasePath -Recurse -Directory | foreach {
        $dirName = Split-Path  $_.FullName -Leaf
        foreach($ext in $fileExtensions) {
            $newFile = Join-Path $_.FullName ("$dirName$ext")
            "Lorem ipsum $ext [[`$DYNAMICTOKEN]] STATICTOKEN" | Out-File -LiteralPath $newFile -Force
        }
    }
}

$setup = {
    $workingFile = "$PSScriptRoot\TestData\temp_template_properties.json"
    $configJson = Create-Config 
    $configJson | Out-File $workingFile -Force
        
    $config = $configJson | ConvertFrom-Json
    Create-TestFolders
    Create-TestFiles
        
    Import-TemplateConfiguration -Path $workingFile
    $replacements = Convert-ObjectToHashtable $config.RegExDynamicReplacements
    $totalReplacements = 0
}
