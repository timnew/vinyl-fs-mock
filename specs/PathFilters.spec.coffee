require('./spec_helper')

describe 'PathFilers', ->
  PathFilers = require('../index').PathFilers

  {
    createFilterChain

    positiveFiler
    negativeFiler
    neutralFilter

    passThrough
    terminator

    createVerifier
    checkFilterType
    unrelativeGlob  
    enableLog  
  } = PathFilers

  makeFile = (path) ->
    {
      path: path
    }

  describe 'exports', ->

    it 'should exports module', ->
      expect(PathFilers).to.exist      

    it 'should exports createFilterChain', ->      
      expect(createFilterChain).to.exist.and.to.be.a 'function'

    it 'should exports filter builders', ->      
      expect(positiveFiler).to.exist.and.to.be.a 'function'
      expect(negativeFiler).to.exist.and.to.be.a 'function'
      expect(neutralFilter).to.exist.and.to.be.a 'function'
    
    it 'should exports special filters', ->  
      expect(passThrough).to.exist.and.to.be.a 'function'
      expect(terminator).to.exist.and.to.be.a 'function'
    
    it 'should exports helpers', ->
      expect(createVerifier).to.exist.and.to.be.a 'function'
      expect(checkFilterType).to.exist.and.to.be.a 'function'
      expect(unrelativeGlob).to.exist.and.to.be.a 'function'
      expect(enableLog).to.exist.and.to.be.a 'function'
  
  describe 'createFilterChain', ->
 
    options = 
      cwd: '/project'

    paths =       
      a: makeFile '/project/a.txt'
      b: makeFile '/project/sub/b.txt'
      c: makeFile '/c.txt'
      d: makeFile '/project/d.js'
      e: makeFile '/project/another/sub/e.txt'

    it 'should load all', ->
      filter = createFilterChain([], options)

      filter(paths.a).should.be.true
      filter(paths.b).should.be.true
      filter(paths.c).should.be.true
      filter(paths.d).should.be.true      
      filter(paths.e).should.be.true      
  
    describe 'single glob', ->
     
      it 'should check positive glob', ->
        filter = createFilterChain(['*.txt'], options)

        filter(paths.a).should.be.true
        filter(paths.b).should.be.false
        filter(paths.c).should.be.false
        filter(paths.d).should.be.false
        filter(paths.e).should.be.false

      it 'should check positive glob **', ->
        filter = createFilterChain(['**/*.txt'], options)

        filter(paths.a).should.be.true
        filter(paths.b).should.be.true
        filter(paths.c).should.be.false
        filter(paths.d).should.be.false
        filter(paths.e).should.be.true
      
      it 'should check response to base path', ->
        filter = createFilterChain(['*.txt'], cwd: '/project/sub')

        filter(paths.a).should.be.false
        filter(paths.b).should.be.true
        filter(paths.c).should.be.false
        filter(paths.d).should.be.false
        filter(paths.e).should.be.false
      
    describe 'multiple globs', ->
      it 'should accept 2 positive globs', ->
        filter = createFilterChain(['*.txt', '*.js'], options)

        filter(paths.a).should.be.true
        filter(paths.b).should.be.false
        filter(paths.c).should.be.false
        filter(paths.d).should.be.true
        filter(paths.e).should.be.false

      it 'should apply negative globs', ->
        filter = createFilterChain(['**/*.txt', '!**/b.txt'], options)

        filter(paths.a).should.be.true
        filter(paths.b).should.be.false
        filter(paths.c).should.be.false
        filter(paths.d).should.be.false
        filter(paths.e).should.be.true
    
      it 'should be order independent', ->
        filter = createFilterChain(['!**/b.txt', '**/*.txt'], options)

        filter(paths.a).should.be.true
        filter(paths.b).should.be.false
        filter(paths.c).should.be.false
        filter(paths.d).should.be.false
        filter(paths.e).should.be.true

  describe 'filter builders', ->

  describe 'verifiers', ->
    describe 'glob verifier', ->      
      it 'should create verifier', ->
        verifier = createVerifier '/project/*.js', '/project'
        expect(verifier).to.be.exist.and.to.be.a 'function'

      it 'should check whether file path is matched', ->
        verifier = createVerifier '*.js', '/project'

        verifier(makeFile('/project/a.js')).should.be.true
        verifier(makeFile('/project/b.txt')).should.be.false

      it 'should set base for file when matched', ->
        verifier = createVerifier 'sub/*.js', '/project'

        file = makeFile '/project/sub/a.js'

        verifier file
        
        file.base.should.equal '/project/sub'

      it 'should not change base for file when not matched', ->
        verifier = createVerifier 'sub/*.js', '/project'

        file = makeFile '/project/sub/b.txt'

        verifier file
        
        expect(file.base).to.be.undefined

  describe 'special filters', ->      
    it 'should always yield true', ->
      passThrough(makeFile('/a.txt'), true).should.be.true
      passThrough(makeFile('/a.txt'), false).should.be.true
      passThrough(makeFile('/a.txt'), null).should.be.true

    it 'should yield previous', ->
      expect(terminator(makeFile('/a.txt'), true)).to.be.true
      expect(terminator(makeFile('/a.txt'), false)).to.be.false
      expect(terminator(makeFile('/a.txt'), null)).to.be.null

  describe 'helpers', ->

    describe 'createVerifier', ->

    describe 'checkFilterType', ->

    describe 'unrelativeGlob', ->