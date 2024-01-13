// Define parameters for the script
@description('Name of the pipeline for data copy activity.')
param pipelineName string = 'ds_rais'

@description('User Id for the source SQL Server.')
@secure()
param sqlsourceUserId string

@description('Password for the source SQL Server.')
@secure()
param sqlsourcePassword string

@description('User Id for the sink Azure SQL Database.')
@secure()
param sqlsinkUserId string

@description('Password for the sink Azure SQL Database.')
@secure()
param sqlsinkPassword string

@description('Server for the source SQL Server.')
@secure()
param sourceSqlServer string

@description('Server for the sink Azure SQL Database.')
@secure()
param sinkSqlServer string

// Define variable names for clarity
var linkedServiceSourceName = 'ds_rais_sql_'
var linkedServiceSinkName = 'ds_futura_cloud'
var sourceDatasetName = 'ds_raiset_sql'
var sinkDatasetName = 'ds_futura_cloud'
var dataFactoryName = 'myappadfa'

// Define variables for source server and database
var sourceServer = sourceSqlServer
var sourceDatabase = 'raisqadb'

// Define variables for sink server and database
var sinkServer = sinkSqlServer
var sinkDatabase = 'futuraqa'

// Defining existing ADF
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource dataFactoryLinkedServiceSource 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: linkedServiceSourceName
}

resource dataFactoryLinkedServiceSink  'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: linkedServiceSinkName
}


resource dataFactorySourceDataset 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: sourceDatasetName
}

resource dataFactorySinkDataset 'Microsoft.DataFactory/factories@2018-06-01' existing = {
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




