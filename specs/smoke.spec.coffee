require('./spec_helper')
spy = require('through2-spy')

describe 'smoke test', ->
  createFS = require('../index')
  coffee = require('gulp-coffee')
  
  it 'should replace gulp', (done) ->  
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
        
    fs.createReadStream 'src/coffee'
      # .pipe spy.obj (file) ->
      #   console.log [file.base, file.path]
      .pipe coffee
        bare: true
      # .pipe spy.obj (file) ->
      #   console.log [file.base, file.path]
      .pipe fs.createWriteStream('dest/js', true)
      .on 'finish', ->
        try
          # console.log fs.directory
          # console.log fs.readFile('dest/js/sample.js')
          # console.log fs.readFile('dest/js/another.js')        
          fs.readFile('dest/js/sample.js').should.not.be.null
          fs.readFile('dest/js/another.js').should.not.be.null
          done()
        catch ex
          done ex