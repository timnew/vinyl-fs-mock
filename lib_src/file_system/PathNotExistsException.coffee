class PathNotExistsException extends Error
  constructor: (message) ->
    @name = this.constructor.name
    @message = message
    @stack = (new Error()).stack

module.exports = PathNotExistsException
