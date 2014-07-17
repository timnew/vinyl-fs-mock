require('./spec_helper')

dumpStream = (stream, done, callback) ->
  result = []
  
  stream.on 'end', ->      
    try  
      callback(result)   
      done()
    catch ex
      done(ex)

  stream.on 'readable', ->    
    while data = stream.read()      
      result.push data

  stream.resume()

describe 'FSReadStream', ->
  createFS = require('../index')  
  {FSReadStream, File} = createFS

  describe 'exports', ->
    it 'should export FSReadStream', ->
      expect(FSReadStream).to.exist.and.to.be.a('function')

    it 'should expors.createReadStream factory function', -> # Deprecated
      fs = createFS('/',{})

      expect(fs.createReadStream).to.be.ok.and.to.be.a('function')

      fs.createReadStream().should.be.instanceOf(FSReadStream)
    
    it 'should expors fs.src factory function', ->
      fs = createFS('/',{})

      expect(fs.src).to.be.ok.and.to.be.a('function')

      fs.src(['*.txt']).should.be.instanceOf(FSReadStream)
    
  describe 'read file system', ->    
    it 'should read all files', (done) ->
      fs = createFS 
        '.': ''
        '..': '/'
        'a.txt': 'text'
        'b.bin': new Buffer('binary')

      stream = fs.src('*')

      dumpStream stream, done, (files) ->
        files.should.have.length(2)

        a = files[0]
        a.should.be.an.instanceOf File
        a.path.should.equal '/a.txt'
        a.contents.toString('utf8').should.equal 'text'

        b = files[1]
        b.should.be.an.instanceOf File
        b.path.should.equal '/b.bin'
        b.contents.toString('utf8').should.equal 'binary'

    describe 'base and cwd', ->
      fsData = ->
        '.': 'project'
        '..': '/'
        'src':
          'a.txt': 'text'
        
      it 'should read file', (done) ->
        fs = createFS fsData()
        
        stream = fs.src('**')

        console.log stream.iterator

        dumpStream stream, done, (files) ->        
          files.should.have.length(1)

          file = files[0]          
          file.path.should.equal '/project/src/a.txt'
          file.base.should.equal '/project'
          file.cwd.should.equal '/project'

      it 'should set base', (done) ->
        fs = createFS fsData()
        
        stream = fs.src('**', cwd: 'src')

        dumpStream stream, done, (files) ->        
          file = files[0]
          expect(file).to.exist
          file.path.should.equal '/project/src/a.txt'
          file.base.should.equal '/project/src'
          file.cwd.should.equal '/project/src'

      it 'should infer base', (done) ->
        fs = createFS fsData()
        
        stream = fs.src('src/**')

        dumpStream stream, done, (files) ->        
          file = files[0]
          expect(file).to.exist
          file.path.should.equal '/project/src/a.txt'
          file.base.should.equal '/project/src'
          file.cwd.should.equal '/project'



