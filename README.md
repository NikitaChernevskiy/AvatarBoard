# Azure AvatarBoard Deployment Guide

Welcome to the Azure AvatarBoard Deployment Guide! This comprehensive guide will walk you through the process of deploying Azure resources, configuring Power Pages, and integrating with Power Automate to set up your AvatarBoard application. By following these step-by-step instructions, you'll ensure a smooth and successful deployment.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Required Extensions and Repository Cloning](#required-extensions-and-repository-cloning)
3. [Deployment Steps](#deployment-steps)
   - [Step 1: Deploy Azure Resources](#step-1-deploy-azure-resources)
   - [Step 2: Upload Training Data and Configure Azure Cognitive Search](#step-2-upload-training-data-and-configure-azure-cognitive-search)
   - [Step 3: Power Pages Site Setup](#step-3-power-pages-site-setup)
4. [Completion and Verification](#completion-and-verification)
5. [Support and Resources](#support-and-resources)

## Prerequisites

Before you begin, ensure you have the following:

- **Visual Studio Code (VS Code):** Download and install [VS Code](https://code.visualstudio.com?wt.mc_id=studentamb_417097) if you haven't already.
- **Azure Subscription:** An active [Microsoft Azure](https://azure.microsoft.com?wt.mc_id=studentamb_417097) account. If you don't have one, you can [sign up for free](https://azure.microsoft.com/free?wt.mc_id=studentamb_417097).
- **Power Pages and Power Automate Access:** Access to [Power Pages](https://powerpages.microsoft.com?wt.mc_id=studentamb_417097) and [Power Automate](https://flow.microsoft.com?wt.mc_id=studentamb_417097), including licenses for Premium connectors.
- **Azure CLI:** Install the [Azure Command-Line Interface (CLI)](https://docs.microsoft.com/cli/azure/install-azure-cli?wt.mc_id=studentamb_417097) for interacting with Azure services via the command line.

## Required Extensions and Repository Cloning

### 1. Install VS Code Extensions

To enhance your development experience, install the following VS Code extensions:

- **Azure CLI Tools Extension:** Improves Azure CLI integration within VS Code.
  
  [Install Azure CLI Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli&wt.mc_id=studentamb_417097)

- **Bicep Extension:** Adds support for the Bicep language, simplifying Azure resource deployments.
  
  [Install Bicep Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep&wt.mc_id=studentamb_417097)

### 2. Clone the AvatarBoard Repository

Clone the AvatarBoard repository to access deployment scripts and templates:

```bash
git clone https://github.com/NikitaChernevskiy/AvatarBoard.git
```

## Deployment Steps

### Step 1: Deploy Azure Resources

#### 1. Open VS Code Terminal

- Launch VS Code.
- Open a new terminal window by pressing `Ctrl + Shift + `` or navigating to **Terminal > New Terminal**.

#### 2. Sign Out of Azure CLI (Optional)

Ensure you're not logged in with unintended credentials:

```bash
az logout
```

### 3. Sign In to Azure CLI

Log in to your Azure account:

```bash
az login
```
If prompted, complete the authentication in your web browser.

*Optional:* To specify a tenant ID:

```bash
az login --tenant YOUR_TENANT_ID
```
Replace `YOUR_TENANT_ID` with your Azure tenant ID, found in Azure Active Directory properties.

### 4. Verify Resource Provider Registration

Check if the required resource providers are registered:

```bash
az provider show --namespace Microsoft.CognitiveServices --query "registrationState"
az provider show --namespace Microsoft.Storage --query "registrationState"
az provider show --namespace Microsoft.Search --query "registrationState"
az provider show --namespace Microsoft.Authorization --query "registrationState"
```
If any return `NotRegistered`, proceed to the next step.

### 5. Register Resource Providers

Register any unregistered resource providers:

```bash
az provider register --namespace Microsoft.CognitiveServices --wait
az provider register --namespace Microsoft.Storage --wait
az provider register --namespace Microsoft.Search --wait
az provider register --namespace Microsoft.Authorization --wait
```

### 6. Create a Resource Group

Create a new resource group for your deployment:

```bash
az group create --location YOUR_REGION --name avatarboardrg
```
Replace `YOUR_REGION` with your preferred Azure region (e.g., `eastus`, `westeurope`).

**View available regions:**

```bash
az account list-locations --output table
```

### 7. Retrieve Your Principal ID

Find your Azure Active Directory object ID:

```bash
az ad signed-in-user show --query objectId -o tsv
```

### 8. Deploy Resources Using Bicep Template

Deploy Azure resources with the Bicep template:

```bash
az deployment group create \
  --resource-group avatarboardrg \
  --template-file ".\code\template.bicep" \
  --parameters name=avatarboard deploymentPrincipalId=YOUR_PRINCIPAL_ID
```

Replace `YOUR_PRINCIPAL_ID` with the `objectId` from the previous step.

*This deployment may take several minutes.*

### Step 2: Upload Training Data and Configure Azure Cognitive Search

Now that you've deployed the necessary Azure resources, it's time to upload your training data and configure Azure Cognitive Search to index and vectorize this data.

#### 1. Wait for Resource Provisioning

**Important:** Wait approximately 1 hour after deploying the services to ensure all resources are fully provisioned and connected. This waiting period helps prevent issues that may arise from resources not being fully ready.

#### 2. Upload Training Data to Azure Blob Storage

**Access the Storage Account**

1. Sign in to the Azure Portal.
2. Navigate to your resource group (`avatarboardrg`).
3. Locate and open the Storage Account you created during deployment (e.g., `avatarboardsa`).

**Upload Data to Blob Storage**

1. In the Storage Account overview, select **Containers** under Data storage in the left-hand menu.
2. Click on **Blob Containers**.
3. Open the blob container you created (e.g., `avatarboardcontainer`).
4. Click on **Upload**.
5. In the upload pane, click **Browse**.
6. Select your training data file(s):
   - **Own Data:** If you have your own training data, select your files.
   - **Sample Data:** If not, use the sample data provided:
     - Navigate to the solutions folder in your cloned repository.
     - Select `sampledata.pdf`.
   - Click **Upload** to upload the file(s) to the blob container.

#### 3. Configure Azure Cognitive Search (AI Search)

Now, you will set up Azure Cognitive Search to index and vectorize your uploaded data.

**Access Azure Cognitive Search**

1. In the Azure Portal, navigate back to your resource group.
2. Locate and open your Azure Cognitive Search service (e.g., `avatarboardsearch`).

**Import and Vectorize Data**

1. In the Cognitive Search service, click on **Import data** under **Get started** or **Data sources** in the left-hand menu.

2. On the Add data source page:
   - **Data source type:** Select **Azure Blob Storage**.
   - **Connection string name:** Choose your storage account connection string.
   - **Container name:** Select your blob container (e.g., `avatarboardcontainer`).
   - **Data source name:** Enter a name for your data source (e.g., `avatarboard-datasource`).
   - **Deletion detection:** Check **Enable deletion detection** and set **Deletion detection mechanism** to **Soft delete**.
   - Click **Next: Add cognitive skills** >.

**Vectorize Your Text**

1. On the **Enrich (Add cognitive skills)** page:
   - Scroll down to **Vectorization**:
     - **Vectorize content:** Enable vectorization of your text data.
     - **Model deployment:** Select the model deployment you created (e.g., `avatarboard-model`).
     - **Authentication type:** Choose **API Key**.
     - **Note:** If you haven't deployed a model or are unsure, refer to the Vector Search documentation for guidance on deploying models.
   - Click **Next: Customize target index** >.

**Configure the Index**

1. On the **Customize target index** page:
   - Review the index schema and make adjustments if necessary.
   - Click **Next: Configure indexer** >.

**Configure Indexing Schedule**

1. On the **Configure indexer** page:
   - **Indexing schedule:** Set the indexing schedule to **Daily** or adjust according to your needs.
   - **Start time:** Optionally set a specific start time.
   - **Field mappings:** Review and adjust if necessary.
   - Click **Next: Review** >.

**Review and Create the Index**

1. On the **Review and finish** page:
   - **Indexer name:** Enter a name (e.g., `avatarboard-indexer`). Note this name; you'll need it later.
   - Review all the settings to ensure they are correct.
   - **Data source name:** Verify.
   - **Skillset name:** Verify.
   - **Index name:** Verify.
   - **Indexer name:** Verify.
   - Click **Submit** to start the indexing process.


## Step 3: Power Pages Site Setup

### 1. Access Power Pages

Go to [make.powerpages.microsoft.com](https://make.powerpages.microsoft.com?wt.mc_id=studentamb_417097).

Sign in with the same credentials used for Azure.

### 2. Import the AvatarBoard Solution

**Download the Solution File**

Obtain `AvatarBoard_2_0_0_0.zip` from the repository's solutions directory.

**Import the Solution**

1. In Power Pages, navigate to **Solutions** on the left menu.
2. Click **Import** at the top.
3. Upload `AvatarBoard_2_0_0_0.zip`.
4. Follow the prompts to complete the import.

### Step 3: Set Up Cloud Flows in Power Automate

#### Access Power Automate

From the app launcher (waffle icon) in Power Pages, select **Power Automate** or go directly to [make.powerautomate.com](https://make.powerautomate.com?wt.mc_id=studentamb_417097).

#### Locate and Edit the GetSecrets Flow

1. Under **Solutions**, find the **AvatarBoard** solution.
2. Open the **GetSecrets** flow.
3. Click **Edit**.

#### Configure Azure Key Vault Connection

1. In the flow editor, find the **Azure Key Vault** action.
2. Click on **...** (ellipsis) and select **Add new connection**.
3. Set up the connection:
   - **Authentication Type:** Default Azure AD application
   - **Vault Name:** Your Key Vault name (e.g., `avatarboardkv`)
4. Click **Create**.

#### Save and Turn On the Flow

- Click **Save**.
- Toggle the flow to **On** if it's not already active.

### Step 4: Reactivate and Configure the Power Pages Site

#### Reactivate the Site

1. In Power Pages, navigate to **Apps > Portal Management**.
2. Under **Inactive Sites**, find the **AvatarBoard** site.
3. Click **Reactivate**.

#### Set Site Details

- **Name:** Enter a unique name.
- **URL:** Provide a unique web address.
- **Language and Time Zone:** Set as appropriate.
- Click **Reactivate**.

### Step 5: Integrate Custom Code

#### Edit the Home Page Code

1. In Power Pages, go to **Apps > AvatarBoard** site.
2. Click **Edit** to open the design studio.
3. Navigate to **Pages > Home**.
4. Click **Edit code**.

#### Modify `Home.en-US.customjs.js`

Replace placeholders with actual values:

```javascript
var _url = var _url = "https://<<REPLACE_WITH_PP_LINK>>.powerappsportals.com/_api/cloudflow/v1.0/trigger/<<REPLACE_WITH_PA_ID>>";
var azureCogSearchIndexNamesecret = "<<REPLACE_WITH_AIS_INDEX>>";
```
- `<<REPLACE_WITH_PP_LINK>>`: Your site's URL (e.g., avatar-board).
- `<<REPLACE_WITH_PA_ID>>`: The ID of the GetSecrets flow. Find it in the flow's URL: `https://.../flows/PA_ID/details`
- `<<REPLACE_WITH_AIS_INDEX>>`: The name of your Azure Cognitive Search index.

#### Save and Sync Changes

1. Click **Save** in the code editor.
2. Return to the main design studio.
3. Click **Sync** to apply changes.

#### Preview the Site

Click **Browse** or **Preview** to test your site.

## Completion and Verification

- **Test Functionality:** Ensure all features work as expected.
- **Check Azure Resources:** Monitor your Azure resources for any issues.
- **Validate Power Automate Flows:** Confirm flows run successfully.
- **Troubleshoot if Needed:**
  - Verify all configurations.
  - Ensure all IDs and URLs are correct.
  - Consult logs for errors.

## Support and Resources

For assistance, consider the following resources:

- [Azure Documentation](https://docs.microsoft.com/azure?wt.mc_id=studentamb_417097)
- [Power Pages Documentation](https://docs.microsoft.com/power-pages?wt.mc_id=studentamb_417097)
- [Power Automate Documentation](https://docs.microsoft.com/power-automate?wt.mc_id=studentamb_417097)
- [Microsoft Learn](https://learn.microsoft.com?wt.mc_id=studentamb_417097)
  - [Azure Learning Paths](https://learn.microsoft.com/training/azure?wt.mc_id=studentamb_417097)
  - [Power Platform Learning Paths](https://learn.microsoft.com/training/powerplatform?wt.mc_id=studentamb_417097)
- [Community Support:](https://docs.microsoft.com/answers/topics/power-platform.html?wt.mc_id=studentamb_417097)
  - [Microsoft Q&A](https://docs.microsoft.com/answers/index.html?wt.mc_id=studentamb_417097)
  - [Power Platform Community](https://powerusers.microsoft.com/t5/Power-Platform/ct-p/PowerPlatform?wt.mc_id=studentamb_417097)

Thank you for following this guide to deploy the Azure AvatarBoard. Your feedback is appreciated as we strive to improve our documentation. If you have any suggestions or encounter issues, please open an issue in the repository.

**Happy deploying! 🚀**
