FileSystem = require('./FileSystem')
Readable = require('readable-stream/readable')

class ReadableFSStream extends Readable
  constructor: (@fileSystem, @iterator) ->
    super
      objectMode: true

  _read: ->
    path = @iterator.next()    

    if path?
      file = @fileSystem.openAsVinylFile(path)      
      @push(file)
    else                  
      @push(null)

module.exports = ReadableFSStream

FileSystem.prototype.createReadableStream = ->
  new ReadableFSStream(this, @createIterator())