pathUtil = require('path')
FileSystem = require('./FileSystem')
Writable = require('readable-stream/writable')

class WritableFSStream extends Writable
  constructor: (@fileSystem, @basepath) ->
    super
      objectMode: true
  
  _write: (file, encoding, next) ->     
    try
      @fileSystem.writeFile @resolvePath(file), @dumpFile(file), true
      next()
    catch ex
      next(ex)

  resolvePath: (file) ->
    return file.path unless @basepath?

    relativePath = pathUtil.relative file.base, file.path
    pathUtil.join @basepath, relativePath

  dumpFile: (file) ->
    return file.contents.toString('utf8') if file.isBuffer()
    return '' if file.isNull()
    throw new Error('Not Supported')

module.exports = WritableFSStream

FileSystem.prototype.createWriteStream = (path) ->
  new WritableFSStream(this, path)