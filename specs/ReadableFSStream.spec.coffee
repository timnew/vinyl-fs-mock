require('./spec_helper')

dumpStream = (stream, callback) ->
  result = []
  
  stream.on 'end', ->        
    callback(result)   

  stream.on 'readable', ->    
    while data = stream.read()      
      result.push data

  stream.resume()

describe 'ReadableFSStream', ->
  {createFS} = require('../index')  
  {ReadableFSStream, File} = createFS

  describe 'exports', ->
    it 'should export ReadableFSStream', ->
      expect(ReadableFSStream).to.exist.and.to.be.a('function')

    it 'should export createReadableStream factory function', ->
      fs = createFS('/',{})

      expect(fs.createReadableStream).to.be.ok.and.to.be.a('function')

      fs.createReadableStream().should.be.instanceOf(ReadableFSStream)
    
  describe 'read file system', ->
    fsData = ->
      '.': ''
      '..': '/'
      'a.txt': 'text'
      'b.bin': new Buffer('binary')

    it 'should read file system', (done) ->
      fs = createFS fsData()

      stream = fs.createReadableStream()

      dumpStream stream, (files) ->
        a = files[0]
        a.should.be.an.instanceOf File
        a.path.should.equal '/a.txt'
        a.contents.toString('utf8').should.equal 'text'

        b = files[1]
        b.should.be.an.instanceOf File
        b.path.should.equal '/b.bin'
        b.contents.toString('utf8').should.equal 'binary'

        done()