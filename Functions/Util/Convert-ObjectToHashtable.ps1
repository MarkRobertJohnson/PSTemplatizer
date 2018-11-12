function Convert-ObjectToHashtable {
    param([Parameter(Mandatory, ValueFromPipeline)]$Obj,
            [switch]$EvaluateValues)
    $values = [ordered]@{}
    $obj.PsObject.Properties | 
     foreach {
         $value = if($EvaluateValues) {(Invoke-Expression $obj."$($_.Name)")} else {$obj."$($_.Name)"} 
         if(-not ($value -is [string])) {
            $value = Convert-ObjectToHashtable -Obj $value -EvaluateValues:$EvaluateValues
         }
         $values += @{$_.name = $value }
     }
     
    return $values
}