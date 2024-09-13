// Parameters
@minLength(2)
@maxLength(12)
@description('Name for the AI resource and used to derive name of dependent resources.')
param name string

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {env: 'avatarboardpov'}

// Principal ID
@description('The principal ID of the identity running the deployment')
param deploymentPrincipalId string

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)

// Dependent resources for the Azure AI Studio
var keyvaultName = '${name}${uniqueSuffix}kv'
var aoiName = '${name}${uniqueSuffix}aoi'
var speechName = '${name}${uniqueSuffix}speech'
var searchName = '${name}${uniqueSuffix}search'
var storageName = '${name}${uniqueSuffix}st'
var containerName = '${name}${uniqueSuffix}container'

// Modules

// module: Key Vault
module keyVault './modules/key-vault.bicep' = {
  name: keyvaultName
  params: {
    name: keyvaultName
    location: location
    tags: tags
    objectId: deploymentPrincipalId
  }
}

// module: Azure OpenAI
module aoi './modules/azure-openai.bicep' = {
  name: aoiName
  params: {
    name: aoiName
    location: location
    tags: tags
    kvname: keyvaultName
  }
  dependsOn: [
    keyVault
  ]
}

// module: Azure AI Speech
module aiSpeech './modules/ai-speech.bicep' = {
  name: speechName
  params: {
    name: speechName
    location: 'westeurope'
    tags: tags
    kvname: keyvaultName
  }
  dependsOn: [
    aoi
  ]
}

// module: Azure AI Search
module aiSearch './modules/ai-search.bicep' = {
  name: searchName
  params: {
    name: searchName
    location: location
    tags: tags
    kvname: keyvaultName
  }
  dependsOn: [
    aiSpeech
  ]
}

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
@description('Storage SKU')
param storageSkuName string = 'Standard_LRS'

@allowed(['Storage', 'StorageV2', 'BlobStorage', 'FileStorage', 'BlockBlobStorage'])
param storageKind string = 'StorageV2'

// module: Storage Account
module storageAccount './modules/storage-account.bicep' = {
  name: storageName
  params: {
    name: storageName
    containerName: containerName
    location: location
    tags: tags
    kind: storageKind
    skuName: storageSkuName
  }
}

output containerName string = storageAccount.outputs.containerName
output storageId string = storageAccount.outputs.id
output storageName string = storageAccount.outputs.name
output sasToken string = storageAccount.outputs.sasToken
output containerEndpoint string = storageAccount.outputs.containerEndpoint

output keyvaultName string = keyVault.outputs.name
output aoiName string = aoi.outputs.aoiName
output searchName string = aiSearch.outputs.name
