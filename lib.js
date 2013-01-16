var Parser, compress, initialize, only_elements;

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
  var define_element, element, elements, find_variables, get_value, initialize_block, initialize_string, name, _results;
  find_variables = function(item, variables) {
    var child, key, property, _i, _len;
    variables = variables || {};
    if (!item) {
      return variables;
    }
    if (typeof item === 'object' && item.length) {
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
          variables = find_variables(property, variables);
        }
      }
    }
    return variables;
  };
  initialize_block = function() {
    return this.variables = find_variables(this.elements);
  };
  initialize_string = function() {
    var current_string, item, new_text, _i, _len, _ref;
    if (typeof this.text === 'string') {
      return;
    }
    new_text = [];
    current_string = '';
    _ref = this.text;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (typeof item === 'string') {
        current_string += item;
      } else {
        if (current_string.length > 0) {
          new_text.push(current_string);
        }
        current_string = '';
        new_text.push(item);
      }
    }
    if (current_string.length > 0) {
      new_text.push(current_string);
    }
    return this.text = new_text;
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
    Case_Statement: {
      value: 'object',
      code: 'code'
    },
    Class_Definition: {
      name: 'compress',
      parent: 'string',
      block: 'list'
    },
    Class_Block: {
      elements: 'string'
    },
    Code: {
      elements: 'list'
    },
    Command: {
      name: 'string',
      expression: 'object'
    },
    Comment: {
      text: 'string',
      multiline: 'bool'
    },
    Control: {
      name: 'string',
      condition: 'string',
      block: 'list'
    },
    Conversion: {
      out_type: 'string',
      expression: 'object'
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
    Instantiate_Class: {
      name: 'string',
      "arguments": 'list'
    },
    Invoke_Function: {
      name: 'compress',
      "arguments": 'list'
    },
    Invoke_Method: {
      object: 'object',
      method: 'object'
    },
    Invoke_Static_Member: {
      class_name: 'string',
      target: 'object'
    },
    Invoke_Variable_Function: {
      variable: 'object',
      "arguments": 'list'
    },
    Literal_String: {
      text: 'string',
      quotes: 'string',
      label: 'string',
      initialize: initialize_string
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
    Regex: {
      text: 'string'
    },
    Switch_Statement: {
      variable: 'object',
      cases: 'list',
      default_case: 'object'
    },
    Terminator: {
      dummy: 'string'
    },
    Variable: {
      name: 'compress',
      children: 'compress',
      index: 'compress',
      global: 'bool'
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

Parser = {
  label: ''
};
