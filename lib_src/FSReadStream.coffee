pathUtil = require('path')
File = require('vinyl')
FileSystem = require('./FileSystem')
Readable = require('readable-stream/readable')
FileSystemIterator = require('./FileSystemIterator')
_ = require('lodash')
deprecate = require('util-deprecate')

class FSReadStream extends Readable
  constructor: (@fileSystem, @iterator, @defaults = {}) ->
    super
      objectMode: true

    _.defaults @defaults, 
      cwd: @fileSystem.fullpath()
      base: @fileSystem.fullpath()      

    @defaults.cwd = @fileSystem.resolvePath(@defaults.cwd)
    @defaults.base = @fileSystem.resolvePath(@defaults.base)
    
  createFile: (file) ->        
    new File _.merge {}, @defaults, file , contents: @fileSystem.readFileAsBuffer(file.path)
    
  _read: ->
    path = @iterator.next()    
    
    if path?
      @push @createFile path
    else
      @push null
    
module.exports = FSReadStream

createReadStreamDeprecated = (path = '.') ->
  iterator = new FileSystemIterator(this, [], cwd: path)
  new FSReadStream(this, iterator, cwd: path)

FileSystem.prototype.createReadStream = deprecate createReadStreamDeprecated, 'fileSystem.createReadStream is deprecated, use fileSystem.src instead.'

FileSystem.prototype.src = (patterns, options) ->
  iterator = new FileSystemIterator this, patterns, options

  new FSReadStream(this, iterator, options)

