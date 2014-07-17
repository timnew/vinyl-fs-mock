require('./spec_helper')

describe 'smoke test', ->
  createFS = require('../index')
  coffee = require('gulp-coffee')
  
  it 'should mock gulp', (done) ->  
    fs = createFS
          src:
            coffee:
              'sample.coffee': """
                console.log 'Hello world'
              """
              'another.coffee': """
                fib = (n) ->
                  switch n
                    when 0, 1
                      1
                    else
                      fib(n) + fib(n-1)  
              """
        
    fs.src 'src/coffee/*.coffee'
      .pipe coffee
        bare: true
      .pipe fs.dest 'dest/js'
      .onFinished done, (folder) ->
        # console.log fs.directory  # Display whole tree of files
        folder.should.equal fs.openFolder('dest/js')                
        folder['sample.js'].should.not.be.null
        folder['another.js'].should.not.be.null
      