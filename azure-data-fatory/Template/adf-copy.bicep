param sourceTableName string = 'tcs'
param pipelineName string = 'db_raistofutura_copy'

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

var linkedServiceSourceName = 'ds_sqlserver'
var linkedServiceSinkName = 'ds_azuresql'
var sourceDatasetName = 'ds_sqlserverdataset'
var sinkDatasetName = 'ds_azuresqldataset'
var dataFactoryName = 'myappadf'

var sourceServer = sourceSqlServer
var sourceDatabase = 'raisqadb'
var sinkServer = sinkSqlServer
var sinkDatabase = 'futuraqa'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

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

resource dataFactorySinkDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: sinkDatasetName
  properties: {
    type: 'AzureSqlTable'
    linkedServiceName: dataFactoryLinkedServiceSink
    typeProperties: {
      tableName: sourceTableName
      schema: 'dbo'
    }
  }
}

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
            writeBehavior: 'Insert'
            tableOption: 'AutoCreateTable'
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
