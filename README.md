![Banner](docs/images/MLOps_for_databricks_Solution_Acclerator_logo.JPG)

About this repository
============================================================================================================================================
This repository contains the Databricks development framework for delivering any Data Engineering projects, and machine learning projects based on the Azure Technologies. 


Details of the accelerator
============================================================================================================================

The accelerator contains few of the core features of Databricks development which can be extended or reused in any implementation projects with Databricks. 

- Logging Framework using the [Opensensus Azure Monitor Exporters](https://github.com/census-instrumentation/opencensus-python/tree/master/contrib/opencensus-ext-azure)
- Support for Databricks development from VS Code IDE using the [Databricks Connect](https://docs.microsoft.com/en-us/azure/databricks/dev-tools/databricks-connect#visual-studio-code) feature.
- continuous development with [Python Local Packaging](https://packaging.python.org/tutorials/packaging-projects/)
- Implementation of the Databricks utilities in VS Code such as dbutils, notebook execution, secret handling. 
- Example Model file which uses the framework end to end.

Prerequisites
============================================================================================================================

To successfully complete your solution, you will need to have access to and or provisioned the following:

-   Access to an Azure subscription
-   Service Principal (valid Client ID and secret ) which has the contributor permission the subscription. We are going to create the resource group using the service principal.
-   VS Code installed. 
-   Docker Desktop Installed.


Getting Started
================================================================================================================================

The below sections provide the step by step approach to set up the solution. As part of this solution, we need the following resources to be provisioned in a resource group. 

1. Azure Databricks
2. Application Insight Instance.
3. A log analytics workspace for the App Insight.
4. Azure Key Vault to store the secrets.
5. A Storage Account. 


## Section 1: Docker Image Load in VS Code

1.	Clone the Repository : https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/pulls
2.	Install Docker Desktop. In this solution, the Visual Code uses the docker image as a remote container to run the solution.
3.	Create .env file in the root folder, and keep the file blank for now. (root foolder is the parent folder of the project)
4.	In the repo, open the workspace. File: workspace.ode-workspace. 
    > Once you click the file, you will get the "Open Workspace" button at right bottom corner in the code editor. Click it to open the solution into the vscode workspace.

<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/workspaceselection.jpg">
</p>


5. We need to connect to the [docker image as remote container in vs code](https://code.visualstudio.com/docs/remote/attach-container#_attach-to-a-docker-container). In the code repository, we have ./.devcontainer folder that has required docker image file and docker configuration file. Once we load the repo in the vscode, we generally get the prompt. Select "Reopen in Container". Otherwise we can go to the VS code command palette ( ctrl+shift+P in windows), and select the option "Remote-Containers: Rebuild and Reopen in Containers"

<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/DockerImageLoad.jpg">
</p>

6. In the background, it is going to build a docker image. We need to wait for sometime to complete build. the docker image will basically contain the a linux environment which has python 3.7 installed. Please have a look at the configuration file(.devcontainer\devcontainer.json) for more details. 
7. Once it is loaded. we will be able to see the python interpreter is loaded successfully. Incase it does not show, we need to load the interpreter manually. To do that, click on the select python interpreter => Entire workspace => /usr/local/bin/python


<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/pythonversion.jpg">
</p>


8.	You will be prompted with installing the required extension on the right bottom corner. Install the extensions by clicking on the prompts.

<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/InstallExtensions.jpg">
</p>


9.	Once the steps are completed, you should be able to see the python extensions as below:

<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/pythonversion.jpg">
</p>


## Section 2: Data bricks Environment creation

The objectives of this section are:

- Create the required resources.
    1. Azure Databricks
    2. Application Insight Instance.
    3. A log analytics workspace for the App Insight.
    4. Azure Key Vault to store the secrets.
    5. A Storage Account. 

- Create the .env file for the local development. 

> You don't need to create the environment again if you already had a databricks environment. You can directly create the .env file ( Section 4 ) with the details of your environment. 

 
1. Go to **src/setup/config/setup_config.json**, and complete the json files with the values; according to your environment. The service principal should be having the contributor access over the subscription you are using. Or if you choose to create the resource group manually, or reuse an existing resource group, then it should have the contributor access on the resource group itself.

> These details would be used to connect to the Azure Subscription for the resource creation.
```
{
 
    "applicationID":"deeadfb5-27xxxaad3-9fd39049b450",
    "tenantID":"72f988bf-8xxxxx2d7cd011db47",
    "subscriptionID":"89c37dd8xxxx-1cfb98c0262e",
    "resourceGroupName":"AccleratorDBKMLOps2",
    "resourceGroupLocation":"NorthEurope"
}
```
 
2. create the file and provide the client ID secret in this file : **src/setup/vault/appsecret.txt**      
> Incase you are not able to create the file from the solution, you can directly go to the file explorer to create the file.

> NOTE: DBSecret.txt will be created in the later section, please ignore it for now. 

At the end of the secret files creation, the folder structure will like below:

<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/SecretsFileImage.jpg">
</p>


3. Open the Powershell ISE in your local machine. We are going to run the Powershell script to create the required resources. The name of the resources are basically having a prefix to the resourcegroup name.
4.set the root path of the Powershell terminal till setup, and execute the deployResource.ps1
 ```
cd "C:\Users\projects\New folder\MLOpsBasic-Databricks\src\setup"
.\deployResources.ps1
 ```
> If you receive the below error, execute the  command [
Set-ExecutionPolicy RemoteSigned]

 ```>.\deployResources.ps1 : File C:\Users\projects\New 
folder\MLOpsBasic-Databricks\src\setup\deployResources.ps1 cannot be loaded because running scripts is disabled on this.
```

<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/PowershellScreen.jpg">
</p>


## Section 3: Databricks Cluster Creation

1.	To create the databricks cluster we need to have personal Access token created. Go to the Databricks workspace, and get the personal access token from the user setting, and save it in the file src/setup/vault/DBKtoken.txt


<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/DatabricksTokenGeneration.jpg">
</p>

2.	Run the following command
 
 ```
cd "C:\Users\projects\New folder\MLOpsBasic-Databricks\src\setup"
 
.\configureResources.ps1
 ```

3.  At the end of the script execution, we will be able to see the databricks cluster has been created successfully.the config file: src\setup\util\DBCluster-Configuration.json is being used to create the cluster.


<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/SuccessfulClusterCreation.JPG">
</p>

4.	Copy the output of the script and paste it to the .env file which we had created previously 

<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/OutputOfTheConfigurationStep.jpg">
</p>

## Section 4: Create the .env file


1.	We need to manually change the databricks host and appI_IK values. Other values should be "as is" from the output of the previous script.

- PYTHONPATH=/workspaces/MLOpsBasic-Databricks/src/modules [The python path in the docker container]
- APPI_IK=connection string of the application insight
- DATABRICKS_HOST=The URL of the databricks workspace.
- DATABRICKS_TOKEN= Databricks Personal Access Token which was generated in the previous step.
- DATABRICKS_ORDGID=OrgID of the databricks that can be fetched from the databricks URL.
 

<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/DatabricksORGIDandHOSTID.JPG">
</p>

Application Insight Connection String

<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/AppInsightConnectionString.jpg">
</p>

At the end, our .env file is going to look as below:
 ```
 
PYTHONPATH=/workspaces/MLOpsBasic-Databricks/src/modules
APPI_IK=InstrumentationKey=e6221ea6xxxxxxf-8a0985a1502f;IngestionEndpoint=https://northeurope-2.in.applicationinsights.azure.com/
DATABRICKS_HOST=https://adb-7936878321001673.13.azuredatabricks.net
DATABRICKS_TOKEN= <Provide the secret>
DATABRICKS_ORDGID=7936878321001673

```

## Section 5: Configure the databricks connect

1.	In this step we are going to configure the databricks connect for VS code to connect to databricks. Run the below command for that from the docker (VS Code) terminal.

 ```
$ python "src/tutorial/scripts/local_config.py" -c "src/tutorial/cluster_config.json"
 ```
>Note: If you get any error saying that "model not found". Try to reload the VS code window and see if you are getting prompt  right bottom corner saying that configuration file changes, rebuild the docker image. Rebuild it and then reload the window. Post that you would not be getting any error. 
 
#### Verify :
1.	You will be able to see the message All tests passed.

<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/databricks-connect-pass.jpg">
</p>


## Section 6:  Create the private package(.whl) and upload to the workspace.
In this section, we will create the private python package and upload it to the databricks environment. 

1.	Run the below command:

```
python src/tutorial/scripts/install_dbkframework.py -c "src/tutorial/cluster_config.json"
``` 
Post  Execution of the script, we will be able to see the module to be installed.


<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/cluster-upload-wheel.jpg">
</p>


## Section 7: Using the framework.
 
To check if the framework is working fine or not, lets execute this file : **src/tutorial/scripts/framework_testing/remote_analysis.py**


Post running the script, we will be able to see the data in the terminal 

<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/final.jpg">
</p>

In order to run the same notebook in the databricks, we just need to create a databricks secrets for the application insight connection string. 

For this, we can execute the below query:

```
python src/tutorial/create_databricks_secrets.py

```
After copying the content of the remote_analysis.py in the databricks notebook, we get the output as below:


<p align="center">
<img src = "https://github.com/microsoft/dstoolkit-ml-ops-for-databricks/blob/main/docs/images/DatabricksNotebookExecution.JPG">
</p>

