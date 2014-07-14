require('./spec_helper')

describe 'FileSystemIterator', ->
  createFS = require('../index')  
  {FileSystemIterator} = createFS

  describe 'exports', ->
    it 'should export class', ->
      expect(FileSystemIterator).to.be.ok    

    it 'should export createIterator factory method', ->
      fs = createFS('/',{})

      expect(fs.createIterator).to.be.ok.and.to.be.a('function')

      fs.createIterator().should.be.instanceOf(FileSystemIterator)


  describe 'should create iterator with proper config', ->
    fs = createFS('/', { })
    base = '/'
    glob = ['*.js']

    it 'should set basepath and patterns', ->
      interator = fs.createIterator(base, glob)

      interator.fileSystem.should.equal fs
      interator.basepath.should.equal base
      interator.patterns.should.eql glob

    it 'should infer basepath', ->
      interator = fs.createIterator(glob)

      interator.fileSystem.should.equal fs
      interator.basepath.should.equal '.'
      interator.patterns.should.eql glob
     
    it 'should infer both basepath and patterns', ->
      interator = fs.createIterator()

      interator.fileSystem.should.equal fs
      interator.basepath.should.equal '.'
      interator.patterns.should.eql []
     
    it 'should normalize patterns to array', ->
      interator = fs.createIterator(base, '*.js')

      interator.fileSystem.should.equal fs
      interator.basepath.should.equal base
      interator.patterns.should.eql glob

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

    it 'should iterate all files', ->
      fs = createFS fsData()

      iterator = fs.createIterator()

      files = []
      
      while next = iterator.next() 
        files.push next      

      files.should.have.members [
        '/project/src/a.txt'
        '/project/src/f/b.txt'
        '/project/src/f/c.bin'
        '/project/src/f/ff/fff/ffff/d.txt'
      ]

    it 'should be able to batch fetch', ->
      fs = createFS fsData()
      
      iterator = fs.createIterator()

      iterator.batchFetch().should.have.members [
        '/project/src/a.txt'
        '/project/src/f/b.txt'
        '/project/src/f/c.bin'
        '/project/src/f/ff/fff/ffff/d.txt'
      ]      

    it 'should apply glob', ->
      fs = createFS fsData()

      iterator = fs.createIterator(['*.txt', '!d.txt'])
      iterator.batchFetch().should.have.members [
        '/project/src/a.txt'
        '/project/src/f/b.txt'       
      ]



