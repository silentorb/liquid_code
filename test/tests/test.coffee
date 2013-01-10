console.log('Current directory: ' + process.cwd())
liquid_module = require '../../liquid.js'
Liquid = liquid_module.Liquid
fs = require("fs")
JavaScript = require("../../render-js.coffee").JavaScript
load_file = (filename) ->
  text = undefined
  text = fs.readFileSync(filename, "ascii")
  text.replace /\r?\n/g, "\n"

#code = load_file("./test/php_samples/middle_test.php")
#liquid = Liquid.parse(code)

code = load_file("./test/php_samples/middle_test.php")
liquid = Liquid.parse(code)
json = JSON.stringify(liquid, null, "  ")
fs.writeFileSync "./test/output/result.json", json, "ascii"
ice = JavaScript.create()
output = ice.render(liquid)
fs.writeFileSync "./test/output/code.js", output, "ascii"

module.exports =
  setUp: (callback) ->
    callback()

  tearDown: (callback) ->

    # clean up
    callback()
  test1: (test) ->


  test2: (test) ->
    code = load_file("./test/php_samples/simple_function.php")
    liquid = Liquid.parse(code)
    console.log liquid
    test.equals 2, 2
    test.done()