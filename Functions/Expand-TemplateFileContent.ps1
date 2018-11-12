function Expand-TemplateFileContent {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(    [Parameter(Mandatory=$true)]
        #The base directory to start searching in
        [string[]]$SearchDirectory, 
        #If set, then template files are not deleted after the template file is expanded and written to a new file
        [switch]$DoNotDeleteTemplateFiles,
        #The file extension of files to treat as templates
        [string[]]$Extension = '.pstemplate',
        [string[]]$ExtensionsToStrip = '.pstemplate',
        #File patterns to exclude from template expansion operations
        [string[]]$ExcludeFiles,
        [scriptblock]$Transform = (Get-Item Function:\Expand-Template).ScriptBlock,
        [ref]$TotalExpansions
    )
    $totalExpansionCount = 0
    $dirsToRename = @{}
    Get-ChildItem -Path $SearchDirectory -Include ($Extension|% {"*$($_)"}) -Recurse |
        Where-Object { (Text-NotLikePatterns -Text $_.FullName -Patterns $ExcludeFiles)} | 
        Foreach-Object {
            #By default files will be overwritten
            $destination = $_.Fullname
            #If the current file should have its extension stripped, strip it
            if($ExtensionsToStrip -contains ([io.path]::GetExtension($_.FullName))) {
                $destination = Join-Path (Split-Path $_.FullName -Parent) ([io.path]::GetFileNameWithoutExtension($_.FullName)) 
            }
            
            $sourceDir = (Split-Path $destination -Parent)
            #Perform any replacements on the filename itself
            $pathExpansions = 0
            $destination = $destination | & $Transform -TotalExpansions ([ref]$pathExpansions)
            
            if($pathExpansions) {
                Write-Host "`tExpanded tokens in file path ($pathExpansions total expansions) $($_.FullName) to $destination"    
            }
            
            #Check if the destination directory has changed due to template replacements
            $destDir = (Split-Path $destination -Parent)
            if(-not (Test-Path $destDir)) {
                mkdir  $destDir -force
                
                $dirsToRename[$sourceDir] = $destDir
               
                
            }
    
            $contentExpansions = 0  
            if($PSCmdlet.ShouldProcess($_.FullName, "Expand template to $destination")) {
        
                & $Transform -Path $_.FullName  -Destination $destination -TotalExpansions ([ref]$contentExpansions)
                if(-not $contentExpansions) {
                    Write-Host "`tNo template expansions found in $($_.FullName)"   
                } else {
                    Write-Host "`tExpanded template ($contentExpansions total expansions) $($_.FullName) to $destination"        
                }
            }
            if(-not $DoNotDeleteTemplateFiles -and $_.FullName -notlike $destination -and (Test-Path -LiteralPath $_.FullName) -and $PSCmdlet.ShouldProcess($_.FullName, 'Delete template file')) {
                $null = Remove-ItemToTrash $_.FullName 
                Write-Host "`tDeleted template file $($_.FullName)"
            }
            if($TotalExpansions) {
                $TotalExpansions.Value += $contentExpansions + $pathExpansions
            }

        }
        
    #Remove dirs that have had name changes
    foreach($sourceDest in $dirsToRename.GetEnumerator()) {
        #Move all files
        $result = robocopy $sourceDest.Name $sourceDest.Value /MOV
        if($LASTEXITCODE -gt 7) {
            throw ("Failed to robo copy {0} to {1}`n " -f $sourceDest.Name ,$sourceDest.Value,$result)
        }
        
       $null = Remove-ItemToTrash $sourceDest.Name
    }
}



function Text-NotLikePatterns {
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$Text,
        [string[]]$Patterns
    
    )
    $val = $true
    $Patterns | Where-Object  { $Text -like $_} | % { $val = $false; }
    
    $val
}