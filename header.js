function Element() {  
}

Element.prototype = {
  constructor: Element
};
 
function compress(item) {
  var result = '';
  if (typeof item === 'string')
    return item;  
  else if (item.length && item.length > 0) {
    for (var i = 0; i < item.length; i++) {
      result += compress(item[i]);
    }
  }
  
  return result;
}

Element.subclass = function(name, init, properties) {
  var parent = this;
  var child = function() {
    var args = Array.prototype.slice.call(arguments);
    this.type = name.toLowerCase();
    parent.prototype.constructor.apply(this, args);
    init.apply(this, args);
  };
  child.prototype = new this();
  child.prototype.constructor = child
  child.subclass = this.subclass;
  //  module.exports[name] = child;
  global[name] = child;
  
  for (var p in properties) {
    child.prototype[p] = properties[p];
  }
  return child;
};

Element.subclass('Block', function(tokens) {
  this.tokens = tokens;
});

Element.subclass('Class_Definition', function(name, block) {
  this.name = name.join('');
  this.block = block;
});

Element.subclass('Code', function(tokens) {
  this.tokens = tokens;
});

Element.subclass('Control', function(name, condition, body) {
  this.name = name;
  this.condition = condition;
  this.body = body;
});

Element.subclass('Function_Definition', function(name, parameters, block) {
  this.name = name.join('');
  this.parameters = parameters;
  this.block = block;
});

Element.subclass('Invoke_Function', function(name, arguments) {
  this.name = name.join('');
  this.arguments = arguments;
});

Element.subclass('Literal_String', function(text) {
  this.text = text;
});

Element.subclass('Parameters', function(variables) {
  this.variables = variables;
});

Element.subclass('Arguments', function(expressions) {
  this.expressions = expressions;
});

Element.subclass('Variable', function(root, children, index) {
  this.name =  root.join('');
  this.children = compress(children);
  this.index = compress(index);
});
