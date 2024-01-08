// Define parameters for the scriptsf
param sourceTableName string = 'welldata'
param pipelineName string = 'db_raistofutura'
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
var linkedServiceSourceName = 'ds_raissqlserver'
var linkedServiceSinkName = 'ds_futuraazuresqll'
var sourceDatasetName = 'ds_sqlrais_${sourceTableName}' // Using sourceTableName parameter in the dataset name
var sinkDatasetName = 'ds_azurfutura'
var dataFactoryName = 'myappadf'

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

// Define linked service for the source (SQL Server)
resource dataFactoryLinkedServiceSource 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: linkedServiceSourceName
  properties: {
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: 'Server=${sourceServer};Database=${sourceDatabase};User Id=${sqlsourceUserId};Password=${sqlsourcePassword};'
    }
  }
  dependsOn: [dataFactory]
}

// Define linked service for the sink (Azure SQL Database)
resource dataFactoryLinkedServiceSink 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: linkedServiceSinkName
  properties: {
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: 'Server=${sinkServer};Database=${sinkDatabase};User Id=${sqlsinkUserId};Password=${sqlsinkPassword};'
    }
  }
  dependsOn: [dataFactory]
}

// Define dataset for the source
resource dataFactorySourceDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: sourceDatasetName
  properties: {
    linkedServiceName: dataFactoryLinkedServiceSource
    type: 'AzureSqlTable'
    typeProperties: {
      schema: 'dbo'
      table: sourceTableName // Using sourceTableName parameter in the table name
    }
  }
}

// Define dataset for the sink
resource dataFactorySinkDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: sinkDatasetName
  properties: {
    linkedServiceName: dataFactoryLinkedServiceSink
    type: 'AzureSqlTable'
    typeProperties: {
      schema: 'dbo'
      table: 'futura'
    }
  }
}

// Define pipeline for the data copy activity
resource dataFactoryPipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
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
            referenceName: 'AzureSqlTable1'
            type: 'DatasetReference'
            parameters: {}
          }
        ]
        outputs: [
          {
            referenceName: 'AzureSqlTable2'
            type: 'DatasetReference'
            parameters: {}
          }
        ]
      }
    ]
    policy: {
      elapsedTimeMetric: {}
    }
  }
  dependsOn: [
    dataFactoryLinkedServiceSource
    dataFactoryLinkedServiceSink
    dataFactorySourceDataset
    dataFactorySinkDataset
  ]
}
