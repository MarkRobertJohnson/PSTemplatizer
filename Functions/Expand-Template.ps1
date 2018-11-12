function Expand-Template {
    <# 
            .SYNOPSIS
            Expand-Template.ps1
            Simple templating engine to expand a given template text containing PowerShell expressions.

            .EXAMPLE
            $text="hello"; .\Expand-Template.ps1 -Text 'Hello [[$text]] world'
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$false, ParameterSetName='Text',ValueFromPipeline=$true)]
        #The text of the template to do the expansion
        [string]$Text,
        [Parameter(Mandatory=$true, ParameterSetName='Path')]
        #Path to template to do the expansion
        [string]$Path,
        #Destination path to write expansion result.  If not specified, write to output stream.
        [string]$Destination,
        #Path to file containing JSON template property values
        [string[]]$ConfigJsonPath,
        #Begin tag for detecting expand expression in template, default is '[['
        [string]$BeginTag = '[[',
        #End tag for detecting expand expression in template, default is ']]'
        [string]$EndTag = ']]',
        [ref]$TotalExpansions,
        [string]$ContentMatchRegEx = '.*?',
        [string]$ReplacementExpression
    )
    if($TotalExpansions) { $TotalExpansions.Value = 0 }
    $BeginTag = [RegEx]::Escape($BeginTag)
    $EndTag = [RegEx]::Escape($EndTag)
    $encoding = 'UTF8'
    
    
    Write-Verbose "Expand-Template: $Path"
    if ($Path) {
        if (!(Test-Path -LiteralPath $path )) { throw "Template-Expand: path `'$path`' can't be found"  }
        $Text = Get-Content -LiteralPath $path -Raw
        $encoding = Get-FileEncoding -Path $path
    } 

    if(-not $text) {
        Write-Verbose 'WARNING: No text to replace $Path'
        return;
    }

    #Load the configuration
    if ($ConfigJsonPath) {
        if (!(Test-Path -Path $ConfigJsonPath)) { throw "Replace-AllTemplateFiles: JSON configuration file(s) `'$ConfigJsonPath`' can't be found" }
        Write-Verbose "Loading JSON Configuration file: $ConfigJsonPath"
        Import-TemplateConfiguration -Path $ConfigJsonPath
    }
    if($TotalExpansions) {
        $global:expansionCount = $TotalExpansions.Value
    } else {
        $global:expansionCount = 0
    }
    
    $pattern = New-Object -Type System.Text.RegularExpressions.Regex `
                          -ArgumentList "$BeginTag($ContentMatchRegEx)$EndTag",([System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $matchEvaluatorDelegate =  [System.Text.RegularExpressions.MatchEvaluator] {
               param([System.Text.RegularExpressions.Match]$Match)
                $expression = $ReplacementExpression
                if(-not $expression) {
                    $expression = $match.get_Groups()[1].Value # content between markers
                }
           
               
               trap { Write-Error "Failed to expand template. Can't evaluate expression '$expression'. The following error occured: $_"; break }
               $global:expansionCount++
               $numReplaced = $global:expansionCount
               #Perform expansion on the values too
               $expression = $expression -replace '\\"','"'
               Write-Verbose "`texpanding expression: $expression"
               
               Invoke-Expression -command "Write-output ($expression)" | 
                    Expand-Template -TotalExpansions ([ref]$global:expansionCount) | 
                        Tee-Object -Variable result
                        
               Write-Verbose "`texpanded expression evaluated value:`n$result`n"
               
               $global:expansionCount += $numReplaced
               
        }

    $expandedText = $pattern.Replace($text, $matchEvaluatorDelegate)

    if (-not $destination){ $expandedText }
    elseif($expandedText -ne $text -or $Destination -notlike $path) { 
        $expandedText | Out-File -LiteralPath $destination -Encoding $encoding -Force -NoNewline
    }
    
    if($Destination -and -not (Test-Path $Destination)) {
        throw "Expected file $Destination to exist, but it does not"
    }
    

    if($TotalExpansions) { $TotalExpansions.Value += $global:expansionCount }
}