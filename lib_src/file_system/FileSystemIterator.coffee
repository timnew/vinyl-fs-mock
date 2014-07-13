FileSystem = require('./FileSystem')

class FileSystemIterator 
  constructor: (@fileSystem) ->
    @fileList = []

    @traversal('.')

  traversal: (path) ->
    files = @fileSystem.listFiles(path)

    for file in files
      if @fileSystem.isFolder(file)
        @traversal(file)
      else
        @fileList.push file

    @fileList

  next: ->
    @fileList.shift()

root.FileSystemIterator = FileSystemIterator

FileSystem.prototype.createIterator = ->
  new FileSystemIterator(this)
  
module.exports = FileSystemIterator