resource dailyTrigger 'Microsoft.DataFactory/factories/triggers@2021-06-01' = {
  name: 'daily_trigger'
  properties: {
    annotations: []
    runtimeState: 'Stopped'
    pipelines: [
      {
        pipelineReference: {
          referenceName: 'ds_rais_futura'
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
          minutes: [
            15
          ]
          hours: [
            10
          ]
        }
      }
    }
  }
}
