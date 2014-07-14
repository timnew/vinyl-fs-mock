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
    paths = 
      root: '/project'
      a: '/project/a.txt'
      b: '/project/sub/b.txt'
      c: '/c.txt'
      d: '/project/d.js'
      e: '/project/another/sub/e.txt'

    it 'should load all', ->
      filter = createFilterChain(paths.root, [])

      filter(paths.a).should.be.true
      filter(paths.b).should.be.true
      filter(paths.c).should.be.true
      filter(paths.d).should.be.true      
      filter(paths.e).should.be.true      
  
    describe 'single glob', ->
     
      it 'should check positive glob', ->
        filter = createFilterChain(paths.root, ['*.txt'])

        filter(paths.a).should.be.true
        filter(paths.b).should.be.false
        filter(paths.c).should.be.false
        filter(paths.d).should.be.false
        filter(paths.e).should.be.false

      it 'should check positive glob **', ->
        filter = createFilterChain(paths.root, ['**/*.txt'])

        filter(paths.a).should.be.true
        filter(paths.b).should.be.true
        filter(paths.c).should.be.false
        filter(paths.d).should.be.false
        filter(paths.e).should.be.true
      
      it 'should check response to base path', ->
        filter = createFilterChain('/project/sub', ['*.txt'])

        filter(paths.a).should.be.false
        filter(paths.b).should.be.true
        filter(paths.c).should.be.false
        filter(paths.d).should.be.false
        filter(paths.e).should.be.false
      
    describe 'multiple globs', ->
      it 'should accept 2 positive globs', ->
        filter = createFilterChain(paths.root, ['*.txt', '*.js'])

        filter(paths.a).should.be.true
        filter(paths.b).should.be.false
        filter(paths.c).should.be.false
        filter(paths.d).should.be.true
        filter(paths.e).should.be.false

      it 'should apply negative globs', ->
        filter = createFilterChain(paths.root, ['**/*.txt', '!**/b.txt'])

        filter(paths.a).should.be.true
        filter(paths.b).should.be.false
        filter(paths.c).should.be.false
        filter(paths.d).should.be.false
        filter(paths.e).should.be.true
    
      it 'should be order independent', ->
        filter = createFilterChain(paths.root, ['!**/b.txt', '**/*.txt'])

        filter(paths.a).should.be.true
        filter(paths.b).should.be.false
        filter(paths.c).should.be.false
        filter(paths.d).should.be.false
        filter(paths.e).should.be.true

  describe 'filter builders', ->

  describe 'special filters', ->
      
    it 'should always yield true', ->
      passThrough('/a.txt', true).should.be.true
      passThrough('/a.txt', false).should.be.true
      passThrough('/a.txt', null).should.be.true

    it 'should yield previous', ->
      expect(terminator('/a.txt', true)).to.be.true
      expect(terminator('/a.txt', false)).to.be.false
      expect(terminator('/a.txt', null)).to.be.null

  describe 'helpers', ->

    describe 'createVerifier', ->

    describe 'checkFilterType', ->

    describe 'unrelativeGlob', ->