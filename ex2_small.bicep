param appName string
param eastLocation string = 'eastus2'
param westLocation string = 'westus'

resource eastAppServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${appName}-east-plan'
  location:eastLocation
  sku:{
    name: 'F1'
    tier: 'Free'
  }
}

resource westAppServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${appName}-west-plan'
  location:westLocation
  sku: {
    name: 'F1'
    tier: 'Free'
  }
}

resource eastWebApp 'Microsoft.Web/sites@2021-02-01' = {
  name: '${appName}-east'
  location: eastLocation
  properties: {
    serverFarmId: eastAppServicePlan.id
  }
}

resource westWebApp 'Microsoft.Web/sites@2021-02-01' = {
  name: '${appName}-west'
  location: westLocation
  properties: {
    serverFarmId: westAppServicePlan.id
  }
}

resource trafficManagerProfile 'Microsoft.Network/trafficmanagerprofiles@2018-08-01' = {
  name: '${appName}-tm'
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    dnsConfig: {
      relativeName: appName
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTP'
      port: 80
      path: '/'
      intervalInSeconds: 30
      timeoutInSeconds: 5
      toleratedNumberOfFailures: 3
    }
    endpoints: [
      {
        name: 'east'
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          endpointMonitorStatus: 'Online'
          targetResourceId: eastWebApp.id
          endpointStatus: 'Enabled'
          priority: 1
          endpointLocation: 'East US 2'
        }
      }
      {
        name: 'west'
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          endpointMonitorStatus: 'CheckingEndpoint'
          targetResourceId: westWebApp.id
          endpointStatus: 'Enabled'
          priority: 2
          endpointLocation: 'West US'
        }
      }
    ]
  }
}
