function Remove-ItemToTrash {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory)][string]$Path)

    
    $vbAsm = Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction SilentlyContinue -PassThru
    $canRecycle = $true
	try {
		$ioType = [Microsoft.VisualBasic.FileIO.FileSystem]
	} catch { Write-Warning "Type not found: Microsoft.VisualBasic.FileIO.FileSystem"}
	
    if(!$vbAsm -or !$ioType) {
        $canRecycle = $false
    }
    
    $item = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
    if ($item -eq $null)
    {
        Write-Error("'{0}' not found" -f $Path)
    }
    else
    {
        if($canRecycle) {
            Write-Verbose ("Moving '{0}' to the Recycle Bin" -f $Path)
            if (Test-Path -LiteralPath $Path -PathType Container)
            {
                [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($Path,'OnlyErrorDialogs','SendToRecycleBin')
            }
            else
            {
           
                [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($Path,'OnlyErrorDialogs','SendToRecycleBin')
            }
        } else {
            Write-Warning ("Unable to move {0} to Recycle bin because the Microsoft.VisualBasic assembly is not available." -f $Path)
            move -LiteralPath $Path $env:Temp -force
        }
    }
}