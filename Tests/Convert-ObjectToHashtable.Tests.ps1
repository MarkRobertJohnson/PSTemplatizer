gci "$PSScriptRoot\..\*.psm1" | Import-Module  -force


Describe 'Convert-ObjectToHashtable' {
    Context 'when converting a JSON file to a hashtable' {

        $obj = Get-Content "$PSScriptRoot\TestData\template_properties.json" | ConvertFrom-Json
        
        $result = Convert-ObjectToHashtable $obj
        $resultObj = Convert-HashTableToObject $result

        It 'has all of the same values as the orginal JSON file' {       
            Compare-FullObject -referenceObject $resultObj -differenceObject $obj | Should BeNullOrempty 
        }
        
        It 'had the same order as the input object' {
            $propNames = $obj.psobject.properties.name
            $hashKeys = $result.GetEnumerator().Name
            for($i = 0; $i -lt $propNames.Count;$i++) {
                $propNames[$i] | Should Match $hashKeys[$i]
            }
            
            for($i = 0; $i -lt $hashKeys.Count;$i++) {
                $hashKeys[$i] | Should Match $propNames[$i]
            }   
            
        }
    }
}

