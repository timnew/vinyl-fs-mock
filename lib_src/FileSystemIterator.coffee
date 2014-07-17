FileSystem = require('./FileSystem')
Type = require('type-of-is')
deprecate = require('util-deprecate')

_ = require('lodash')
  
{createFilterChain} = require('./PathFilters')

class FileSystemIterator 
  constructor: (@fileSystem, @patterns, options = {}) ->        

    @options = _.defaults options, 
      cwd: '.'

    @options.cwd = @fileSystem.resolvePath(@options.cwd)
      
    @patterns = [@patterns] unless Type.is(@patterns, Array)    

    @filterChain = createFilterChain(@patterns, @options)

    @candidates = []
    @traversal(@options.cwd, @options.cwd)    

    @reset()

  traversal: (path, cwd) ->
    return unless @fileSystem.exists path      

    files = @fileSystem.listFiles(path)

    for file in files
      if @fileSystem.isFolder(file)
        @traversal(file)
      else
        @candidates.push
          path: file
          cwd: cwd
          contents: undefined 
          base: undefined # populated in filter chain

    return   

  reset: ->    
    @result = @candidates.filter @filterChain

  next: ->
    @result.shift()

  batchFetch: ->
    @result
  
module.exports = FileSystemIterator