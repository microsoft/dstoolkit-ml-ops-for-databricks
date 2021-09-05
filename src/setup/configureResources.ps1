<#
Prereqisite :

Service Principal must be granted subscription contributor permission

1. setup_config.json should be filled with the proper details. ( already done during the first script execution )
2. appsecret.txt should be having the client secret of the service principal. ( already done during the first script execution )
3..\vault\DBKtoken.txt file should be filled with the Databricks Personal Access token.
3. change the directory path in the command line to the project file path.
cd C:\Users\......\MLOpsBasic-Databricks\src\setup


Post Execution Step
=================================
1. create .env file in root with the details from the output of the execution

PYTHONPATH=/workspaces/MLOpsBasic-Databricks/src/modules
APPI_IK="7936932708497696"
DATABRICKS_HOST=https://adb-dapi398220b1d763f6cf6e94657b066e49b7-2.XX.azuredatabricks.net/
DATABRICKS_TOKEN=7936932708497696
DATABRICKS_ORDGID=53d00092-2e8c-496b-9634-ae6a9658c775

2. DATABRICKS_HOST=https://adb-dapi398220b1d763f6cf6e94657b066e49b7-2.XX.azuredatabricks.net/ ==> change the "XX" with the correct version from the databricks workspace URL.

#>

Write-Verbose     "PSScriptRoot is: $PSScriptRoot"
$rootPath = (Get-Item -Path $PSScriptRoot).FullName
Write-Verbose     "config file path: $rootPath\config\setup_config.json"
$config = Get-Content -Raw -Path "$rootPath\config\setup_config.json" | ConvertFrom-Json


# $rootPath = $config.rootDirectoryPath
# cd $rootpath

$applicationID=$config.applicationID
$appsecret = Get-Content -Path "$rootPath\vault\appsecret.txt"
$tenantId =$config.tenantID
$subscriptionID = $config.subscriptionID
$resourceGroupname = $config.resourceGroupName
$resourceGroupLocation = $config.resourceGroupLocation


$dbktoken = Get-Content -Path "$rootPath\vault\DBKtoken.txt"

# DBK Cluster Creation
cd $rootPath
cd util
$returnResult = .\Deploy-DBCluster.ps1 -ResourceGroupName $resourceGroupname -Location $resourceGroupLocation -BearerToken $dbktoken -Verbose 
$clusterID  = $returnResult | select -Last 1

cd..
# Login to databricks
$resourceGroupLocation = $resourceGroupLocation.replace(' ','')


$DBAPIRootUrl = "https://"+$resourceGroupLocation+".azuredatabricks.net"
$DBAPIKey = $dbktoken
 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
 
$ClustersAPIListUrl = $DBAPIRootUrl.Trim('/') + "/api/2.0/workspace/list"
 
$headers = @{
  Authorization = "Bearer $DBAPIKey"
  "Content-Type" = "application/json"
}
 
$Path= "/"
$parameters = @{
  path = $Path
}
 
$response = Invoke-WebRequest -Uri $ClustersAPIListUrl -Method GET -Headers $headers -Body $parameters
$orgID = $response.Headers.'X-Databricks-Org-Id'

$appInsightName = ((Get-AzApplicationInsights -ResourceGroupName $resourceGroupname)  | Where-Object {$_.Name -eq $resourceGroupname+"-ai"})
$instrumentationKey = $appInsightName.InstrumentationKey


$output = 'PYTHONPATH=/workspaces/MLOpsBasic-Databricks/src/modules
APPI_IK={0}
DATABRICKS_HOST=https://adb-{1}.XX.azuredatabricks.net/
DATABRICKS_TOKEN={2}
DATABRICKS_ORDGID={3}' -f $instrumentationKey, $orgID,$dbktoken,$orgID

Write-Host $output
