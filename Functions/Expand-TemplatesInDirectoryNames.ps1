function Expand-TemplatesInDirectoryNames {
    [CmdletBinding()]
    param([string[]]$SearchDirectory,
        [hashtable]$StaticReplacements,
        [ref]$TotalReplacements)
    
    $replacements = 0
    Get-ChildItem -Path $SearchDirectory -Recurse -Directory | foreach { 
        $expandedPath = $_.FullName | Expand-Template -TotalExpansions ([ref]$replacements)
        
        if($StaticReplacements) {
             $expandedPath = $expandedPath | foreach { 
                        $expansions = 0
                        $_| Replace-RegExDynamicContent -Replacements $StaticReplacements -TotalExpansions ([ref]$expansions) 
                        $replacements += $expansions
            }   
        }

        if($TotalReplacements) { $TotalReplacements.Value += $replacements}
        if($expandedPath -notlike $_.FullName -and (-not (Test-path $expandedPath -PathType Container))) {
            Move-Item  -LiteralPath $_.FullName -Destination $expandedPath  -Force
        }
    }   
}