function Push-OMS {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true)]
        $json,

        [Parameter(Mandatory = $true)]
        $ConfigRepoPath,

        [Parameter(Mandatory = $true)]
        $LogType,

        [Parameter(Mandatory = $true)]
        $TimeStampField
	

    )
    
    $OMSPath = $ConfigRepoPath + "\OMSWorkspaceConfig\OMSWorkspace.json"
    $credentialConfig = Get-Content -Raw -Path $OMSPath | ConvertFrom-Json
	
    # Assign Workspace ID
    $WorkspaceId = $credentialConfig.WorkspaceId 

    # Assign Primary Key
    $SharedKey = $credentialConfig.SharedKey

    #Send Data
    Send-OMSData -customerId $WorkspaceId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType -TimeStampField $TimeStampField

}