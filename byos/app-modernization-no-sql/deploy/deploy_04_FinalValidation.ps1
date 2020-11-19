#
# Final validation
#   Requires pre-defined variables $suffix
#

$webUrl = "https://openhackweb-" + $suffix + ".azurewebsites.net";

[Console]::WriteLine("Checking Website Availability")
$availabilityResult = Invoke-WebRequest $webUrl

if($availabilityResult.StatusCode -eq 200) {
    Write-Output ("Website is available")
}
else {
    Write-Output("Website availability check failed for team: " + $teamName)
}