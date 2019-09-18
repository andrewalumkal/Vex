function Read-TestConfig () {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true)]
        $ConfigRepoPath
    )

    $ConfigPath = $ConfigRepoPath + "\TestConfig"
    Get-ChildItem -Recurse -Filter *.config.json -Path $ConfigPath | ForEach-Object {
		
        $TestJson = Get-Content -Path $_.FullName -Raw | ConvertFrom-Json
        $TestConfig += $TestJson.TestConfig

    }

    return $TestConfig

}