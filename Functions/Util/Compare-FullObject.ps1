function Compare-FullObject {
    param([object]$ReferenceObject,
            [object]$DifferenceObject)

    $properties = $ReferenceObject | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
    $properties += $DifferenceObject | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
    $properties = $properties | Sort-Object -Unique

    foreach($property in $properties) {
        Compare-Object -ReferenceObject $ReferenceObject -DifferenceObject $DifferenceObject -Property $property
    }
}