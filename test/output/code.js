var Query = Meta_Object.subclass('Query',trellises: array(),
main_table: 'node',
joins: array(),
filters: array(),
post_clauses: array(),
limit: '',
sources: array(),
links: array(),
trellis: '',
db: '',
initialize: function(trellis) {
    if (get_class()!= 'Trellis' && !is_subclass_of()) {
      throw newException();
    
}
this.trellis = trellis;
    this.ground = this.trellis.ground;
    this.db = this.ground.db;
    this.main_table = trellis->get_table_name();
    this->add_source();
    if (include_links) {
      current_trellis = trellis;
      do {
        foreach (current_trellis.links as link) {
          this->add_link();
        
}

}
while();
    
}

},
add_source: function(source) {
    this.sources[] = source;
    table_name = source->get_table_name();
    foreach (source.core_properties as property) {
      if()this->add_field();
    
}
source->parent_query();
  
},
add_filter: function(clause) {
    this.filters[] = clause;
  
},
add_field: function(clause) {
    this.fields[] = clause;
  
},
add_join: function(clause) {
    this.joins[] = clause;
  
},
add_post: function(clause) {
    this.post_clauses[] = clause;
  
});