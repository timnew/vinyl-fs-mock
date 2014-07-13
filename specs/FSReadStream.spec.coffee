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

    it 'should expors.createReadStream factory function', ->
      fs = createFS('/',{})

      expect(fs.createReadStream).to.be.ok.and.to.be.a('function')

      fs.createReadStream().should.be.instanceOf(FSReadStream)
    
  describe 'read file system', ->    
    it 'should read all files', (done) ->
      fs = createFS 
        '.': ''
        '..': '/'
        'a.txt': 'text'
        'b.bin': new Buffer('binary')

      stream = fs.createReadStream()

      dumpStream stream, done, (files) ->
        a = files[0]
        a.should.be.an.instanceOf File
        a.path.should.equal '/a.txt'
        a.contents.toString('utf8').should.equal 'text'

        b = files[1]
        b.should.be.an.instanceOf File
        b.path.should.equal '/b.bin'
        b.contents.toString('utf8').should.equal 'binary'

    describe 'base path', ->
      fsData = ->
        '.': ''
        '..': '/'
        'src':
          'a.txt': 'text'
        
      it 'should read file', (done) ->
        fs = createFS fsData()
        
        stream = fs.createReadStream()

        dumpStream stream, done, (files) ->        
          file = files[0]
          
          file.path.should.equal '/src/a.txt'
          file.base.should.equal '/'

      it 'should read file', (done) ->
        fs = createFS fsData()
        
        stream = fs.createReadStream('src')

        dumpStream stream, done, (files) ->        
          file = files[0]
          
          file.path.should.equal '/src/a.txt'
          file.base.should.equal '/src'




