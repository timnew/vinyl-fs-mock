pathUtil = require('path')
File = require('vinyl')
FileSystem = require('./FileSystem')
Readable = require('readable-stream/readable')
deprecate = require('util-deprecate')

class FSReadStream extends Readable
  constructor: (@fileSystem, @iterator, basepath) ->
    super
      objectMode: true

    @basepath = if basepath?
                  pathUtil.resolve(@fileSystem.fullpath(), basepath)
                else
                  @fileSystem.fullpath()

  createFile: (path) ->
    new File
      path: path
      base: @basepath
      cwd: @fileSystem.fullpath()
      contents: @fileSystem.readFileAsBuffer(path)  
    
  _read: ->
    path = @iterator.next()    
    
    if path?
      @push @createFile path
    else
      @push null
    
module.exports = FSReadStream

createReadStream = (path = '.') ->
  new FSReadStream(this, @createIterator(path, []), path)

FileSystem.prototype.createReadStream = deprecate createReadStream, 'fileSystem.createReadStream is deprecated, use fileSystem.src instead.'