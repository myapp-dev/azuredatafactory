param deleteActivityName string
param datasetName string
param sourceType string
param isRecursive bool
param maxConcurrentConnections int
param enableLogging bool
param linkedServiceName string
param logFilePath string

resource deleteActivity 'Microsoft.DataFactory/factories/pipelines/activities@2018-06-01' = {
  name: deleteActivityName
  properties: {
    type: 'Delete'
    typeProperties: {
      dataset: {
        referenceName: datasetName
        type: 'DatasetReference'
      }
      storeSettings: {
        type: sourceType
        recursive: isRecursive
        maxConcurrentConnections: maxConcurrentConnections
      }
      enableLogging: enableLogging
      logStorageSettings: if (enableLogging) {
        linkedServiceName: {
          referenceName: linkedServiceName
          type: 'LinkedServiceReference'
        }
        path: logFilePath
      }
    }
  }
}
