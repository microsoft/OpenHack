param (
    [string]$storageAccountName,
    [string]$storageContainerName,
    [string]$catalogJsonFileName,
    [string]$containerSAS
)

function GetKey([System.String]$Verb = '', [System.String]$ResourceId = '',
            [System.String]$ResourceType = '',[System.String]$Date = '',[System.String]$masterKey = '') {

    $keyBytes = [System.Convert]::FromBase64String($masterKey) 
    $text = @($Verb.ToLowerInvariant() + "`n" + $ResourceType.ToLowerInvariant() + "`n" + $ResourceId + "`n" + $Date.ToLowerInvariant() + "`n" + "" + "`n")
    $body =[Text.Encoding]::UTF8.GetBytes($text)
    $hmacsha = new-object -TypeName System.Security.Cryptography.HMACSHA256 -ArgumentList (,$keyBytes) 
    $hash = $hmacsha.ComputeHash($body)
    $signature = [System.Convert]::ToBase64String($hash)

    [System.Web.HttpUtility]::UrlEncode($('type=master&ver=1.0&sig=' + $signature))
}

function GetUTDate() {
    $date = get-date
    $date = $date.ToUniversalTime();
    return $date.ToString("ddd, dd MMM yyyy HH:mm:ss \G\M\T")
}

function BuildHeaders([string]$action = "get", [string]$resType, [string]$resourceId){
    $authz = GetKey -Verb $action -ResourceType $resType -ResourceId $resourceId -Date $apiDate -masterKey $connectionKey
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", $authz)
    $headers.Add("x-ms-version", '2015-12-16')
    $headers.Add("x-ms-date", $apiDate) 
    $headers
}

function GetDatabases() {
    $uri = $rootUri + "/dbs"

    $hdr = BuildHeaders -resType dbs

    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $hdr
    $response.Databases

    Write-Host ("Found " + $Response.Databases.Count + " Database(s)")
}

function GetCollections([string]$DBName) {
    $uri = $rootUri + "/dbs/" + $DBName + "/colls"

    $hdr = BuildHeaders -resType colls -resourceId "dbs/$DBName"

    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $hdr
    $response
}

function CreateDatabase([string]$DBName) {
    $uri = $rootUri + "/dbs"

    $hdr = BuildHeaders -resType dbs -action post

    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $hdr -Body "{""id"": ""$DBName""}"
    $response
}

function CreateCollection([string]$DBName, [string]$CollectionName, [string]$PartitionKey) {
    $uri = $rootUri + "/dbs/" + $DBName + "/colls"

    $hdr = BuildHeaders -resType colls -action post -resourceId "dbs/$DBName"
    $hdr.Add("x-ms-offer-throughput", "1000")

    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $hdr -Body "{""id"": ""$CollectionName"", ""partitionKey"": $PartitionKey }"
    $response
}

function CreateDocument([string]$DBName, [string]$CollectionName, $Document) {
    $uri = $rootUri + "/dbs/" + $DBName + "/colls/" + $CollectionName + "/docs"

    $hdr = BuildHeaders -resType docs -action post -resourceId "dbs/$DBName/colls/$CollectionName"
    $hdr.Add("x-ms-documentdb-partitionkey", "[""$($Document.genre)""]")

    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $hdr -Body "$($Document | ConvertTo-JSON)"
    $response
}

# It is the responsibility of the caller to ensure that AzCopy.exe is on path
AzCopy.exe cp "https://$storageAccountName.blob.core.windows.net/$storageContainerName/$($catalogJsonFileName)?$containerSAS" ".\$catalogJsonFileName"

Connect-AzureRmAccount -MSI

$cosmos = Get-AzureRmResource | Where-Object { $_.ResourceType -ieq "Microsoft.DocumentDB/databaseAccounts" }
$rootUri = "https://" + $cosmos.Name + ".documents.azure.com"
$resourceGroupName = $cosmos.ResourceGroupName

$apiDate = GetUTDate

$keys = Invoke-AzureRmResourceAction -Action listKeys `
    -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
    -ApiVersion "2015-04-08" `
    -ResourceGroupName $resourceGroupName `
    -Name $cosmos.Name -Force

$connectionKey = $keys.primaryMasterKey

CreateDatabase -DBName southridge
CreateCollection -DBName southridge -CollectionName movies -PartitionKey "{""paths"":[""/genre""], ""kind"":""Hash""}"

$movies = Get-Content .\$catalogJsonFileName | ConvertFrom-JSON
foreach($movie in $movies)
{
    CreateDocument -DBName southridge -CollectionName movies -Document $movie
}

Remove-Item $catalogJsonFileName