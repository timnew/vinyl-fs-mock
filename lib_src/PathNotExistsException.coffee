class PathNotExistsException extends Error
  constructor: (message) ->
    super message
    @name = this.constructor.name
    @message = message
    @stack = (new Error()).stack

module.exports = PathNotExistsException
