param factoryName string = 'yourFactoryName'
param ds_raissqlserver string = 'yourRaiSqlServer'
param ds_futuraazuresqll string = 'yourFuturaAzureSql'

resource dataset1 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${factoryName}/AzureSqlTable1'
  properties: {
    linkedServiceName: {
      referenceName: ds_raissqlserver
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'AzureSqlTable'
    schema: []
    typeProperties: {
      schema: 'dbo'
      table: 'welldata'
    }
  }
}

resource dataset2 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: '${factoryName}/AzureSqlTable2'
  properties: {
    linkedServiceName: {
      referenceName: ds_futuraazuresqll
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'AzureSqlTable'
    schema: []
    typeProperties: {
      schema: 'dbo'
      table: 'futura'
    }
  }
}

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: '${factoryName}/pipeline1'
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
    annotations: []
  }
  dependsOn: [
    dataset1
    dataset2
  ]
}

resource dataFactoryPipelineTrigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: 'raisfuturatrigger'
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
        startTime: '2024-01-12T01:41:00'
        timeZone: 'India Standard Time'
        schedule: {
          minutes: [41]
          hours: [7]
        }
      }
    }
  }
}
