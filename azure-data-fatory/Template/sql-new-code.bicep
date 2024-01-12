// Define parameters for the script
@description('Name of the pipeline for data copy activity.')
param pipelineName string = 'ds_rais_to_futura'

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
var linkedServiceSourceName = 'ds_rais_sql_onprem'
var linkedServiceSinkName = 'ds_futura_cloud'
var sourceDatasetName = 'ds_raiset_sql'
var sinkDatasetName = 'ds_futura_cloud'
var dataFactoryName = 'myappadfa'

// Define variables for source server and database
var sourceServer = sourceSqlServer
var sourceDatabase = 'rig_master'

// Define variables for sink server and database
var sinkServer = sinkSqlServer
var sinkDatabase = 'rig_master'

// Defining existing ADF
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

// Define linked service for the source (SQL Server)
resource dataFactoryLinkedServiceSource 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: linkedServiceSourceName
  properties: {
    type: 'AzureSqlDatabase'
    typeProperties: {
      // Use variables for sourceServer and sourceDatabase
      connectionString: 'Server=${sourceServer};Database=${sourceDatabase};User Id=${sqlsourceUserId};Password=${sqlsourcePassword};'
    }
  }
}

// Define linked service for the sink (Azure SQL Database)
resource dataFactoryLinkedServiceSink 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: linkedServiceSinkName
  properties: {
    type: 'AzureSqlDatabase'
    typeProperties: {
      // Use variables for sinkServer and sinkDatabase
      connectionString: 'Server=${sinkServer};Database=${sinkDatabase};User Id=${sqlsinkUserId};Password=${sqlsinkPassword};'
    }
  }
}



resource ds_raisonprem 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: sourceDatasetName
  properties: {
    linkedServiceName: {
      referenceName: 'ds_mysql'
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'AzureSqlTable'
    schema: []
    typeProperties: {
      schema: 'dbo'
      table: 'rig_master'
    }
  }
}

resource ds_futura 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: sinkDatasetName
  properties: {
    linkedServiceName: {
      referenceName: 'ds_muazuresql'
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'AzureSqlTable'
    schema: []
    typeProperties: {
      schema: 'dbo'
      table: 'rais_master'
    }
  }
}

resource futura_dev 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: pipelineName
  properties: {
    activities: [
      {
        name: 'Copy data1'
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
            referenceName: 'rais_dev'
            type: 'DatasetReference'
          }
        ]
        outputs: [
          {
            referenceName: 'futura_dev'
            type: 'DatasetReference'
          }
        ]
      }
    ]
    annotations: []
    lastPublishTime: '2024-01-12T20:10:51Z'
  }
}

resource dev_trigger 'Microsoft.DataFactory/factories/triggers@2021-06-01-preview' = {
  name: 'dev_trigger'
  properties: {
    annotations: []
    runtimeState: 'Started'
    pipelines: [
      {
        pipelineReference: {
          referenceName: 'futura_dev'
          type: 'PipelineReference'
        }
      }
    ]
    type: 'ScheduleTrigger'
    typeProperties: {
      recurrence: {
        frequency: 'Day'
        interval: 1
        startTime: '2024-01-12T01:37:00'
        timeZone: 'India Standard Time'
        schedule: {
          minutes: [43]
          hours: [1]
        }
      }
    }
  }
}
