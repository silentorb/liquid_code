var MetaHub = require('../bloom/lib/metahub.js');

MetaHub.node_module(module, function() {
  var Ice = MetaHub.Meta_Object.subclass('Ice', {
    render: function(liquid) {
    
    }
  });

  var JavaScript = Ice.subclass('JavaScript', {
    depth: 0,
    indent_amount: 2,
    indent: function() {
      var result = '';
      for (var x = 0; x < this.indent_amount * this.depth; ++x) {
        result += ' ';
      }
      return result;
    },
    render: function(liquid) {
      //      console.log('liquid', liquid , typeof liquid, liquid.length);
      if (liquid === null || liquid === undefined)
        return;

      if (liquid.type) {
        var type = this.classes[liquid.type];
        if (type) {
          console.log (this.indent() + liquid.type);
          //          MetaHub.extend(liquid, type);
          //          return liquid.render(this);
          return type.call(this, liquid);
        }
      }
      else if (typeof liquid !== 'string' && liquid.length > 0) {       
        return this.render_elements(liquid);        
      }
      else {
        return liquid;
      }
    },
    render_elements: function(tokens) {
      var result = '';
      for (var i = 0; i < tokens.length; i++) {
        var text = this.render(tokens[i]);
        if (text !== undefined && text !== null)
          result += text;
      }
  
      return result;
    },
    classes: {
      block: function(element) {
        ++this.depth;
        var result = " {\n" + this.indent() +
        this.render_elements(element.tokens)
        + "\n}\n";
        --this.depth;
        return result;
      },
      code:  function(element) {          
        return this.render_elements(element.tokens);        
      },
      class_definition:  function(element) {
        this.parent = this.parent || Meta_Object;
        var result = 'var ' + element.name + '= '
        return result + this.render(element.block);        
      },
      control:  function(element) {
        var text = element.name;
        if (element.condition) {
          text += ' (' + this.render(element.condition)
          + ')';
        }
        return text + this.render(element.body);
      },
      function_definition:  function(element) {
        return 'function ' + element.name + '(' + this.render(element.parameters)
        + ')' + this.render(element.block);
      },
      invoke_function:  function(element) {
        return element.name + '(' + this.render(element.arguments) + ')';
      },
      literal_string:  function(element) {
        return "'" + element.text + "'";
      },
      parameters: function(element) {
        var self = this;
        var variables = element.variables.map(function(variable) {
          return self.render(variable);
        });
        return variables.join(', ');
      },
      variable:  function(element) {
        return element.name + element.children.replace(/\->/g, '.') + element.index;
      }
    }
  });
});