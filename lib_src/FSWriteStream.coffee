pathUtil = require('path')
FileSystem = require('./FileSystem')
Writable = require('readable-stream/writable')
deprecate = require('util-deprecate')

class FSWriteStream extends Writable
  constructor: (@fileSystem, folder, cwd) ->
    super
      objectMode: true
    
    @cwd = cwd ? @fileSystem.fullpath()
    folder = folder ? '.'

    @path = pathUtil.resolve(@cwd, folder)

    @fileSystem.openFolder(@path, true)
  
  _write: (file, encoding, next) ->     
    try
      @fileSystem.writeFile @resolvePath(file), @dumpFile(file), true
      next()
    catch ex
      next(ex)

  resolvePath: (file) ->
    return file.path unless @path?

    relativePath = pathUtil.relative file.base, file.path
    pathUtil.join @path, relativePath

  dumpFile: (file) ->
    return file.contents.toString('utf8') if file.isBuffer()
    return '' if file.isNull()
    throw new Error('Not Supported')

  onFinished: (done, callback) ->
    @on 'finish', =>
      try        
        callback @fileSystem.openFolder(@path)
        done()
      catch ex
        done(ex)
    
module.exports = FSWriteStream

createWriteStream = (path) ->
  new FSWriteStream(this, path)

FileSystem.prototype.createWriteStream = deprecate createWriteStream, 'fileSystem.createWriteStream is deprecated, use fileSystem.dest instead'

FileSystem.prototype.dest = (folder, options = {}) ->
  new FSWriteStream(this, folder, options.cwd)
  