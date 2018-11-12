function Replace-RegExDynamicContent {
    [Cmdletbinding()]
    param(
        
        [Parameter(Mandatory=$true)][hashtable]$Replacements,
        [Parameter(Mandatory=$true, ParameterSetName='Text',ValueFromPipeline=$true)]
        #The text of the template to do the expansion
        [string]$Text,
        [Parameter(Mandatory=$true, ParameterSetName='Path')]
        #Path to template to do the expansion
        [string]$Path,
        #Destination path to write expansion result.  If not specified, write to output stream.
        [string]$Destination,
        [ref]$TotalExpansions
    )
    
    $encoding = 'UTF8'
    
    if ($Path) {
        if (!(Test-Path -LiteralPath $path )) { throw "Template-Expand: path `'$path`' can't be found"  }
        $Text = Get-Content -LiteralPath $path -Raw
        $encoding = Get-FileEncoding -Path $path
    }

    $origText = $Text
    foreach($Replacement in $Replacements.GetEnumerator()) {
        $expansions = 0 
        $Text = Expand-Template -Text $Text -BeginTag '' -EndTag '' -ContentMatchRegEx $Replacement.Name -ReplacementExpression $Replacement.Value -TotalExpansions ([ref]$expansions) 
        if($totalExpansions) {
            $totalExpansions.Value += $expansions
        }        
    }
    if(-not $destination) {
        Write-Output $Text
    } 
    elseif($Text -ne $origText -or $Destination -notlike $Path) {
        $text | Out-File -LiteralPath $destination -Encoding $encoding -Force -NoNewline
    }
    
    if($Destination -and -not (Test-Path $Destination)) {
        throw "Expected file $Destination to exist, but it does not"
    }
    
}
