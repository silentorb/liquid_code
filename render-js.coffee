MetaHub = require("../bloom/lib/metahub.js")
MetaHub.node_module module, ->
  Ice = MetaHub.Meta_Object.subclass("Ice",
    render: (liquid) ->
  )
  JavaScript = Ice.subclass("JavaScript",
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
      if liquid.type
        type = @classes[liquid.type]
        if type
          console.log @indent() + liquid.type
          
          #          MetaHub.extend(liquid, type);
          #          return liquid.render(this);
          type.call this, liquid
      else if typeof liquid isnt "string" and liquid.length > 0
        @render_elements liquid
      else
        liquid

    render_elements: (tokens) ->
      result = ''
      for token in tokens
        text = @render(token)
        if text isnt `undefined` and text isnt null
          result += text 
      result
      
    classes:
      arguments: (element) ->
        return '' if !element.expressions || element.expressions.length < 1
        expressions = element.expressions.map (expression) =>
          @render expression        
        expressions.join ", "
      block: (element) ->
        ++@depth
        result = " {\n" + @indent() + @render_elements(element.elements) + "\n}\n"
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
        console.log '***'
        parent = element.parent || 'Meta_Object'
        "var " + element.name + " = " + parent + ".subclass('" +
        element.name + "'," + @render(element.block) + ");"

      code: (element) ->
        @render_elements element.elements

      control: (element) ->
        text = element.name
        text += " (" + @render(element.condition) + ")"  if element.condition
        text + @render(element.body)

      function_definition: (element) ->
        "function " + element.name + "(" + @render(element.parameters) + ")" + @render(element.block)

      invoke_function: (element) ->
        if element.arguments && element.arguments.length > 0
          args = @render(element.arguments)
        else
          args = ''
        element.name + "(" + args + ")"

      literal_string: (element) ->
        "'" + element.text + "'"

      method_definition: (element) ->
        if element.constructor
          name = 'initialize'
        else
          name = element.name
        name + ": function" + "(" + @render(element.parameters) + ")" + @render(element.block)

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

      variable: (element) ->
        element.name + element.children.replace(/\->/g, ".") + element.index
  )
