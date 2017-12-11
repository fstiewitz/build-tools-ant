module.exports =

  config:
    provider:
      title: 'How to load targets from build files'
      description: 'Try legacy method if you encounter bugs'
      type: 'string'
      default: 'vproj'
      enum: [
        {value: 'vproj', description: 'Load all targets with ProjectHelper'}
        {value: 'proj', description: 'Load targets with ProjectHelper'}
        {value: 'legacy', description: 'Parse build file (legacy)'}
      ]

  provideProvider: ->
    key: 'java-ant'
    mod: require './module'
