Function Save-PesterResults () {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true)]
        $PesterResultObject,

        [Parameter(Mandatory = $true)]
        [ValidateSet('OMS', 'Database')]
        $OutputTarget,

        [Parameter(Mandatory = $true)]
        $TargetCredential
    )

    $LogType = "VexTest"
    $TimeStampField = "InvocationStartTime"

    try {

        if ($OutputTarget -eq "OMS") {

            Write-Verbose "Exporting $($PesterResultObject.Count) results"
            $resultJson = ConvertTo-Json $PesterResultObject

            Push-OMS -json $resultJson -TargetCredential $TargetCredential -LogType $LogType -TimeStampField $TimeStampField
            Write-Verbose "Sent results to OMS"
    
        }

        elseif ($OutputTarget -eq "Database") {
            Write-Verbose "Push to OutputTarget:$OutputTarget not supported at this time"
        }

        else {
            return
        }

    }

    catch {
        Write-Host "Export to OutputTarget:$OutputTarget failed" -ForegroundColor Red
        Write-Host "Error Message: $_.Exception.Message" -ForegroundColor Red
        continue
    }

}