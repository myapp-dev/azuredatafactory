Define parameters for the script
@description('Name of the pipeline for data copy activity.')
param pipelineName string = 'xxxxx'

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
var linkedServiceSourceName = 'ds_xxx'
var linkedServiceSinkName = 'ds_xxxx'
var sourceDatasetName = 'ds_mxxx'
var sinkDatasetName = 'ds_xxx'
var dataFactoryName = 'xxxx'

// Define variables for source server and database
var sourceServer = sourceSqlServer
var sourceDatabase = 'xxxx'

// Define variables for sink server and database
var sinkServer = sinkSqlServer
var sinkDatabase = 'xxxx'

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

// Define dataset for the source
resource dataFactorySourceDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: sourceDatasetName
  properties: {
    linkedServiceName: {
      referenceName: dataFactoryLinkedServiceSource.name
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'AzureSqlTable'
    schema: []
    typeProperties: {
      table: 'xxxx'
    }
  }
}

// Define dataset for the sink
resource dataFactorySinkDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: sinkDatasetName

  properties: {
    linkedServiceName: {
      referenceName: dataFactoryLinkedServiceSink.name
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'AzureSqlTable'
    schema: []
    typeProperties: {
      table: 'xxxxx'
    }
  }
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
  name: 'raisfuturatrigger'
  parent: dataFactory
  properties: {
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
    //create ADF templates
    {
      scripts:{
          build:node node_modules/@microsoft/azure-data-factory-utilities/lib/index
      },
      dependencies:{
          @microsoft/azure-data-factory-utilities:^0.1.3
      }
    }
    //define the publish_branch of the created data factories

    {publishBranch:factory/adf_publish,includeFactoryTemplate:true}

    //ARM Template definition for the factories
    {
      $schema: https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#,
      contentVersion: 1.0.0.0,
      parameters: {
          factoryName: {
                value: dataFactoryName
          },
          TriggerRunState: {
                value: Start
          }
          publicNetworkAccess: Enabled
                identity: {
                      type: SystemAssigned
          }
      }
    }

    typeProperties: {
      recurrence: {
        endTime: '2024-01-01T18:10:00Z' // Replace with your end time
        frequency: 'Day' // Replace with your frequency (e.g., 'Day')
        interval: 1 // Replace with your interval
        schedule: {
          hours: [
            03 // Replace with your hours
          ]
          minutes: [
            00// Replace with your minutes
          ]
          monthDays: [
            1 // Replace with your month day
          ]
          monthlyOccurrences: [
            {
              day: 'Monday' // Replace with your day
              occurrence: 1 // Replace with your occurrence
            }
          ]
          weekDays: [
            'Monday' // Replace with your week day
          ]
        }
        startTime: '2024-01-01T18:00:00Z' // Replace with your start time
        timeZone: 'IST' // Replace with your time zone
      }
    }
  }
}
//start publishing with ADF template
//create adf template 





