var MetaHub = require('../bloom/lib/metahub.js');
MetaHub.import_all();

var PEG = require('pegjs');
var fs = require('fs');

function load_file(filename) {
    var text;
    text = fs.readFileSync(filename, 'ascii');
    return text.replace(/\r?\n/g, "\n");
}

var header = load_file('lib.js');
var rules = load_file('php.peg');
var parser = PEG.buildParser('{' + header + '}' + rules);


var Liquid = Meta_Object.subclass('Liquid', {

});

Liquid.parse = function (code) {
    try {
        return parser.parse(code);
    }
    catch (ex) {
        console.log(ex);
    }
}

module.exports = MetaHub.current_module.classes;