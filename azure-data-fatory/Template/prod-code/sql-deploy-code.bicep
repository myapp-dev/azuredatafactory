// Define parameters for the script
@description('Name of the pipeline for data copy activity.')
param pipelineName string = 'ds_rais'




// Define variable names for clarity
var linkedServiceSourceName = 'ds_rais_sql'
var linkedServiceSinkName = 'ds_futura_cloud'
var sourceDatasetName = 'ds_raiset_sql'
var sinkDatasetName = 'ds_futura_cloud'
var dataFactoryName = 'myappadfa'

// Defining existing ADF
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource dataFactoryLinkedServiceSource 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' existing = {
  parent: dataFactory
  name: linkedServiceSourceName
}

resource dataFactoryLinkedServiceSink 'Microsoft.DataFactory/factories/linkedServices@2018-06-01' existing = {
  name: linkedServiceSinkName
}

resource dataFactorySourceDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' existing = {
  name: sourceDatasetName
}

resource dataFactorySinkDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' existing = {
  name: sinkDatasetName
}

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: pipelineName
  properties: {
    activities: [
      {
        name: 'Copy data'
        type: 'Copy'
        dependsOn: []
        policy: {
          timeout: '0.12:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'AzureSqlSource'
            queryTimeout: '02:00:00'
            partitionOption: 'None'
          }
          sink: {
            type: 'AzureSqlSink'
            writeBehavior: 'insert'
            sqlWriterUseTableLock: false
            tableOption: 'autoCreate'
            disableMetricsCollection: false
          }
          enableStaging: false
          translator: {
            type: 'TabularTranslator'
            typeConversion: true
            typeConversionSettings: {
              allowDataTruncation: true
              treatBooleanAsNumber: false
            }
          }
        }
        inputs: [
          {
            referenceName: dataFactorySourceDataset.name
            type: 'DatasetReference'
            parameters: {}
          }
        ]
        outputs: [
          {
            referenceName: dataFactorySinkDataset.name
            type: 'DatasetReference'
            parameters: {}
          }
        ]
      }
    ]
    policy: {
      elapsedTimeMetric: {}
    }
    annotations: []
  }
}

resource dataFactoryPipelineTrigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: 'raistrigger'
  parent: dataFactory
  properties: {
    annotations: []
    type: 'ScheduleTrigger'
    pipelines: [
      {
        parameters: {}
        pipelineReference: {
          name: pipeline.name
          referenceName: pipeline.name
          type: 'PipelineReference'
        }
      }
    ]
    typeProperties: {
      recurrence: {
        frequency: 'Day'
        interval: 1
        startTime: '2024-01-12T09:18:00'
        timeZone: 'India Standard Time'
        schedule: {
          minutes: [
            18
          ]
          hours: [
            9
          ]
        }
      }
    }
  }
}
