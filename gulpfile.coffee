require('coffee-script/register')

gulp = require('gulp')
del = require('del')
coffee = require('gulp-coffee')
bump = require('gulp-bump')
mocha = require('gulp-mocha')

argv = require('yargs')
  .alias('b', 'bump')
  .default('bump', 'patch')
  .describe('bump', 'bump [major|minor|patch|prerelease] version')  
  .argv

paths = 
  source:
    coffee: ['lib_src/*.coffee','lib_src/**/*.coffee']    
    spec: [['specs/*.spec.coffee', 'specs/**/*.spec.coffee'], {read: false}]
    manifest: ['./package.json']
  dest:
    root: '.'
    coffee: 'lib'      

gulp.task 'clean', ->
  del.sync(paths.dest.coffee)

gulp.task 'coffee', ->
  gulp.src paths.source.coffee
    .pipe coffee()
    .pipe gulp.dest paths.dest.coffee

gulp.task 'mocha', ['coffee'], ->
  gulp.src paths.source.spec[0], paths.source.spec[1]
    .pipe mocha({reporter: 'spec', growl: true})    

gulp.task 'build', ['clean', 'coffee', 'mocha']

gulp.task 'default', ['build']

gulp.task 'bump', ->  
  gulp.src paths.source.manifest
    .pipe bump { type: argv.bump }
    .pipe gulp.dest(paths.dest.root)  

gulp.task 'watch', ['build'], ->
  gulp.watch ['*.coffee', '**/*.coffee'], ['mocha']