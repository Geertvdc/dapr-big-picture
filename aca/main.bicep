param location string = 'westeurope'
param aca_env string = 'dapr-bigpicture-containerappenv'

module aca 'aca.bicep' = {
  name: 'aca'
  params: {
    location: location
    aca_env: aca_env
  }
}

module pubsub 'pubsub.bicep' = {
  name: 'pubsub'
  dependsOn: [
    aca
  ]
  params: {
    location: location
    aca_env: aca_env
  }
}


module state 'state.bicep' = {
  name: 'state'
  dependsOn: [
    aca
  ]
  params: {
    location: location
    aca_env: aca_env
  }
}


