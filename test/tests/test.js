var JavaScript, Liquid, code, fs, ice, json, liquid, liquid_module, load_file, output;

console.log('Current directory: ' + process.cwd());

liquid_module = require('../../liquid.js');

Liquid = liquid_module.Liquid;

fs = require("fs");

JavaScript = require("../../render-js.coffee").JavaScript;

load_file = function(filename) {
  var text;
  text = void 0;
  text = fs.readFileSync(filename, "ascii");
  return text.replace(/\r?\n/g, "\n");
};

code = load_file("./test/php_samples/middle_test.php");

liquid = Liquid.parse(code);

json = JSON.stringify(liquid, null, "  ");

fs.writeFileSync("./test/output/result.json", json, "ascii");

ice = JavaScript.create();

output = ice.render(liquid);

fs.writeFileSync("./test/output/code.js", output, "ascii");

module.exports = {
  setUp: function(callback) {
    return callback();
  },
  tearDown: function(callback) {
    return callback();
  },
  test1: function(test) {},
  test2: function(test) {
    code = load_file("./test/php_samples/simple_function.php");
    liquid = Liquid.parse(code);
    console.log(liquid);
    test.equals(2, 2);
    return test.done();
  }
};
