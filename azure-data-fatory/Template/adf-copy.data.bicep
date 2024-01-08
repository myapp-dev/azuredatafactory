var dataFactoryName = 'myappadf'
// Defining existing ADF
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

