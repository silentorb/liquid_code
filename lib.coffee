compress = (item) ->
  result = ""
  if item is null || item is undefined
    return ""
  if typeof item is "string"
    return item
  else if item.length and item.length > 0
    for i in item
      result += compress(i)        
  result

only_elements = (element) ->
  element.type

initialize = () ->
  find_variables = (item, variables)->
    variables = variables || {}
    return variables if !item
    if typeof item == 'object' && item.length
      for child in item
        variables = find_variables(child, variables)
    else if typeof item == 'object'
      if item.type == 'variable'
        variables[item.name] = item
      else
        for key, property of item
          variables = find_variables(property, variables)

    variables
  
  initialize_block = ()->
    @variables = find_variables(@elements)
  
  initialize_string = ()->
    # compress consecutive string items
    return if typeof @text == 'string'
    new_text = []
    current_string = ''
    for item in @text
      if typeof item == 'string'
        current_string += item
      else
        if current_string.length > 0
          new_text.push current_string
        current_string = ''
        new_text.push item
    if current_string.length > 0
      new_text.push current_string
    @text = new_text
  
  get_value = (value, type)->
    if type == 'compress'
      return compress value
    return value
  
  define_element = (name, element)->
    new_class = ()->
      args = Array::slice.call(arguments)
      x = 0
      @type = name.toLowerCase()
      for key, type of element
        break if x > args.length || key == 'initialize'
        #this[key] = get_value(args[x++], type)
        this[key] = args[x++]
#      console.log name, this
      if element.initialize
        element.initialize.apply this, args
      this
    new_class::constructor = new_class
    global[name] = new_class

  elements =
    Arguments:
      expressions: 'list'
    Array_Append:
      variable: 'object'
      expression: 'object'
    Assignment:
      variable: 'object'
      expression: 'object'
    Associative_Array_Definition:
      items: 'list'
    Block:
      elements: 'list'
      initialize: initialize_block
    Case_Statement:
      value: 'object'
      code: 'code'
    Class_Definition:
      name: 'compress'
      parent: 'string'
      block: 'list'
    Class_Block:
      elements: 'string'    
    Code:
      elements: 'list'
    Command:
      name: 'string'
      expression: 'object'
    Comment:
      text: 'string'
      multiline: 'bool'
    Control:
      name: 'string'
      condition: 'string'
      block: 'list'
    Conversion:
      out_type: 'string'
      expression: 'object'
    Create_Array:
      arguments: 'list'
    Exception_Raise:
      expression: 'object'
    Expression:
      contents: 'object',
    Expression_List:
      expressions: 'list'
    Foreach_Object:
      object: 'string'
      key: 'string'
      value: 'object'
      block: 'list'
    Function_Definition:
      name: 'compress'
      parameters: 'string'
      block: 'list'
    Instantiate_Class:
      name: 'string'
      arguments: 'list'
    Invoke_Function:
      name: 'compress'
      arguments: 'list'
    Invoke_Method:
      object: 'object'
      method: 'object'
    Invoke_Static_Member:
      class_name: 'string'
      target: 'object'
    Invoke_Variable_Function:
      variable: 'object'
      arguments: 'list'
    Key_Value:
      key: 'string'
      value: 'object'
    Literal_String:
      text: 'string'
      quotes: 'string'
      label: 'string'
      initialize: initialize_string
    Method_Definition:
      name: 'compress'
      parameters: 'string'
      block: 'list'
      constructor: 'bool'
    Operator:
      symbol: 'string'
    Parameter:
      name: 'string'
      default_value: 'string'
    Parameters:
      variables: 'list'
    Property:
      variable: 'string'
      value: 'string'
    Regex:
      text: 'string'
    Switch_Statement:
      variable: 'object'
      cases: 'list'
      default_case: 'object'
    Terminator:
      dummy: 'string'
    Variable:
      name: 'compress'
      children: 'compress'
      index: 'compress'
      global: 'bool'
      
  for name, element of elements
    define_element name, element

initialize()

Parser = 
  label: ''
