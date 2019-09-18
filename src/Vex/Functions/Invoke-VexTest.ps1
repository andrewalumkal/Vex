Function Invoke-VexTest () {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true)]
        $ConfigRepoPath,

        [Parameter(Mandatory = $false)]
        [ValidateSet('All', 'Schedule', 'TestList')]
        $RunType = 'All',

        [Parameter(Mandatory = $false)]
        $RunTypeParams,

        [Parameter(Mandatory = $false)]
        [ValidateSet('OMS', 'Database', 'None')]
        $OutputTarget = "None",

        [Parameter(Mandatory = $false)]
        [ValidateSet('All', 'None', 'Summary', 'Failed')]
        $Show = "Summary"
    )

    if ($RunType -ne "All" -and [string]::IsNullOrWhiteSpace($RunTypeParams)) {
        Write-Host "Please supply RunTypeParams"
        return
    }

    Write-Verbose "Output Target: $OutputTarget"
    $BatchId = [System.Guid]::NewGuid()
    $PathToTests = $ConfigRepoPath + "\Tests\"
    $Schedule = ""
    $AllTestObjects = Read-TestConfig -ConfigRepoPath $ConfigRepoPath

    if ($RunType -eq "Schedule") {
        $Schedule = $RunTypeParams
    }
    
    #Get all tests from Tests subfolders
    $TestsInAllFolders = Get-ChildItem -Recurse -Filter *.ps1 -Path $PathToTests -Name 

    #Tests are only valid if they are present in TestConfig and in the Tests folder
    $ValidTests = $AllTestObjects.TestFile | Where-Object { $TestsInAllFolders -contains $_ }


    if ($RunType -eq "Schedule") {
        Write-Verbose "ConfigRepoPath: $ConfigRepoPath"
        Write-Verbose "RunType: $RunType"
        Write-Verbose "Schedule: $RunTypeParams"

        #Get all test objects for specific schedule
        $TestObjects = $AllTestObjects | Where-Object { $_.Schedule -contains $RunTypeParams }
    }

    elseif ($RunType -eq "TestList") {
        
        Write-Verbose "ConfigRepoPath: $ConfigRepoPath"
        Write-Verbose "RunType: $RunType"
        Write-Verbose "TestList: $RunTypeParams"

        #Get all test objects for test list
        $TestObjects = $AllTestObjects | Where-Object { $RunTypeParams -contains $_.TestFile }
    }

    else {
        ## run all tests
        Write-Verbose "Running all tests"
        $TestObjects = $AllTestObjects
    }


    foreach ($Test in $TestObjects) {

        $TestName = $Test.TestFile

        if ($ValidTests -contains $TestName) {
        
            $TestPath = ""
            $TestPath = $PathToTests + $TestName

            $Servers = Get-ServerListFromEnvironments -ConfigRepoPath $ConfigRepoPath -EnvironmentList $Test.EnvironmentsToTest
            $Operator = $Test.AlertOperator
            $TestOwner = $TestName.Split("\\")[0]
                
            $invocationStartTime = [DateTime]::UtcNow

            #Run Test
            Write-Output "Running test ($TestName) on environments ($($Test.EnvironmentsToTest))"
            $results = Invoke-Pester -Script @{Path = $TestPath; Parameters = @{ServersToTest = $Servers } } -PassThru -Show $Show
                
            $invocationEndTime = [DateTime]::UtcNow


            if ($results.TestResult.Count -gt 0) {

                $pesterResults = @()

                foreach ($testResult in $results.TestResult) {
                    $pesterResults += [PSCustomObject]@{
                        BatchId             = $BatchID
                        InvocationId        = [System.Guid]::NewGuid()
                        InvocationStartTime = $invocationStartTime.ToString("yyyy-mm-dd hh:mm:ss:ff")
                        InvocationEndTime   = $invocationEndTime.ToString("yyyy-mm-dd hh:mm:ss:ff")
                        HostComputer        = $env:computername   
                        TestFile            = $TestName                           
                        TimeTaken           = $testResult.Time.TotalMilliseconds
                        Passed              = $testResult.Passed
                        Describe            = $testResult.Describe
                        Context             = $testResult.Context
                        Name                = $testResult.Name
                        FailureMessage      = $testResult.FailureMessage
                        Result              = $testResult.Result
                        Identifier          = $LogType
                        Schedule            = $Schedule
                        AlertOperator       = $Operator
                        TestOwner           = $TestOwner
                    }

                }

                if ($OutputTarget -eq "None") {
                    Write-Verbose "Test output not saved"
                }


                else {
                    Save-PesterResults -PesterResultObject $pesterResults -OutputTarget $OutputTarget -ConfigRepoPath $ConfigRepoPath
                }

            }

        }

    }
}