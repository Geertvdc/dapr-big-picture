param location string = 'westeurope'
param aca_env string = 'dapr-bigpicture-containerappenv'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: 'dapr-bigpicture-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: 'dapr-bigpicture-appinsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}


resource containerappenv 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: aca_env
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: listKeys(logAnalyticsWorkspace.id, '2020-10-01').primarySharedKey
      }
    }
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
  }
}

resource frontend 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'frontend'
  location: location
  properties: {
    managedEnvironmentId: containerappenv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
      }
      dapr: {
        enabled: true
        appPort: 80
        appId: 'frontend'
      }
    }
    template: {
      containers: [
        {
          image: 'marcelv/globoticket-dapr-frontend:latest'
          name: 'frontend'
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

resource catalog 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'catalog'
  location: location
  properties: {
    managedEnvironmentId: containerappenv.id
    configuration: {
      ingress: {
        external: false
        targetPort: 80
      }
      dapr: {
        enabled: true
        appPort: 80
        appId: 'catalog'
      }
    }
    template: {
      containers: [
        {
          image: 'marcelv/globoticket-dapr-catalog:latest'
          name: 'catalog'
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

resource ordering 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'ordering'
  location: location
  properties: {
    managedEnvironmentId: containerappenv.id
    configuration: {
      ingress: {
        external: false
        targetPort: 80
      }
      dapr: {
        enabled: true
        appPort: 80
        appId: 'ordering'
      }
    }
    template: {
      containers: [
        {
          image: 'marcelv/globoticket-dapr-ordering:latest'
          name: 'catalog'
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}
