// Generated by CoffeeScript 1.3.3
(function() {
  var Furnace, Ice, JavaScript, Liquid, MetaHub, PHP, Parser, Scope,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  MetaHub = require('../bloom/lib/metahub.js');

  MetaHub.import_all();

  String.prototype.match_all = function(regex, action) {
    var match, text, _results;
    text = this.toString();
    _results = [];
    while (match = regex.exec(text)) {
      _results.push(action(match));
    }
    return _results;
  };

  String.prototype.replace_all = function(pattern, replacement) {
    var text;
    text = this.toString();
    while (text.indexOf(pattern) >= 0) {
      text = text.replace(pattern, replacement);
    }
    return text;
  };

  String.prototype.insert = function(index, text) {
    return this.slice(0, index) + text + this.slice(index);
  };

  Parser = {
    find_scope: function(source, open, close, pattern) {
      var depth, end, match, regex, start;
      depth = 0;
      start = -1;
      end = 0;
      regex = new RegExp(pattern, 'g');
      while (match = regex.exec(source)) {
        if (match[0] === open) {
          ++depth;
          if (start === -1) {
            start = match.index;
          }
        } else {
          if (--depth === 0) {
            end = regex.lastIndex;
            return [start, end];
          }
        }
      }
    },
    regex_stack: function(text, patterns) {
      var pattern, _i, _len;
      for (_i = 0, _len = patterns.length; _i < _len; _i++) {
        pattern = patterns[_i];
        if (typeof pattern[0] === 'string') {
          text = text.replace_all(pattern[0], pattern[1]);
        } else {
          text = text.replace(pattern[0], pattern[1]);
        }
      }
      return text;
    }
  };

  Liquid = Meta_Object.subclass('Liquid', Scope = Meta_Object.subclass('Scope', {
    prefix: '',
    body: '',
    range: [],
    variables: [],
    parameters: [],
    initialize: function(prefix, body, range) {
      this.prefix = prefix;
      this.body = body;
      this.range = range;
    }
  }));

  Furnace = Meta_Object.subclass('Furnace', {
    initialize: function() {},
    locate_functions: function(source) {},
    liquify: function(source) {
      var liquid, scope, _i, _len, _ref;
      liquid = Liquid.create();
      liquid.source = source;
      liquid.scopes = this.locate_functions(source);
      _ref = liquid.scopes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        scope = _ref[_i];
        this.find_variables(scope);
        this.process_scope(scope);
      }
      return liquid;
    },
    process_scope: function(scope) {}
  });

  Ice = Meta_Object.subclass('Ice', {
    initialize: function() {},
    solidify: function(liquid) {
      var result, scope, _i, _len, _ref;
      result = '';
      _ref = liquid.scopes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        scope = _ref[_i];
        result += scope.prefix + '{' + scope.body + '}' + "\n\n";
      }
      return result;
    }
  });

  PHP = Furnace.subclass('PHP', {
    locate_functions: function(source) {
      var pattern, scopes;
      scopes = [];
      pattern = /((?:(?:(?:public)|(?:private)|(?:protected)|(?:static))+\s*)?function\s+\w+\s*\((.*?)\))/g;
      source.match_all(pattern, function(match) {
        var body, range, scope;
        console.log(match.index);
        range = Parser.find_scope(source.substring(match.index), '{', '}', '{|}');
        body = source.substring(range[0] + 1 + match.index, range[1] - 1 + match.index);
        scope = Scope.create(match[1], body, range);
        scope.parameters = match[2].match(/[\$\w]+/g) || [];
        return scopes.push(scope);
      });
      return scopes;
    },
    find_variables: function(scope) {
      var match, matches, var_defines, var_string, variable, variables, _i, _j, _len, _len1;
      variables = [];
      matches = scope.body.match(/\$\w+/g);
      if (matches) {
        for (_i = 0, _len = matches.length; _i < _len; _i++) {
          match = matches[_i];
          if (__indexOf.call(variables, match) < 0) {
            variables.push(match);
          }
        }
        var_defines = [];
        for (_j = 0, _len1 = variables.length; _j < _len1; _j++) {
          variable = variables[_j];
          if (__indexOf.call(scope.parameters, variable) < 0 && variable !== '$this') {
            var_defines.push(variable);
          }
        }
        if (var_defines.length > 0) {
          var_string = 'var ' + var_defines.join(', ') + ";\n";
          scope.body = scope.body.insert(1, var_string);
        }
        return scope.variables = var_defines;
      }
    },
    process_scope: function(scope) {
      var current_counter, replace_defaults, replace_foreach;
      current_counter = 'a'.charCodeAt(0);
      replace_foreach = function(match, $1, $2) {
        var c;
        c = String.fromCharCode(++current_counter);
        return 'for (var ' + c + ' = 0; ' + c + ' < ' + $1 + '.length; ++' + c + ') {\n' + $2 + ' = ' + $1 + '[' + c + '];\n';
      };
      replace_defaults = function(match, variable, value, ending) {
        var default_string;
        default_string = variable + ' = ' + variable + ' || ' + value + ";\n";
        scope.body = scope.body.insert(1, default_string);
        return variable + ending;
      };
      scope.body = Parser.regex_stack(scope.body, [[/(\w+)\[\]\s*=\s*(.*?);/g, '$1->push($2);'], [/\->{(.*?)}/g, '[$1]'], ['.', '+'], ['->', '.'], [/\$/g, ''], [/isset\((.*?)\)/g, '$1 !== undefined'], [/foreach\s*\(\s*(\S+)\s+as\s+(\S+?)\)\s*{/g, replace_foreach]]);
      return scope.prefix = Parser.regex_stack(scope.prefix, [['$', ''], [/^.*?function/, 'function'], ['&', ''], [/(\w+)\s+=\s+(.*?)\s*([\),])/g, replace_defaults]]);
    }
  });

  JavaScript = Ice.subclass('JavaScript', module.exports = MetaHub.current_module.classes);

  module.exports.Parser = Parser;

}).call(this);
