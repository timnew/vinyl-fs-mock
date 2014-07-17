require('./spec_helper')
_ = require('lodash')

describe 'FileSystemIterator', ->
  createFS = require('../index')  
  {FileSystemIterator} = createFS

  describe 'exports', ->
    it 'should export class', ->
      expect(FileSystemIterator).to.be.ok    

  describe 'should create iterator with proper config', ->

    it 'should create iterator', ->
      fs = createFS('/', {})    
      glob = ['*.js']

      iterator = new FileSystemIterator(fs, glob, cwd: '/')

      iterator.fileSystem.should.equal fs
      iterator.patterns.should.eql glob

    it 'should infer cwd iterator', ->
      fs = createFS('/', {})          
      
      iterator = new FileSystemIterator(fs, [])

      iterator.options.cwd.should.equal fs.fullpath()

    it 'should resolve cwd', ->
      fs = createFS('/project', {})          
      
      iterator = new FileSystemIterator(fs, [], cwd: 'sub')

      iterator.options.cwd.should.equal '/project/sub'

    it 'should not crash if glob path does not exist', ->
      new FileSystemIterator(createFS('/project', {}), ['/another/*.js'], cwd:'/')

  describe 'iterate through file system', ->

    fsData = ->
      '.': 'src'
      '..': '/project'
      'a.txt': 'a'
      'f': 
        'b.txt': 'b'
        'c.bin': new Buffer('c')
        'ff':
          'fff':
            'ffff':
              'd.txt': 'd'
            'empty': {}
     
    extractPath = (array) ->
      _.map(array, _.property('path'))
      

    it 'should iterate all files', ->
      fs = createFS fsData()

      iterator = new FileSystemIterator(fs, [])

      files = []
      
      while next = iterator.next() 
        files.push next      

      extractPath(files).should.have.members [
        '/project/src/a.txt'
        '/project/src/f/b.txt'
        '/project/src/f/c.bin'
        '/project/src/f/ff/fff/ffff/d.txt'
      ]

    it 'should be able to batch fetch', ->
      fs = createFS fsData()
      
      iterator = new FileSystemIterator(fs, [])

      files = iterator.batchFetch()
      extractPath(files).should.have.members [
        '/project/src/a.txt'
        '/project/src/f/b.txt'
        '/project/src/f/c.bin'
        '/project/src/f/ff/fff/ffff/d.txt'
      ]      

    it 'should apply glob', ->
      fs = createFS fsData()

      iterator = new FileSystemIterator(fs, ['**.txt','**/*.txt', '!**/d.txt'])

      files = iterator.batchFetch()      
      extractPath(files).should.have.members [
        '/project/src/a.txt'
        '/project/src/f/b.txt'
      ]



