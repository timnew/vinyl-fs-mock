require('./spec_helper')

describe 'FSWriteStream', ->
  createFS = require('../index')  
  {FSWriteStream, File} = createFS

  describe 'exports', ->
    it 'should export FSWriteStream', ->
      expect(FSWriteStream).to.exist.and.to.be.a('function')

    it 'should export createWriteStream factory function', ->
      fs = createFS('/',{})

      expect(fs.createWriteStream).to.be.ok.and.to.be.a('function')

      fs.createWriteStream().should.be.instanceOf(FSWriteStream)
  
  describe 'write file', ->
    fsData = ->
      '.': 'project'
      '..': '/'
      'src':
        'css': 
          'a.css': 'a'
        'js': 
          'b.js': 'b'    

    createFile = (path, basepath, content) ->
      unless content?
        content = basepath
        basepath = undefined

      new File
        path: path
        base :basepath
        contents: if content? then new Buffer(content) else null

    describe 'content', ->

      it 'should write file', ->
        fs = createFS fsData()

        stream = fs.createWriteStream()
        
        stream.write createFile('/project/src/css/a.css','css')

        fs.readFile('/project/src/css/a.css').should.equal 'css'

      it 'should write empty file', ->
        fs = createFS fsData()

        stream = fs.createWriteStream()
        
        stream.write createFile('/project/src/css/a.css', null)

        fs.readFile('/project/src/css/a.css').should.equal ''

    describe 'create path', ->
      
      it 'should create new file', ->
        fs = createFS fsData()

        stream = fs.createWriteStream()
        
        stream.write createFile('/project/src/readme', 'readme')

        fs.readFile('/project/src/readme').should.equal 'readme'
     
      it 'should create folder when necessary', ->
        fs = createFS fsData()

        stream = fs.createWriteStream()
        
        stream.write createFile('/project/src/html/c.html', 'c')

        fs.readFile('/project/src/html/c.html').should.equal 'c'

      it 'should create folder when created', ->
        fs = createFS fsData()

        stream = fs.createWriteStream('x/y/z')
        
        fs.isFolder('x/y/z').should.be.true

    describe 'relative path', ->

      it 'should override path', ->
        fs = createFS fsData()

        stream = fs.createWriteStream('/project/dest')
        
        stream.write createFile('/project/src/readme', '/project/src', 'readme')

        fs.readFile('/project/dest/readme').should.equal 'readme'

    describe 'events', ->
      it 'should fire finish event', (done) ->
        fs = createFS fsData()

        stream = fs.createWriteStream()
        
        stream.on 'finish', ->                
          done()
        
        stream.end()

    describe 'onFinished', ->
      it 'should send dest folder to callback and invoke done automatically', (done) ->
        fs = createFS fsData()

        stream = fs.createWriteStream('/project/dest')
        
        stream.onFinished done, (folder) ->
          expect(folder).to.equal fs.openFolder('/project/dest')
        
        stream.end()

      it 'should be okay if not done callback is provided', (done) ->
        fs = createFS fsData()

        stream = fs.createWriteStream('/project/dest')
        
        stream.onFinished (folder) ->
          done()
        
        stream.end()