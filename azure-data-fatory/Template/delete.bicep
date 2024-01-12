param sinkDatasetName string
param linkedServiceSinkName string
param sourceType string
param currentConnections int

resource deleteActivity 'Microsoft.DataFactory/factories/pipelines/activities@2020-06-01' = {
  name: 'DeleteActivity'
  properties: {
    type: 'Delete'
    typeProperties: {
      dataset: {
        referenceName: sinkDatasetName
        type: 'DatasetReference'
      }
      storeSettings: {
        type: sourceType
        recursive: true
        maxConcurrentConnections: currentConnections
      }
      enableLogging: false // Set to true if needed
      logStorageSettings: {
        linkedServiceName: {
          referenceName: linkedServiceSinkName
          type: 'LinkedServiceReference'
        }
        path: '<path to save log file>'
      }
    }
  }
}

resource cleanupExpiredFiles 'Microsoft.DataFactory/factories/pipelines@2020-06-01' = {
  name: 'CleanupExpiredFiles'
  properties: {
    activities: [
      {
        name: 'DeleteFilebyLastModified'
        type: 'Delete'
        dependsOn: []
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          dataset: {
            referenceName: sinkDatasetName
            type: 'DatasetReference'
          }
          logStorageSettings: {
            linkedServiceName: {
              referenceName: linkedServiceSinkName
              type: 'LinkedServiceReference'
            }
            path: 'mycontainer/log'
          }
          enableLogging: true
          storeSettings: {
            type: 'AzureBlobStorageReadSettings'
            recursive: true
            modifiedDatetimeEnd: '2024-01-05T00:00:00.000Z'
          }
        }
      }
    ]
    annotations: []
  }
}


param dataFactoryName string
param Start string
param Enabled string

resource factory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  properties: {
    publicNetworkAccess: Enabled
    identity: {
      type: 'SystemAssigned'
    }
  }
}

resource trigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: 'MyTrigger'
  properties: {
    type: 'Schedule'
    typeProperties: {
      recurrence: {
        endTime: '2024-01-01T18:10:00Z'
        frequency: 'Day'
        interval: 1
        schedule: {
          hours: [
            3
          ]
          minutes: [
            0
          ]
          monthDays: [
            1
          ]
          monthlyOccurrences: [
            {
              day: 'Monday'
              occurrence: 1
            }
          ]
          weekDays: [
            'Monday'
          ]
        }
        startTime: '2024-01-01T18:00:00Z'
        timeZone: 'IST'
      }
    }
  }
  dependsOn: [
    factory
  ]
}

// Start publishing with ADF template
// Create ADF template
