#console.log('Current directory: ' + process.cwd())
liquid_module = require './liquid.js'
Liquid = liquid_module.Liquid
fs = require("fs")
JavaScript = require("./render-js.coffee").JavaScript
CoffeeScript = require("./render-coffee.coffee").CoffeeScript
load_file = (filename) ->
  text = undefined
  text = fs.readFileSync(filename, "ascii")
  text.replace /\r?\n/g, "\n"

code = load_file(process.argv[2])
liquid = Liquid.parse(code)
json = JSON.stringify(liquid, null, "  ")
fs.writeFileSync "./test/output/result.json", json, "ascii"
ice = CoffeeScript.create()
output = ice.render(liquid)
fs.writeFileSync process.argv[3], output, "ascii"
