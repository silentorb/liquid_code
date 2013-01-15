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
#    console.log '*' + typeof item
    if typeof item == 'object' && item.length
      console.log '(list)'
      for child in item
        variables = find_variables(child, variables)
    else if typeof item == 'object'
      if item.type == 'variable'
        variables[item.name] = item
      else
        for key, property of item
          console.log key
          variables = find_variables(property, variables)

    variables
  
  initialize_block = ()->
    @variables = find_variables(@elements)
  
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
#        console.log '*', key
#      console.log 'type', @type
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
    Block:
      elements: 'list'
      initialize: initialize_block
    Class_Definition:
      name: 'compress'
      block: 'list'
    Class_Block:
      elements: 'string'    
    Code:
      elements: 'list'
    Control:
      name: 'string'
      condition: 'string'
      block: 'list'
    Create_Array:
      arguments: 'list'
    Exception_Raise:
      expression: 'object'
    Expression:
      contents: 'object'
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
    Invoke_Function:
      name: 'compress'
      arguments: 'list'
    Invoke_Method:
      object: 'object'
      method: 'object'
    Literal_String:
      text: 'string'
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
    Terminator:
      dummy: 'string'
    Variable:
      name: 'compress'
      children: 'compress'
      index: 'compress'
      
  for name, element of elements
    define_element name, element

initialize()