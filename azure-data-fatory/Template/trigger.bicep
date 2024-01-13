resource rais_trigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: 'rais_trigger'
  properties: {
    annotations: []
    pipelines: [
      {
        pipelineReference: {
          referenceName: 'ds_rais_to_futura'
          type: 'PipelineReference'
        }
      }
    ]
    type: 'ScheduleTrigger'
    typeProperties: {
      recurrence: {
        frequency: 'Day'
        interval: 1
        startTime: '2024-01-12T08:18:00'
        timeZone: 'India Standard Time'
        schedule: {
          minutes: [
            18
          ]
          hours: [
            8
          ]
        }
      }
    }
  }
}

// You can use the following PowerShell command to start the trigger
resource start_trigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: 'start_trigger'
  properties: {
    mode: 'Incremental'
    template: {
      $schema: 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: [
        {
          type: 'Microsoft.DataFactory/factories/triggers/start'
          apiVersion: '2018-06-01'
          name: 'rais_trigger/StartTrigger'
          properties: {
            referenceName: 'rais_trigger'
          }
        }
      ]
    }
  }
}
