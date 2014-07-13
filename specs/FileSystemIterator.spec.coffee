require('./spec_helper')

describe 'FileSystemIterator', ->
  {createFS} = require('../index')  
  FileSystemIterator = createFS.FileSystemIterator

  it 'should export class', ->
    expect(FileSystemIterator).to.be.ok    

  it 'should export createIterator factory method', ->
    fs = createFS('/',{})

    expect(fs.createIterator).to.be.ok.and.to.be.a('function')

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

      console.log files

      files.should.have.members [
        '/project/src/a.txt'
        '/project/src/f/b.txt'
        '/project/src/f/c.bin'
        '/project/src/f/ff/fff/ffff/d.txt'
      ]



