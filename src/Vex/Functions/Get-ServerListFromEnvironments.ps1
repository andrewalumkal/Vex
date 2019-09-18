function Get-ServerListFromEnvironments () {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true)]
        $EnvironmentList,
		
        [Parameter(Mandatory = $true)]
        $ConfigRepoPath
    )

    $EnvConfigPath = $ConfigRepoPath + "\EnvironmentConfig\Environment.json"
    $EnvJson = Get-Content -Path $EnvConfigPath -Raw | ConvertFrom-Json
    $EnvConfig = $EnvJson.EnvironmentList

    $EnvResult = $EnvConfig | Where-Object { $EnvironmentList -contains $_.EnvironmentName }

    $ServerList = @()

    foreach ($env in $EnvResult) {

        $ServerList += $env.Servers

    }

    return $ServerList | Sort-Object | Get-Unique

}