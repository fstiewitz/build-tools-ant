Module = require '../lib/module'

path = require 'path'

Command =
  class Command
    constructor: (t) ->
      for k in Object.keys(t)
        this[k] = t[k]

describe 'Command Provider: Ant File', ->
  model = null
  projectPath = null
  filePath = null
  config = null

  beforeEach ->
    projectPath = atom.project.getPaths()[0]
    filePath = path.join(projectPath, '.build-tools.cson')
    config =
      file: 'build.xml'
      props:
        stdout:
          highlighting: 'hc'
          profile: 'java'
        output:
          linter:
            disable_trace: false
    Module.activate(Command)
    model = new Module.model([projectPath, filePath], config, null)

  it '::getCommandByIndex', ->
    waitsForPromise -> model.getCommandByIndex(0).then (c) ->
      expect(c.name).toBe 'ant clean'
      expect(c.project).toBe projectPath
      expect(c.source).toBe filePath
      expect(c.command).toBe 'ant -buildfile "build.xml" clean'

  it '::getCommandCount', ->
    waitsForPromise -> model.getCommandCount().then (count) ->
      expect(count).toBe 6

  it '::getCommandNames', ->
    waitsForPromise -> model.getCommandNames().then (names) ->
      expect(names).toEqual ['ant clean', 'ant compile', 'ant jar', 'ant run', 'ant clean-build', 'ant main']

  describe 'View', ->
    view = null
    hide = null
    show = null

    beforeEach ->
      model.config.file = ''
      model.config.props = {}
      view = new Module.view(model)
      hide = jasmine.createSpy('hide')
      show = jasmine.createSpy('show')
      spyOn(model, 'save')
      view.setCallbacks hide, show
      jasmine.attachToDOM(view.element)

    afterEach ->
      view.remove()

    describe 'On apply click', ->
      notify = null

      beforeEach ->
        notify = spyOn(atom.notifications, 'addError')
        view.find('#apply').click()

      it 'displays an error if path is empty', ->
        expect(notify).toHaveBeenCalledWith 'Path must not be empty'

      describe 'with a valid path', ->

        beforeEach ->
          view.path.getModel().setText('build2.xml')
          view.find('#apply').click()

        it 'sets the file path', ->
          expect(model.config.file).toBe 'build2.xml'

        it 'saves the config file', ->
          expect(model.save).toHaveBeenCalled()
