pathUtil = require('path')
FileSystem = require('./FileSystem')

createFS = FileSystem.create = (name, path, fs) ->
  switch arguments.length
    when 1
      fs = name
      root = process.cwd()
      fs['.'] ?= pathUtil.basename root
      fs['..'] ?= pathUtil.dirname root
    when 2
      fs = path
      name = pathUtil.resolve name
      fs['.'] = pathUtil.basename name
      fs['..'] = pathUtil.dirname name
    when 3
      fs['.'] = name
      fs['..'] = path

  new FileSystem(fs)      

module.exports = createFS