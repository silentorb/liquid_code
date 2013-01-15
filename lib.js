var compress, initialize, only_elements;

compress = function(item) {
  var i, result, _i, _len;
  result = "";
  if (item === null || item === void 0) {
    return "";
  }
  if (typeof item === "string") {
    return item;
  } else if (item.length && item.length > 0) {
    for (_i = 0, _len = item.length; _i < _len; _i++) {
      i = item[_i];
      result += compress(i);
    }
  }
  return result;
};

only_elements = function(element) {
  return element.type;
};

initialize = function() {
  var define_element, element, elements, find_variables, get_value, initialize_block, name, _results;
  find_variables = function(item, variables) {
    var child, key, property, _i, _len;
    variables = variables || {};
    if (typeof item === 'object' && item.length) {
      console.log('(list)');
      for (_i = 0, _len = item.length; _i < _len; _i++) {
        child = item[_i];
        variables = find_variables(child, variables);
      }
    } else if (typeof item === 'object') {
      if (item.type === 'variable') {
        variables[item.name] = item;
      } else {
        for (key in item) {
          property = item[key];
          console.log(key);
          variables = find_variables(property, variables);
        }
      }
    }
    return variables;
  };
  initialize_block = function() {
    return this.variables = find_variables(this.elements);
  };
  get_value = function(value, type) {
    if (type === 'compress') {
      return compress(value);
    }
    return value;
  };
  define_element = function(name, element) {
    var new_class;
    new_class = function() {
      var args, key, type, x;
      args = Array.prototype.slice.call(arguments);
      x = 0;
      this.type = name.toLowerCase();
      for (key in element) {
        type = element[key];
        if (x > args.length || key === 'initialize') {
          break;
        }
        this[key] = args[x++];
      }
      if (element.initialize) {
        element.initialize.apply(this, args);
      }
      return this;
    };
    new_class.prototype.constructor = new_class;
    return global[name] = new_class;
  };
  elements = {
    Arguments: {
      expressions: 'list'
    },
    Array_Append: {
      variable: 'object',
      expression: 'object'
    },
    Assignment: {
      variable: 'object',
      expression: 'object'
    },
    Block: {
      elements: 'list',
      initialize: initialize_block
    },
    Class_Definition: {
      name: 'compress',
      block: 'list'
    },
    Class_Block: {
      elements: 'string'
    },
    Code: {
      elements: 'list'
    },
    Control: {
      name: 'string',
      condition: 'string',
      block: 'list'
    },
    Create_Array: {
      "arguments": 'list'
    },
    Exception_Raise: {
      expression: 'object'
    },
    Expression: {
      contents: 'object'
    },
    Expression_List: {
      expressions: 'list'
    },
    Foreach_Object: {
      object: 'string',
      key: 'string',
      value: 'object',
      block: 'list'
    },
    Function_Definition: {
      name: 'compress',
      parameters: 'string',
      block: 'list'
    },
    Invoke_Function: {
      name: 'compress',
      "arguments": 'list'
    },
    Invoke_Method: {
      object: 'object',
      method: 'object'
    },
    Literal_String: {
      text: 'string'
    },
    Method_Definition: {
      name: 'compress',
      parameters: 'string',
      block: 'list',
      constructor: 'bool'
    },
    Operator: {
      symbol: 'string'
    },
    Parameter: {
      name: 'string',
      default_value: 'string'
    },
    Parameters: {
      variables: 'list'
    },
    Property: {
      variable: 'string',
      value: 'string'
    },
    Terminator: {
      dummy: 'string'
    },
    Variable: {
      name: 'compress',
      children: 'compress',
      index: 'compress'
    }
  };
  _results = [];
  for (name in elements) {
    element = elements[name];
    _results.push(define_element(name, element));
  }
  return _results;
};

initialize();
