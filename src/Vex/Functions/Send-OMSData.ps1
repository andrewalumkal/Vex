Function New-Signature () {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true)]
        $customerId,
        [Parameter(Mandatory = $true)]
        $sharedKey,
        [Parameter(Mandatory = $true)]
        $date,
        [Parameter(Mandatory = $true)]
        $contentLength,
        [Parameter(Mandatory = $true)]
        $method,
        [Parameter(Mandatory = $true)]
        $contentType,
        [Parameter(Mandatory = $true)]
        $resource
    )
    
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId, $encodedHash
    return $authorization
}

Function Send-OMSData {
    [cmdletbinding()]
    Param (
        [string] $customerId
        , [string] $sharedKey
        , [object] $body
        , [string] $logType
        , [string] $TimeStampField
    )

    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = New-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -method $method `
        -contentType $contentType `
        -resource $resource

    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization"        = $signature;
        "Log-Type"             = $logType;
        "x-ms-date"            = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing | Out-Null
    
}


