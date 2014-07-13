vinyl-fs-mock [![NPM version][npm-image]][npm-url] [![Build Status][ci-image]][ci-url] [![Dependency Status][depstat-image]][depstat-url]
================

> A fake file system implementation, used for test code written based on [vinyl]() and [vinyl-fs](). 
> Useful for [gulp]() plugin unit test. 
> With [vinyl-fs-mock][homepage], all the file fixtures can be provided inline. So not more external fixtures needed.

## Install

Install using [npm][npm-url].

    $ npm install vinyl-fs-mock

## Usage

```coffeescript

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
```
 
## License
MIT

[![NPM downloads][npm-downloads]][npm-url]

[homepage]: https://github.com/timnew/vinyl-fs-mock

[npm-url]: https://npmjs.org/package/vinyl-fs-mock
[npm-image]: http://img.shields.io/npm/v/vinyl-fs-mock.svg?style=flat
[npm-downloads]: http://img.shields.io/npm/dm/vinyl-fs-mock.svg?style=flat

[ci-url]: https://drone.io/github.com/timnew/vinyl-fs-mock/latest
[ci-image]: https://drone.io/github.com/timnew/vinyl-fs-mock/status.png

[depstat-url]: https://gemnasium.com/timnew/vinyl-fs-mock
[depstat-image]: http://img.shields.io/gemnasium/timnew/vinyl-fs-mock.svg?style=flat
