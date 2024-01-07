// Define parameters for the script
param sourceTableName string = 'rig' // Source table name
param pipelineName string = 'db_devpipeline'
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

// Define variables for clarity
var linkedServiceSourceName = 'ds_source-linkserver'
var linkedServiceSinkName = 'ds_sink-linkserver'
var sourceDatasetName = 'ds_source-dataset'
var sinkDatasetName = 'ds_sink-dataset'
var dataFactoryName = 'mydatafactory'

// Define variables for source server and database
var sourceServer = sourceSqlServer
var sourceDatabase = 'sourcedb'

// Define variables for sink server and database
var sinkServer = sinkSqlServer
var sinkDatabase = 'sinkdb'

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
      connectionString: 'Server=${sinkServer};Database=${sinkDatabase};User Id=${sqlsinkUserId};Password=${sqlsinkPassword};'
    }
  }
}

// Define dataset for the source
resource dataFactorySourceDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: sourceDatasetName
  properties: {
    type: 'AzureSqlTable'
    linkedServiceName: dataFactoryLinkedServiceSource
    typeProperties: {
      tableName: sourceTableName
    }
  }
}

// Define dataset for the sink
resource dataFactorySinkDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: sinkDatasetName

  properties: {
    type: 'AzureSqlTable'
    linkedServiceName: dataFactoryLinkedServiceSink
    typeProperties: {
      tableName: sourceTableName // Use the same table name for source and sink
    }
  }
}

// Define pipeline for the data copy activity
resource dataFactoryPipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: pipelineName
  properties: {
    activities: [
      {
        name: 'CopyData'
        type: 'Copy'
        typeProperties: {
          source: {
            type: 'SqlSource'
            sqlReaderQuery: 'SELECT * FROM ${sourceTableName}'
          }
          sink: {
            type: 'SqlSink'
            writeBatchSize: 10000
            writeBatchTimeout: '60.00:00:00'
          }
        }
        inputs: [
          {
            referenceName: dataFactorySourceDataset.name
            type: 'DatasetReference'
          }
        ]
        outputs: [
          {
            referenceName: dataFactorySinkDataset.name
            type: 'DatasetReference'
          }
        ]
      }
    ]
  }
}
