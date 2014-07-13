require('./spec_helper')

describe 'WritableFSStream', ->
  {createFS} = require('../index')  
  {WritableFSStream, File} = createFS

  describe 'exports', ->
    it 'should export WritableFSStream', ->
      expect(WritableFSStream).to.exist.and.to.be.a('function')

    it 'should export createWritableFSStream factory function', ->
      fs = createFS('/',{})

      expect(fs.createWritableFSStream).to.be.ok.and.to.be.a('function')

      fs.createWritableFSStream().should.be.instanceOf(WritableFSStream)
    
  describe 'createWritableFSStream', ->
    fsData = ->
      '.': 'src'
      '..': '/project'
      'css': 
        'a.css': 'a'
      'js': 
        'b.js': 'b'

    it 'should create file system', ->
      fs = createFS fsData()

      stream = fs.createWritableFSStream()

      stream.fileSystem.fullpath().should.equal '/project/src'
    
    it 'should create file system based on given path', ->
      fs = createFS fsData()

      stream = fs.createWritableFSStream('css')

      stream.fileSystem.fullpath().should.equal '/project/src/css'

    it 'should create folder when necessary', ->
      fs = createFS fsData()

      stream = fs.createWritableFSStream('html', true)

      stream.fileSystem.fullpath().should.equal '/project/src/html'
  
  describe 'write file', ->
    fsData = ->
      '.': 'src'
      '..': '/project'
      'css': 
        'a.css': 'a'
      'js': 
        'b.js': 'b'    

    createFile = (path, content) ->
      new File
        path: path
        contents: if content? then new Buffer(content) else null

    it 'should write file', ->
      fs = createFS fsData()

      stream = fs.createWritableFSStream()
      
      stream.write createFile('/project/src/css/a.css','css')

      fs.readFile('/project/src/css/a.css').should.equal 'css'

    it 'should write empty file', ->
      fs = createFS fsData()

      stream = fs.createWritableFSStream()
      
      stream.write createFile('/project/src/css/a.css', null)

      fs.readFile('/project/src/css/a.css').should.equal ''

    it 'should create new file', ->
      fs = createFS fsData()

      stream = fs.createWritableFSStream()
      
      stream.write createFile('/project/src/readme', 'readme')

      fs.readFile('/project/src/readme').should.equal 'readme'
   
    it 'should create folder when necessary', ->
      fs = createFS fsData()

      stream = fs.createWritableFSStream()
      
      stream.write createFile('/project/src/html/c.html', 'c')

      fs.readFile('/project/src/html/c.html').should.equal 'c'

