exports = module.exports = require('./createFS')

exports.FileSystem = require('./FileSystem')
exports.PathNotExistsException = require('./PathNotExistsException')
exports.File = require('vinyl')
exports.FileSystemIterator = require('./FileSystemIterator')
exports.ReadableFSStream = require('./ReadableFSStream')
exports.WritableFSStream = require('./WritableFSStream')