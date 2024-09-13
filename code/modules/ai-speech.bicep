// params

@description('AI Speech name')
param name string

@description('Resource Location')
param location string

@description('Tags')
param tags object

@description('Key Vault name')
param kvname string

// resource

resource aiSpeech 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  kind: 'SpeechServices'
  sku: {
    name: 'S0'
  }
  properties: {}
}

// secrets

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvname
}

resource subscriptionKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'subscriptionKey'
  properties: {
    value: aiSpeech.listKeys().key1
  }
}

resource region 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'region'
  properties: {
    value: aiSpeech.location
  }
  dependsOn: [
    subscriptionKey
  ]
}

// outputs
output name string = aiSpeech.name
output id string = aiSpeech.id
