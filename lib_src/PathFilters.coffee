pathUtil = require('path')
Type = require('type-of-is')
Minimatch = require('minimatch').Minimatch
glob2base = require('glob2base')
_ = require('lodash')

log = (msg) ->
  log.log msg

log.enableLog = (enabled) ->
  if enabled
    log.log = console.log
  else
    log.log = ->

log.enableLog(false)

createFilterChain = (globs, options) ->
  return passThrough if globs.length is 0
  
  filter = terminator

  for glob in globs.slice(0).reverse()    
    verifier = createVerifier(glob, options.cwd)
    chainer = checkFilterType(glob)
    filter = chainer verifier, filter

  (input) ->    
    result = (filter(input, null) == true)
    log "\noutput: #{result}\n"

    result

positiveFiler = (verifier, next) ->
  (input, previousResult) ->  
    log "Positve: #{verifier.verifierName}"     
    log "  (#{input}, #{previousResult}) -> "
    switch previousResult
      when true # Confirmed by positive filter before
        log "    next(true): bypassed"
        next(input, true) # bypass check, pass result to next filter
      when null #  Haven't been confirmed by positive filter before        
        newResult = if verifier(input) then true else null # Confirmed or keep unknown
        log "    next(#{newResult}): checked"
        next(input, newResult) # Invoke next filter
      when false # should be never possible, guard logic        
        log "    false: determined"
        false
    
negativeFiler = (verifier, next) ->
  (input, previousResult) ->
    log "Negative: #{verifier.verifierName}"     
    log "  (#{input}, #{previousResult}) -> "
    switch previousResult
      when true, null # Havn't been rejected        
        if verifier(input) # verify
          log "    next(#{previousResult}): keep"
          next(input, previousResult) # Passed, keep previous result to invoked next filer
        else          
          log "    false: rejected"
          false # rejected determinedly
      when false # should be never possible, guard logic
        log "    false: determined"
        false

neutralFilter = (verifier, next) ->
  (input, previousResult) ->
    verifier(input, previousResult, next) # delegate to verifier

passThrough =  (input, previousResult) ->
  true # Confirm determinedly 

terminator = (input, result) ->
  log "terminator: #{result}"
  result      

createVerifier = (glob, basepath) ->  
  verifier = switch Type.of(glob)
              when RegExp  
                (file) ->   
                  glob.test file.path                
              when Function
                glob
              when String                
                glob = unrelativeGlob(glob, basepath)
                minimatch = new Minimatch(glob, {matchBase: true})
                base = pathUtil.resolve(glob2base.minimatch(minimatch.set))
                (file) ->
                  if minimatch.match file.path
                    file.base = base
                    true
                  else
                    false
  
  verifier.verifierName = glob
  verifier 

checkFilterType = (glob) ->
  if Type.is(glob, RegExp)
    negativeFiler 
  else if Type.is(glob, Function)
    neutralFilter
  else if glob[0] is '!'
    negativeFiler
  else
    positiveFiler
  
unrelativeGlob = (glob, basepath) ->
  return glob if Type.is(glob, RegExp) or Type.is(glob, Function) # Not applied

  if glob[0] == '!'
    prefix = '!'
    glob = glob[1..]
  else
    prefix = ''

  prefix + pathUtil.join(basepath, glob)

module.exports = {
  createFilterChain
  positiveFiler
  negativeFiler
  neutralFilter

  passThrough
  terminator

  createVerifier
  checkFilterType
  unrelativeGlob
  enableLog: log.enableLog
}
