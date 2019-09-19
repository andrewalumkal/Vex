function Push-OMS {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true)]
        $json,

        [Parameter(Mandatory = $true)]
        $TargetCredential,

        [Parameter(Mandatory = $true)]
        $LogType,

        [Parameter(Mandatory = $true)]
        $TimeStampField
	

    )
    
    # Assign Workspace ID
    $WorkspaceId = $TargetCredential.CredentialID 

    # Assign Primary Key
    $SharedKey = $TargetCredential.CredentialSecret

    #Send Data
    Send-OMSData -customerId $WorkspaceId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType -TimeStampField $TimeStampField

}