function Convert-HashTableToObject {
    param(
    [Parameter(Mandatory,ValueFromPipeline)]
    [hashtable]$ht) 
    
    $ht | ConvertTo-Json | ConvertFrom-Json
}