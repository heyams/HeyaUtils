# todo create a team service pricicle client id and key for authenticating "az login"

# install preview application insights Azure CLI commands if it's not available yet
az extension add -n application-insights

# use a new GUID to make resource group and iKey name unique
$NewGuid = New-GUID

# create a new resource group name "e2e-test-suite-$NewGuid"
$NewResourceGroup = az group create --name e2e-test-suite-$NewGuid --location westus
$RgResp = $NewResourceGroup | Out-String | ConvertFrom-Json
echo "created a new resource named $($RgResp.name)"
echo "the new resource group id=$($RgResp.id)"

# create a new iKey using the newly created resource group name
$CreateIkeyResp = az monitor app-insights component create --app e2e-test-suite-app-$NewGuid --location westus --kind web -g $RgResp.name --application-type web
$IkeyResp = $CreateIkeyResp | Out-String | ConvertFrom-Json
echo "created a new iKey with resourceId=$($IkeyResp.id)"
echo "the new iKey's appId=$($IkeyResp.appId)"
echo "the new iKey's connectionString=$($IkeyResp.connectionString)"
$ENV:APPLICATIONINSIGHTS_CONNECTION_STRING = $IkeyResp.connectionString
$env:APPLICATIONINSIGHTS_APP_ID = $IkeyResp.appId

# create an API key for $CreateIkeyResp.id
$CreateApiKey = az monitor app-insights api-key create --api-key e2e-test-suite --read-properties ReadTelemetry -g $RgResp.name --app $IkeyResp.name
$ApiKeyResp = $CreateApiKey | Out-String | ConvertFrom-Json
# save $ApiKeyResp.apiKey as an env var
$env:APPLICATIONINSIGHTS_API_KEY = $ApiKeyResp.apiKey

# todo trigger test apps here

# once the test is done, clean up all the azure resources created earlier.

# delete iKey
Remove-AzResource -ResourceId $IkeyResp.id -Force

# delete the resource group
Remove-AzResource -ResourceId $RgResp.id -Force

