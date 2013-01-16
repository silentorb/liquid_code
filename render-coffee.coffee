MetaHub = require("../bloom/lib/metahub.js")
MetaHub.node_module module, ->
  Ice = MetaHub.Meta_Object.subclass("Ice",
    render: (liquid) ->
  )
  
  function_conversions =
    'json_encode': 'JSON.stringify'
    'print_r': 'console.log'
    'unset': 'delete $1'
    'array_unshift': '$1.unshift($2)'
    'property_exists': '$1[$2] != undefined'
    'array_merge': 'MetaHub.extend'
    'get_object_vars': '$1'
    'preg_match': '$2.match($1)'

  CoffeeScript = Ice.subclass("CoffeeScript",
    depth: 0
    indent_amount: 2
    function_conversions: function_conversions
    indent: ->
      result = ""
      x = 0

      while x < @indent_amount * @depth
        result += " "
        ++x
      result

    render: (liquid) ->
      return  if liquid is null or liquid is `undefined`
      args = Array::slice.call(arguments)
      if liquid.type
        type = @classes[liquid.type]
        if type
          type.apply this, args
      else if typeof liquid isnt "string" and liquid.length > 0
        @render_elements liquid
      else
        liquid

    render_block: (elements)->
      ++@depth
      indent = @indent()      
      rendered_elements = elements.map (element) =>
        indent + @render(element)
      --@depth
      result = "\n" + rendered_elements.join("\n")

      if result[result.length - 1] != "\n"
        result += "\n"
      result
      
    render_elements: (tokens, spacer) ->
      spacer = ' ' if typeof spacer != 'string'
      results = []
      for token in tokens
        text = @render(token)
        if text isnt `undefined` and text isnt null
          results.push text
      
      if results.length > 0
        results.join(spacer)
      else
        ''
    
    render_function_body: (element)->
      parameters = @render(element.parameters)
      text = ''
      if parameters.length > 0
        text += "(" + parameters + ")"
      text += "->"
      header = []
      for parameter in element.parameters.variables
        if parameter.default_value
          default_hack = 'if ' + parameter.name + ' == undefined\n'
          @depth += 2
          default_hack += @indent() + parameter.name + ' = ' + @render(parameter.default_value)
          @depth -= 2
          header.push default_hack

      text += @render(element.block, header)
      text
      
    classes:
      arguments: (element) ->
        return '' if !element.expressions || element.expressions.length < 1
        expressions = element.expressions.map (expression) =>
          @render expression        
        expressions.join ", "
      
      array_append: (element)->
        @render(element.variable, true) + '.push(' + @render(element.expression) + ')'
        
      assignment: (element)->
        @render(element.variable) + ' = ' + @render(element.expression)
        
      block: (element, prefix, suffix) ->
        prefix = prefix || []
        suffix = suffix || []
        elements = [].concat prefix, element.elements, suffix
        @render_block elements
 
      class_block: (element) ->
        @render_block element.elements.filter (x) -> x.type

      class_definition: (element) ->
        parent = element.parent || 'Meta_Object'
        element.name + " = " + parent + ".subclass '" +
        element.name + "'," + @render(element.block)
        
      code: (element) ->
        @render_elements element.elements
      
      command: (element)->
        text = element.name
        text = 'console.log' if text == 'echo' || text == 'print'
        text = '#' + text if text == 'global'
        if element.expression
          text += " " + @render element.expression
        text

      comment: (element)->
        if element.multiline
          '/*' + element.text + '*/'
        else
          '#' + element.text

      control: (element) ->
        if element.name == 'do'
          condition = "break unless " + @render(element.condition)
          text = 'loop' + @render(element.block, undefined, condition)
        else
          text = element.name
          text += " " + @render(element.condition)  if element.condition
          text + @render(element.block)
      
      conversion: (element)->
        exp = @render element.expression
        switch element.out_type
          when 'int' then "parseInt(" + exp + ")"
          when 'float' then "parseFloat(" + exp + ")"
          when 'string' then exp + ".toString()"
           
      create_array: (element)->
        '[' + @render(element.arguments) + ']'
        
      exception_raise: (element)->
        'throw ' + @render(element.expression) + "\n"
        
      expression: (element)->
        text = ''
        text += '!' if element.negate == true
        text += @render(element.contents)

      expression_list: (element)->
        @render_elements(element.expressions, ' ')
        
      function_definition: (element) ->
        element.name + ' = ' + @render_function_body element

      foreach_object: (element)->
        object = @render(element.object)
        value = @render(element.value)
        key = ''
        if element.key
          key = @render(element.key) + ', '
        text = 'for ' + key + value + ' of ' + object
        text += @render(element.block)

      instantiate_class: (element) ->
        if element.name == 'stdClass'
          "{}"
#          "new" +  + "(" + @render(element.arguments) + ")"
        else
          element.name + ".create(" + @render(element.arguments) + ")"
 
      invoke_function: (element) ->
        if element.arguments && element.arguments.expressions.length > 0
          args = @render(element.arguments)
        else
          args = ''

        text = ''
        if element.root
          text += @render(element.root) + '.'        
        
        name = element.name
        conversion = @function_conversions[element.name]
        if conversion
          if conversion.match /\$\d/
            expression = conversion.replace /\$0/g, args
            return expression.replace /\$(\d)/g, (match, index)=>
              @render element.arguments.expressions[index - 1]
          name = conversion
          
        text += name + "(" + args + ")"

#            element.arguments.expressions[

      invoke_method: (element)->
        object = @render(element.object)
        if object = 'this'
          object = '@'
        else
          object += '.'
        object + @render(element.method)
      
      invoke_static_member: (element)->
        element.class_name + '.' + @render(element.target)

      invoke_variable_function: (element)->
        @render(element.variable) + '(' + @render(element.arguments) + ')'
        
      literal_string: (element) ->
        if element.quotes == 'heredoc'
#          lines = element.text
#          '<<<' + element.label + @render(element.text) + element.label
          text = '"""\n'
          for item in element.text
            if typeof item == 'string'
              text += item
            else if item.type == 'variable'
              text += '#{' + @render(item) + '}'
          text += '\n"""\n'
        else
          if element.quotes = 'single'
            quote = "'"
          else
            quote = '"'
          quote + @render(element.text) + quote

      method_definition: (element) ->
        if element.constructor
          name = 'initialize'
        else
          name = element.name
        name + ": " + @render_function_body(element)
#        name + ": function" + "(" + @render(element.parameters) + ")" + @render(element.block)

      operator: (element)->
        conversions =
          '===': '=='
          '!==': '!='
          '.=': '+='
        
        if conversions[element.symbol] != undefined
          return conversions[element.symbol]

        element.symbol
          
      parameter: (element) ->
        element.name

      parameters: (element) ->
        return '' if !element.variables || element.variables.length < 1
        variables = element.variables.map (variable) =>
          @render variable        
        variables.join ", "

      property: (element) ->
        value = element.value || "''"
        @render(element.variable) + ': ' + @render(value)
      
      regex: (element)->
        "/" + element.text + "/"

      switch_statement: (element)->
        text = 'switch ' + @render(element.variable) + "\n"
        @depth++
        cases = []
        fall_through = []
        for c in element.cases
          if c.code.length == 0
            fall_through.push @render(c.value)
          else
            new_case =
              type: 'case_statement'
              values: fall_through.concat @render(c.value)
              code: c.code
            cases.push new_case
            fall_through = []

        for c in cases
          text += @indent() + 'when ' + c.values.join(', ')
          text += @render_block(c.code)
        
        if element.default_case
          text += @indent() + 'else '
          text += @render_block(element.default_case.code)
          
        @depth--
        text
        
      terminator: (element)->
        ''

      variable: (element, hide_index) ->
        text = ''
        if element.root
          text += @render(element.root) + '.'
#        text = [element.name].concat(element.children).join('.')
        text += element.name
        text = text.replace /^this\./, '@'
        if !hide_index && element.index
          text += "[" + @render(element.index) + "]"
        text
  )
