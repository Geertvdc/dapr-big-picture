param location string = 'westeurope'
param aca_env string

resource containerappenv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: aca_env
}

resource redisCache 'Microsoft.Cache/Redis@2019-07-01' = {
  name: 'redisshopstate'
  location: location
  properties: {
    enableNonSslPort: true
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 0
    }
  }
}

var redisHost = redisCache.properties.hostName
var redisPassword = redisCache.listKeys().primaryKey

resource redis 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  parent: containerappenv
  name: 'shopstate'
  properties: {
    componentType : 'state.redis'
    version: 'v1'
    ignoreErrors: false
    initTimeout: '60s'
    secrets: [
      {
        name: 'redis-key'
        value: redisPassword
      }
    ]
    metadata : [
      {
        name: 'redisHost'
        value: '${redisHost}:6379'
      }
      {
        name: 'redisPassword'
        secretRef: 'redis-key'
      }
    ]
  }
}
