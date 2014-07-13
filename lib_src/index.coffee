exports = module.exports = require('./createFS')

exports.FileSystem = require('./FileSystem')
exports.PathNotExistsException = require('./PathNotExistsException')
exports.File = require('vinyl')
exports.FileSystemIterator = require('./FileSystemIterator')
exports.FSReadStream = require('./FSReadStream')
exports.FSWriteStream = require('./FSWriteStream')