MetaHub = require '../bloom/lib/metahub.js'
MetaHub.import_all()

PEG = require 'pegjs'

String.prototype.match_all = (regex, action) ->
  text = @toString()
  action(match)  while match = regex.exec(text)

String.prototype.replace_all = (pattern, replacement) ->
  text = @toString()
  while text.indexOf(pattern) >= 0
    text = text.replace pattern, replacement
  text

String::insert = (index, text) ->
  @slice(0, index) + text + @slice(index)

Parser = 
  find_scope: (source, open, close, pattern) ->
    depth = 0
    start = -1
    end = 0
    regex = new RegExp(pattern, 'g')
    while match = regex.exec(source)
      if match[0] == open
        ++depth;
        start = match.index if start == -1
      else
        if --depth == 0        
          end = regex.lastIndex
          return [ start, end ] 

  regex_stack: (text, patterns) ->
    for pattern in patterns
      if typeof pattern[0] == 'string'
        text = text.replace_all(pattern[0], pattern[1])
      else  
        text = text.replace(pattern[0], pattern[1])
    text

Liquid = Meta_Object.subclass 'Liquid',

Scope = Meta_Object.subclass 'Scope',
  prefix: ''
  body: ''
  range: []
  variables: []
  parameters: []
  initialize: (@prefix, @body, @range)->

Furnace = Meta_Object.subclass 'Furnace',
  initialize: ->
    
  locate_functions: (source)->
  
  liquify: (source) ->
    liquid = Liquid.create()
    liquid.source = source
    liquid.scopes = @locate_functions source
    for scope in liquid.scopes
      @find_variables scope
      @process_scope scope
    liquid
  
  process_scope: (scope) ->

Ice = Meta_Object.subclass 'Ice',  
  initialize: ->
    
  solidify: (liquid) ->
    result = ''
    for scope in liquid.scopes
      result += scope.prefix + '{' + scope.body + '}' + "\n\n"
    result

PHP = Furnace.subclass 'PHP',
  locate_functions: (source)->
    scopes = []
    pattern = /((?:(?:(?:public)|(?:private)|(?:protected)|(?:static))+\s*)?function\s+\w+\s*\((.*?)\))/g
    source.match_all pattern, (match) ->
      console.log match.index
      range = Parser.find_scope(source.substring(match.index), '{', '}', '{|}')
      body = source.substring(range[0] + 1 + match.index, range[1] - 1 + match.index)
      scope = Scope.create match[1], body, range
      scope.parameters = match[2].match(/[\$\w]+/g) || []
      scopes.push scope
    scopes
    
  find_variables: (scope) ->
    variables = []
    matches = scope.body.match(/\$\w+/g)
    if matches
      for match in matches
        if match not in variables
          variables.push(match)

      var_defines = []
      for variable in variables
        if variable not in scope.parameters && variable != '$this'
          var_defines.push variable

      if var_defines.length > 0
        var_string = 'var ' + var_defines.join(', ') + ";\n";
        scope.body = scope.body.insert(1, var_string)
      scope.variables = var_defines    
    
  process_scope: (scope) ->
    current_counter = 'a'.charCodeAt(0)
    replace_foreach = (match, $1, $2)->
      #'for ($2 in $1) {'
      c = String.fromCharCode(++current_counter)
      'for (var ' + c + ' = 0; ' + c + ' < ' + $1 + '.length; ++' + c + ') {\n' + $2 + ' = ' + $1 + '[' + c + '];\n'

    replace_defaults = (match, variable, value, ending)->
      default_string = variable + ' = ' + variable + ' || ' + value + ";\n"
      scope.body = scope.body.insert(1, default_string)
      variable + ending

    scope.body = Parser.regex_stack scope.body, [
      [ /(\w+)\[\]\s*=\s*(.*?);/g, '$1->push($2);' ]
      [ /\->{(.*?)}/g, '[$1]' ]
      [ '.', '+' ]
      [ '->', '.' ]
      [ /\$/g, '' ]
      [ /isset\((.*?)\)/g, '$1 !== undefined' ]
      [ /foreach\s*\(\s*(\S+)\s+as\s+(\S+?)\)\s*{/g, replace_foreach ]
    ]
    
    scope.prefix = Parser.regex_stack scope.prefix, [
      [ '$', '' ]
      [ /^.*?function/, 'function' ]
      [ '&', '' ]
      [ /(\w+)\s+=\s+(.*?)\s*([\),])/g, replace_defaults ]
    ]  

JavaScript = Ice.subclass 'JavaScript',

module.exports = MetaHub.current_module.classes
module.exports.Parser = Parser