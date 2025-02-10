targetScope = 'subscription'

// Parameters
param parLocation string
param parResourceGroupName string
param parEventGridSystemTopicName string
param parCreateFunctionResourceId string
param parDeleteFunctionResourceId string

// Resources
module modResourceGroup 'br/public:avm/res/resources/resource-group:0.4.0' = {
  name: 'resourceGroupDeployment'
  params: {
    name: parResourceGroupName
    location: parLocation
  }
}

module modSystemTopicCreate 'br/public:avm/res/event-grid/system-topic:0.5.0' = {
  name: 'systemTopicCreateDeployment'
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  params: {
    name: parEventGridSystemTopicName
    source: '/subscriptions/${subscription().subscriptionId}'
    topicType: 'Microsoft.ResourceNotifications.Resources'
    eventSubscriptions: [
      {
        destination: {
          endpointType: 'AzureFunction'
          properties: {
            maxEventsPerBatch: 1
            resourceId: parCreateFunctionResourceId
          }
        }
        eventDeliverySchema: 'EventGridSchema'
        expirationTimeUtc: '2099-01-01T11:00:21.715Z'
        filter: {
          includedEventTypes: [
            'Microsoft.ResourceNotifications.Resources.CreatedOrUpdated'
          ]
          advancedFilters: {
            operatorType: 'StringContains'
            key: 'data.resourceInfo.type'
            values: [
              'Microsoft.Network/privateEndpoints'
            ]
          }
        }
        name: 'privateEndpointCreation'
        retryPolicy: {
          eventTimeToLive: '1440'
          maxDeliveryAttempts: 30
        }
      }
    ]
    location: modResourceGroup.outputs.location
  }
}

module modSystemTopicDelete 'br/public:avm/res/event-grid/system-topic:0.5.0' = {
  name: 'systemTopicDeleteDeployment'
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  params: {
    name: parEventGridSystemTopicName
    source: '/subscriptions/${subscription().subscriptionId}'
    topicType: 'Microsoft.ResourceNotifications.Resources'
    eventSubscriptions: [
      {
        destination: {
          endpointType: 'AzureFunction'
          properties: {
            maxEventsPerBatch: 1
            resourceId: parDeleteFunctionResourceId
          }
        }
        eventDeliverySchema: 'EventGridSchema'
        expirationTimeUtc: '2099-01-01T11:00:21.715Z'
        filter: {
          includedEventTypes: [
            'Microsoft.ResourceNotifications.Resources.Deleted'
          ]
          advancedFilters: {
            operatorType: 'StringContains'
            key: 'data.resourceInfo.type'
            values: [
              'Microsoft.Network/privateEndpoints'
            ]
          }
        }
        name: 'privateEndpointDeletion'
        retryPolicy: {
          eventTimeToLive: '1440'
          maxDeliveryAttempts: 30
        }
      }
    ]
    location: modResourceGroup.outputs.location
  }
}
