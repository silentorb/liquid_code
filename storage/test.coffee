require 'coffee-trace'
liquid_module = require '../liquid.js'
Parser = liquid_module.Parser
PHP = liquid_module.PHP
JavaScript = liquid_module.JavaScript

fs = require 'fs'

load_file = (filename)->
  text = fs.readFileSync filename, 'ascii'
  text.replace(/\r?\n/g, "\n")

module.exports =
  setUp: (callback) ->
    @foo = "bar"
    callback()

  tearDown: (callback) ->    
    # clean up
    callback()

  test_find_scope: (test) ->
    range = Parser.find_scope('f(){ { } } {}', '{', '}', '{|}')
    test.equals range[0], 3
    test.equals range[1], 10
    test.done()
    
  test_locate_functions: (test) ->
    code = load_file './test/php_samples/simple_function.php'
    range = Parser.find_scope(code, '{', '}', '{|}')
    test.equals range[0], 30
    test.equals range[1], 74
    
    furnace = PHP.create()
    scopes = furnace.locate_functions(code)
    test.equals scopes.length, 1
    test.equals scopes[0].range[0], 30
    test.equals scopes[0].range[1], 74
    test.done()

  test_variables: (test) ->
    code = load_file './test/php_samples/variables.php' 
    furnace = PHP.create()
    scope = furnace.locate_functions(code)[0]
    furnace.find_variables scope
    test.equals scope.variables.length, 1
    test.done()

  test_full_convert: (test) ->
    code = load_file './test/php_samples/full_test.php'
    furnace = PHP.create()
    ice = JavaScript.create()
    liquid = furnace.liquify code
    code = ice.solidify liquid
    fs.writeFileSync './test/output/result.js', code, 'ascii'
    test.done()