FileSystem = require('./FileSystem')

class FileSystemIterator 
  constructor: (@fileSystem, @basepath = '.') ->
    @fileList = []

    @traversal(@basepath)

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

FileSystem.prototype.createIterator = (path) ->
  new FileSystemIterator(this, path)
  
module.exports = FileSystemIterator