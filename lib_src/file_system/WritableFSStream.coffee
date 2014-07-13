FileSystem = require('./FileSystem')
Writable = require('readable-stream/writable')

class WritableFSStream extends Writable
  constructor: (@fileSystem) ->
    super
      objectMode: true
  
  _write: (file, encoding, next) ->    
    @fileSystem.writeFile file.path, @dumpFile(file), true

  dumpFile: (file) ->
    return file.contents.toString('utf8') if file.isBuffer()
    return '' if file.isNull()
    throw new Error('Not Supported')

module.exports = WritableFSStream

FileSystem.prototype.createWritableFSStream = (path, create) ->
  targetFs = if path? then this.subFileSystem(path,create) else this
  new WritableFSStream(targetFs)