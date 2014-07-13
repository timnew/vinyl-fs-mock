FileSystem = require('./FileSystem')

class FileSystemIterator 
  constructor: (@fs) ->
    @fileList = []

    @traversal('.')

  traversal: (path) ->
    files = @fs.listFiles(path)

    for file in files
      if @fs.isFolder(file)
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