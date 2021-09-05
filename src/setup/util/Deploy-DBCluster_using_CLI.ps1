
param
(

	[Parameter(Position = 0, Mandatory = $True,  HelpMessage = "Specify the ResourceGroupName.")]	
	[String] $ResourceGroupName,
	[Parameter(Position = 1, Mandatory = $True,  HelpMessage = "Specify the Location.")]	
	[String] $Location,
	[Parameter(Position = 2, Mandatory = $True, HelpMessage = "Specify the BearerToken.")]	
	[String] $BearerToken # TODO: This should come from DevOps task
)

#$Environment       = "Dev"
#$ResourceGroupName = "RS-DEV-WE-03"
#$Location          = "westeurope"
#$BearerToken       = "d"

#$psISE.CurrentFile.FullPath

# This switch needs to be enabled to print verbose messages
$VerbosePreference = 'Continue'  

Write-Verbose     "PSScriptRoot is: $PSScriptRoot"
$ScriptFolderPath = (Get-Item -Path $PSScriptRoot).FullName
Write-Verbose     "parameter file path: $ScriptFolderPath"

$clusterFilePath  = "$ScriptFolderPath\DBCluster-Configuration.json"
$clusterId        = $null

# Install Libraries
python -m pip install --upgrade pip
#python -m pip install wheel
#python -m pip install setuptools
python -m pip install databricks-cli

#Removing the space from the Location is there is any

$Location = $Location.replace(' ','')
# Login to databricks
@"
https://$Location.azuredatabricks.net
$BearerToken
"@ | databricks configure --token

# Create Interactive clusters
# Check if the cluster exist
$clusterName = (Get-Content -Path $clusterFilePath | ConvertFrom-Json).cluster_name
$clusters    = (databricks clusters list --output="JSON" | ConvertFrom-Json).clusters | Where-Object { $_.cluster_name -eq $clusterName }

if ($null -ne $clusters) 
{
    $clusterId = $clusters.cluster_id
}
if($clusterid -ne $null){
Write-Verbose $clusterId
}

if ($clusterId) 
{
    Write-Verbose "Cluster already exist with ID $clusterId"
    if ((databricks clusters get --cluster-id $clusterId | ConvertFrom-Json).state -ne "RUNNING") 
	{
        Write-Verbose "Cluster state is terminated starting cluster: $clusterId"
        databricks clusters start --cluster-id $clusterId

		# Start the cluster and poll until its state changes to Running
        while ((databricks clusters get --cluster-id $clusterId | ConvertFrom-Json).state -eq "PENDING") 
		{
            Write-Verbose "Waiting for Databrick cluster id $($clusterId) to get started, sleep for 30 seconds"
            Start-Sleep -Seconds 30
        }

        if ((databricks clusters get --cluster-id $clusterId | ConvertFrom-Json).state -eq "RUNNING") 
		{
            Write-Verbose "Databrick cluster id $($clusterId) is now running"
        }
        else 
		{
            Write-Verbose "Databrick cluster id $($clusterId) creation failed. exiting script"
            exit
        }
    }
}
else 
{
    #Create a fixed node cluster
    $clusterId = (databricks clusters create --json-file $clusterFilePath | ConvertFrom-Json).cluster_id
    if($clusterid -ne $null){
		Write-Verbose "cluster id $clusterId"
	}

    while ((databricks clusters get --cluster-id $clusterId | ConvertFrom-Json).state -eq "PENDING") 
	{
        Write-Verbose "Waiting for Databrick cluster id $($clusterId) to created, sleep for 30 seconds"
        Start-Sleep -Seconds 30
    }

    if ((databricks clusters get --cluster-id $clusterId | ConvertFrom-Json).state -eq "RUNNING") 
	{
        Write-Verbose "Databrick cluster id $($clusterId) is now running"
    }
    else 
	{
        Write-Verbose "Databrick cluster id $($clusterId) creation failed. exiting script"
        exit
    }

}
return $clusterId
