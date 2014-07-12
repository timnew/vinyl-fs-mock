pathUtil = require('path')
Type = require('type-of-is')

Buffer = require('buffer').Buffer
File = require('vinyl')

class PathNotExistsException extends Error
  constructor: (message) ->
    @name = this.constructor.name
    @message = message
    @stack = (new Error()).stack

class FileSystem
  constructor: (@fs) ->

  name: ->
    if(arguments.length == 0)
      @fs['.']
    else
      @fs['.'] = arguments[0]

  path: ->
    if(arguments.length == 0)
      @fs['..']
    else
      @fs['..'] = arguments[0]

  fullpath: ->
    pathUtil.join(@path(), @name())  

  _localPath: (path) ->
    localPath = pathUtil.relative @fullpath(), path
    localPath.split pathUtil.sep

  openFolder: (path, create) ->
    path = @_localPath(path) if typeof path is 'string'

    result = @fs

    for name in path
      unless result[name]?
        if create 
          result[name] = {} 
        else
          throw new PathNotExistsException("path #{path.join(pathUtil.sep)} is invalid")

      result = result[name]

    result

  writeFile: (path, content, create) ->
    path = @_localPath(path)
    
    filename = path.pop()

    folder = @openFolder(path, create)

    folder[filename] = content

  readFile: (path) ->
    path = @_localPath(path)
    
    filename = path.pop()

    folder = @openFolder(path)

    folder[filename]

  readFileAsBuffer: (path) ->
    content = @readFile(path)
    content = new Buffer(content) unless Buffer.isBuffer(content)
    content

  entryType: (path) ->        
    switch Type.of(@readFile(path)).name
      when 'Object'
        'folder'
      when 'Buffer'
        'file.binary'
      when 'String'
        'file.text'
      else
        'unknown'

  isFolder: (path) ->
    @entryType(path) == 'folder'

  isFile: (path) ->
    type = @entryType(path)         
    type[..4] == 'file.'

  subFileSystem: (path, create) ->
    folder = @openFolder(path, create)
    new FileSystem(folder)

  openFile: (path) ->
    new File 
      path: path
      contents: @readFileAsBuffer(path)

FileSystem.create = (name, path, fs) ->
  switch arguments.length
    when 1
      fs = name
      root = process.cwd()
      fs['.'] ?= pathUtil.basename root
      fs['..'] ?= pathUtil.dirname root
    when 2
      fs = path
      name = pathUtil.resolve name
      fs['.'] = pathUtil.basename name
      fs['..'] = pathUtil.dirname name
    when 3
      fs['.'] = name
      fs['..'] = path

  new FileSystem(fs)      

exports = module.exports = FileSystem.create
exports.FileSystem = FileSystem
exports.PathNotExistsException = PathNotExistsException
exports.File = File

