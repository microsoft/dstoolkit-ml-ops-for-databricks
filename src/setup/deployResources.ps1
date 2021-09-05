<#
Prereqisite :
Service Principal must be granted subscription contributor permission

1. setup_config.json should be filled with the proper details. 
2. .\vault\appsecret.txt should be having the client secret of the service principal
3. change the directory path in the command line to the project file path.
cd C:\Users\......\MLOpsBasic-Databricks\src\setup
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

#Install Modules. 

if (!(Get-Module -Name "Az.Accounts" -ListAvailable)){
    Install-Module -Name "Az.Accounts"
    Import-Module -Name "Az.Accounts"

}

if (!(Get-Module -Name "Az.ApplicationInsights" -ListAvailable)){
    Install-Module -Name "Az.ApplicationInsights"
    Import-Module -Name "Az.ApplicationInsights"

}


if (!(Get-Module -Name "Az.Databricks" -ListAvailable)){
    Install-Module -Name "Az.Databricks"
    Import-Module -Name "Az.Databricks"

}

$PWord= ConvertTo-SecureString -String  $appsecret -AsPlainText -Force
$Credential1 = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $applicationID, $PWord
$info= Connect-AzAccount -ServicePrincipal -Credential $Credential1 -TenantId $tenantid -Subscription $subscriptionID

# Create the Resource Group
if (!( Get-AzResourceGroup -Name $resourceGroupname -ErrorVariable notPresent -ErrorAction SilentlyContinue )){
New-AzResourceGroup -Location $resourceGroupLocation -Name $resourceGroupname
}

# Task 1: Deploy the Resource Group
$templatefileLocation = $rootPath + "\arm-templates\template.json"

# Task 2: Deploy the Resource
$deploymentDetails = New-AzDeployment -Name "DBKadnResourceCreation"   `
-Location $resourceGroupLocation -resource_group $resourceGroupname `
-TemplateFile $templatefileLocation `
-locationFromTemplate $resourceGroupLocation

$deploymentDetails

# if ($deploymentDetails.ProvisioningState -eq "Succeeded"){
#     $dbkName = (Get-AzDatabricksWorkspace  -ResourceGroupName "AccleratorDBKMLOps1").Name
#     $appInsightName = (Get-AzApplicationInsights -ResourceGroupName "AccleratorDBKMLOps1")    
#     }

