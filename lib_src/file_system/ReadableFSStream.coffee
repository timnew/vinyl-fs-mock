FileSystem = require('./FileSystem')
Readable = require('readable-stream/readable')

class ReadableFSStream extends Readable
  constructor: (@fileSystem, @iterator, @basepath) ->
    super
      objectMode: true

  _read: ->
    path = @iterator.next()    

    if path?
      file = @fileSystem.openAsVinylFile path
      file.base = @basepath if @basepath?
      @push(file)
    else                  
      @push(null)

module.exports = ReadableFSStream

FileSystem.prototype.createReadStream = (path) ->
  new ReadableFSStream(this, @createIterator(path), path)