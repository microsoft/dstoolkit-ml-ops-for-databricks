
param
(

	[Parameter(Position = 0, Mandatory = $True,  HelpMessage = "Specify the ResourceGroupName.")]	
	[String] $ResourceGroupName,
	[Parameter(Position = 1, Mandatory = $True,  HelpMessage = "Specify the Location.")]	
	[String] $Location,
	[Parameter(Position = 2, Mandatory = $True, HelpMessage = "Specify the BearerToken.")]	
	[String] $BearerToken # TODO: This should come from DevOps task
)

$VerbosePreference = 'Continue'  

Write-Verbose     "PSScriptRoot is: $PSScriptRoot"
$ScriptFolderPath = (Get-Item -Path $PSScriptRoot).FullName
Write-Verbose     "parameter file path: $ScriptFolderPath"

$clusterFilePath  = "$ScriptFolderPath\DBCluster-Configuration.json"

$clusterId        = $null
$clusterName = (Get-Content -Path $clusterFilePath | ConvertFrom-Json).cluster_name
$clusterDefintion = Get-Content -Path $clusterFilePath

$resourceGroupLocation = $Location.replace(' ','')
$DBAPIRootUrl = "https://"+$resourceGroupLocation+".azuredatabricks.net"
$DBAPIKey = $BearerToken
 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
 
$ClustersAPIListUrl = $DBAPIRootUrl.Trim('/') + "/api/2.0/clusters/list"
 
$headers = @{
  Authorization = "Bearer $DBAPIKey"
  "Content-Type" = "application/json"
}
 
$Path= "/"
$parameters = @{
  path = $Path
}
 
$response = Invoke-WebRequest -Uri $ClustersAPIListUrl -Method GET -Headers $headers -Body $parameters

$responseObj = $response.Content | ConvertFrom-Json
$clusterid = ""
foreach ( $c in $responseObj.clusters){
    if($c.cluster_name -eq $clusterName){
        $clusterid = $c.cluster_id        
    }
}
if($clusterid){
    Write-Host "The cluster is already present"
}
else{
    Write-Host "new cluster to be created"

    $ClustersAPIListUrl = $DBAPIRootUrl.Trim('/') + "/api/2.0/clusters/create"
 
    $headers = @{
      Authorization = "Bearer $DBAPIKey"
      "Content-Type" = "application/json"
    }
 
    $Path= "/"
    $parameters = @{
      path = $Path
    }
 
    $response = Invoke-WebRequest -Uri $ClustersAPIListUrl -Method POST -Headers $headers -Body $clusterDefintion
    $clusterid = ($response.Content|ConvertFrom-Json).cluster_id
}
return $clusterid