pathUtil = require('path')
FileSystem = require('./FileSystem')
Writable = require('readable-stream/writable')
deprecate = require('util-deprecate')

class FSWriteStream extends Writable
  constructor: (@fileSystem, basepath) ->
    super
      objectMode: true

    @basepath = if basepath?
                  pathUtil.resolve(@fileSystem.fullpath(), basepath)
                else
                  @fileSystem.fullpath()

    @fileSystem.openFolder(@basepath, true)
  
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

  onFinished: (done, callback) ->
    @on 'finish', =>
      try        
        callback @fileSystem.openFolder(@basepath)
        done()
      catch ex
        done(ex)
  
  
module.exports = FSWriteStream

createWriteStream = (path) ->
  new FSWriteStream(this, path)

FileSystem.prototype.createWriteStream = deprecate createWriteStream, 'fileSystem.createWriteStream is deprecated, use fileSystem.dest instead'

