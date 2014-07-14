FileSystem = require('./FileSystem')
Type = require('type-of-is')

{createFilterChain} = require('./PathFilters')

class FileSystemIterator 
  constructor: (@fileSystem, basepath, patterns) ->
    @candidates = []

    unless patterns?
      patterns = basepath
      basepath = '.'      

    @basepath = basepath   

    @patterns = patterns ? []
    @patterns = [@patterns] unless Type.is(@patterns, Array)    
    
    @filterChain = createFilterChain(@basepath, @patterns)

    @traversal(@basepath)    

    @reset()

  traversal: (path) ->
    files = @fileSystem.listFiles(path)

    for file in files
      if @fileSystem.isFolder(file)
        @traversal(file)
      else
        @candidates.push file

    return    

  reset: ->    
    @result = @candidates.filter @filterChain

  next: ->
    @result.shift()

  batchFetch: ->
    @result

root.FileSystemIterator = FileSystemIterator

FileSystem.prototype.createIterator = (path, glob) ->
  new FileSystemIterator(this, path, glob)
  
module.exports = FileSystemIterator