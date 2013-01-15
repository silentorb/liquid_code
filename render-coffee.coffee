MetaHub = require("../bloom/lib/metahub.js")
MetaHub.node_module module, ->
  Ice = MetaHub.Meta_Object.subclass("Ice",
    render: (liquid) ->
  )
  CoffeeScript = Ice.subclass("CoffeeScript",
    depth: 0
    indent_amount: 2
    indent: ->
      result = ""
      x = 0

      while x < @indent_amount * @depth
        result += " "
        ++x
      result

    render: (liquid) ->
      
      #      console.log('liquid', liquid , typeof liquid, liquid.length);
      return  if liquid is null or liquid is `undefined`
      args = Array::slice.call(arguments)
      if liquid.type
        type = @classes[liquid.type]
        if type
#          console.log @indent() + liquid.type
          type.apply this, args
      else if typeof liquid isnt "string" and liquid.length > 0
        @render_elements liquid
      else
        liquid

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
      header = ''
      for parameter in element.parameters.variables
        if parameter.default_value
#          header += parameter.name + ' = ' + parameter.name + ' || ' + @render(parameter.default_value) + ";\n"
          header += 'if (' + parameter.name + ' === undefined)\n' + parameter.name + ' = ' + @render(parameter.default_value) + ";\n"

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
        
      block: (element, prefix) ->
        if prefix is undefined
          prefix = ''  
        ++@depth
        result = "\n" + @indent() + prefix
        result += @render_elements(element.elements, "\n" + @indent()) + "\n"
        --@depth
        result

      class_block: (element) ->
        ++@depth
        elements = element.elements.filter (element) ->
          element.type
        elements = elements.map (element) =>
          @render(element).trim()
        --@depth
        elements.join(",\n")        

      class_definition: (element) ->
        parent = element.parent || 'Meta_Object'
        element.name + " = " + parent + ".subclass('" +
        element.name + "', {\n" + @render(element.block) + "});"

      code: (element) ->
        @render_elements element.elements
        
      comment: (element)->
        if element.multiline
          '/*' + element.text + '*/'
        else
          '//' + element.text

      control: (element) ->
        if element.name == 'do'
          text = 'do' + @render(element.block)
          text += "while (" + @render(element.condition) + ");\n"
        else
          text = element.name
          text += " (" + @render(element.condition) + ")"  if element.condition
          text + @render(element.block)
      
      create_array: (element)->
        '[' + @render(element.arguments) + ']'
        
      exception_raise: (element)->
        'throw ' + @render(element.expression) + ";\n"
        
      expression: (element)->
        @render(element.contents)

      expression_list: (element)->
        @render_elements(element.expressions, ' ')
        
      function_definition: (element) ->
        element.name + ' = ' + @render_function_body element

      foreach_object: (element)->
        object = @render(element.object)
        value = @render(element.value)
        key = ''
        if element.key
          key = key + ', '
        text = 'for ' + key + value + ' of ' + object
        text += @render(element.block)
        
      invoke_function: (element) ->
#        console.log element.arguments
        if element.arguments && element.arguments.expressions.length > 0
          args = @render(element.arguments)
        else
          args = ''
        element.name + "(" + args + ")"

      invoke_method: (element)->
        @render(element.object) + '.' + @render(element.method)
      
      invoke_static_member: (element)->
        element.class_name + '.' + @render(element.target)

      invoke_variable_function: (element)->
        @render(element.variable) + '(' + @render(element.arguments) + ')'
        
      literal_string: (element) ->
        if element.quotes = 'heredoc'
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
        name + ": " + @render_function_body element
#        name + ": function" + "(" + @render(element.parameters) + ")" + @render(element.block)

      operator: (element)->
        if element.symbol == '.'
          return '+';
        else
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
        
      terminator: (element)->
        ''

      variable: (element, hide_index) ->
        text = element.name + element.children.replace(/\->/g, ".")
        if !hide_index
          text += @render(element.index)
        text
  )
