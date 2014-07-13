FileSystem = require('./FileSystem')
Readable = require('readable-stream/readable')

class ReadableFSStream extends Readable
  constructor: (@fs, @iterator) ->
    super
      objectMode: true

  _read: ->
    path = @iterator.next()    

    if path?
      file = @fs.openAsVinylFile(path)      
      @push(file)
    else                  
      @push(null)

module.exports = ReadableFSStream

FileSystem.prototype.createReadableStream = ->
  new ReadableFSStream(this, @createIterator())