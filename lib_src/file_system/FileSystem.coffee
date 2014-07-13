pathUtil = require('path')
_ = require('lodash')
Type = require('type-of-is')

PathNotExistsException = require('./PathNotExistsException')
Buffer = require('buffer').Buffer
File = require('vinyl')

class FileSystem
  constructor: (@directory) ->

  name: ->
    if(arguments.length == 0)
      @directory['.']
    else
      @directory['.'] = arguments[0]

  path: ->
    if(arguments.length == 0)
      @directory['..']
    else
      @directory['..'] = arguments[0]

  fullpath: ->      
    pathUtil.join(@path(), @name())  

  _localPath: (path) ->    
    path = @resolvePath(path)
    localPath = pathUtil.relative @fullpath(), path
    localPath.split pathUtil.sep

  openFolder: (path, create) ->    
    path = @_localPath(path) if typeof path is 'string'  

    result = @directory    

    for name in path when name isnt ''
      unless result[name]?
        if create 
          result[name] = {} 
        else
          throw new PathNotExistsException("path #{path.join(pathUtil.sep)} is invalid")

      result = result[name]

    result

  resolvePath: (path) ->
    pathUtil.resolve(@fullpath(), path)

  listFiles: (path) ->    
    path = @resolvePath(path)    
    
    folder = @openFolder(path)  
    
    _.chain folder      
      .keys()
      .filter (name) ->
        name != '.' and name != '..'
      .map (name) ->        
        pathUtil.join(path, name)
      .value()

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

  deleteFile: (path) ->
    path = @_localPath(path)
    
    filename = path.pop()

    folder = @openFolder(path)

    delete folder[filename]

  exists: (path) ->
    try
      @openFolder path
      true
    catch ex
      return false if Type.is(ex, PathNotExistsException)

      throw ex
      
  readFileAsBuffer: (path) ->
    content = @readFile(path)
    content = new Buffer(content) unless Buffer.isBuffer(content)
    content

  readFileAsString: (path, encoding = 'utf8') ->
    content = @readFile(path)
    content = content.toString(encoding) unless _.isString(content)
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
    path = @resolvePath(path)
    folder = @openFolder(path, create)
    FileSystem.create path, folder

  openAsVinylFile: (path) ->
    new File 
      path: path
      contents: @readFileAsBuffer(path)  

module.exports = FileSystem
