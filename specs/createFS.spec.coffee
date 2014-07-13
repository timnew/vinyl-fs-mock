require('./spec_helper')

describe 'createFS', ->
  {createFS} = require('../index') 
  
  {FileSystem} = createFS
  
  it 'should export createFS function', ->
    expect(createFS).to.exist.and.to.be.a('function')
     
  describe 'create function', ->
    fsData = -> 
      'a.txt': 'text'
      'b.config': 'config'    

    it 'should create fs with 3 params', ->
      fs = createFS('sample', '/projects', fsData())
      fs.should.be.instanceOf FileSystem

      fs.directory.should.has.keys '.', '..', 'a.txt', 'b.config'
      fs.name().should.equal 'sample'
      fs.path().should.equal '/projects'

    it 'create fs with 2 params', ->
      fs = createFS('/projects/sample', fsData())
      fs.should.be.instanceOf FileSystem

      fs.directory.should.has.keys '.', '..', 'a.txt', 'b.config'
      fs.name().should.equal 'sample'
      fs.path().should.equal '/projects'
    
    describe 'create fs with 1 param', ->   
      it 'should take fs as root', ->
        fs = createFS(fsData())
        fs.should.be.instanceOf FileSystem      

        fs.directory.should.has.keys '.', '..', 'a.txt', 'b.config'
        fs.name().should.equal require('path').basename process.cwd()
        fs.path().should.equal require('path').dirname process.cwd()

      it 'should reserve existing data', ->
        data = fsData()
        data['.'] = 'project'
        data['..'] = '/projects'
        fs = createFS(data)
        fs.should.be.instanceOf FileSystem      

        fs.directory.should.has.keys '.', '..', 'a.txt', 'b.config'
        fs.name().should.equal 'project'
        fs.path().should.equal '/projects'
