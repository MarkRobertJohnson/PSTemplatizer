gci "$PSScriptRoot\..\*.psm1" | Import-Module  -force

# describes the function Remove-ItemToTrash
Describe 'Remove-ItemToTrash' {

    # scenario 1: call the function without arguments
    Context 'Running without arguments'   {
        $testbasePath = $TestDrive
        # test 1: it does not throw an exception:
        It 'runs without errors' {
            'test' > $testBasePath\test.txt
            { Remove-ItemToTrash -Path $testBasePath\test.txt } | Should Not Throw
        }
        It 'delete a file to the trash' {
            'test' > $testBasePath\test.txt
            Remove-ItemToTrash -Path $testBasePath\test.txt
            "$testBasePath\test.txt" | Should Not Exist
        }
        # test 2: it returns nothing ($null):
        It 'does not return anything'     {
            'test' > $testBasePath\test.txt
            Remove-ItemToTrash -Path $testBasePath\test.txt | Should BeNullOrEmpty 
        }
    }
}
