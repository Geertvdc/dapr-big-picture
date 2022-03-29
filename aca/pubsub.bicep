param location string = 'westeurope'
param aca_env string

resource containerappenv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: aca_env
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: 'dapr-bigpicture-servicebus'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2017-04-01' = {
  parent: serviceBusNamespace
  name: 'dapr-bigpicture-servicebus-queue'
}

var serviceBusEndpoint = '${serviceBusNamespace.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnectionString = listKeys(serviceBusEndpoint, serviceBusNamespace.apiVersion).primaryConnectionString


resource servicebus_component 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  parent: containerappenv
  name: 'pubsub'
  properties:{
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    metadata: [
      {
        name: 'connectionString'
        secretRef: 'connectionstring-key'
      }
    ]
    secrets: [
      {
        name: 'connectionstring-key'
        value: serviceBusConnectionString
      }
    ]
  }
}

