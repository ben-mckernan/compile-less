{CompositeDisposable} = require 'atom'

less = require 'less'
fs = require 'fs'
mkdirp = require 'mkdirp'
path = require 'path'

module.exports =
    activate: (state) ->
        @subscriptions = new CompositeDisposable

        @subscriptions.add atom.commands.add 'atom-workspace',
            'core:save': => @render()

    deactivate: ->
        @subscriptions.dispose()

    render: ->
        editor = atom.workspace.getActiveTextEditor()
        return if not editor

        grammer = editor.getGrammar()
        return if grammer.name.toLowerCase() != 'less'

        sourceFile = editor.getPath()
        destinationFile = sourceFile.replace /\.[^\.]+$/, '.css'

        destinationFolder = path.dirname destinationFile

        fs.readFile sourceFile, (err, contents) =>
            return console.log err if err

            less.render contents.toString(), { paths: [destinationFolder], compress: true }
                .then (output) ->
                    mkdirp destinationFolder, (err) ->
                        if err
                            atom.notifications.addError err,
                                dismissiable: true
                        else
                            fs.writeFile destinationFile, output.css
