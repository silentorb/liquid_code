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
        break if x > args.length
        #this[key] = get_value(args[x++], type)
        this[key] = args[x++]
#        console.log '*', key
#      console.log 'type', @type
      this
    new_class::constructor = new_class
    global[name] = new_class

  elements =
    Arguments:
      expressions: 'list'
    Block:
      elements: 'string'
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
      body: 'list'
    Function_Definition:
      name: 'compress'
      parameters: 'string'
      block: 'list'
    Invoke_Function:
      name: 'compress'
      arguments: 'list'
    Literal_String:
      text: 'string'
    Method_Definition:
      name: 'compress'
      parameters: 'string'
      block: 'list'
      constructor: 'bool'
    Parameter:
      name: 'string'
      default_value: 'string'
    Parameters:
      variables: 'list'
    Property:
      variable: 'string'
      value: 'string'
    Variable:
      name: 'compress'
      children: 'compress'
      index: 'compress'
      
  for name, element of elements
    define_element name, element

initialize()