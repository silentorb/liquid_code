var Query = Meta_Object.subclass('Query', {
trellises: [],
main_table: 'node',
joins: [],
filters: [],
post_clauses: [],
limit: '',
sources: [],
links: [],
trellis: '',
db: '',
initialize: function(trellis, include_links) {
    if (include_links === undefined)
include_links = true;
var current_trellis, link;
if (get_class(trellis)  != 'Trellis'  && !  is_subclass_of(trellis, 'Trellis')) {
      
             throw new Exception('An invalid trellis was passed to the Query constructor.');

}
 this.trellis  = trellis ;
 this.ground  = this.trellis.ground ;
 this.db  = this.ground.db ;
 this.main_table  = trellis.get_table_name() ;
 this.add_source(trellis) ;
 if (include_links) {
      current_trellis  = trellis ;
 do {
        
                 for (var i in current_trellis.links) {
link = current_trellis.links[i];
 {
          this.add_link(link) ;

}
}
}
while (current_trellis  = current_trellis.parent);

}

},
add_source: function(source, include_primary_key) {
    if (include_primary_key === undefined)
include_primary_key = true;
var table_name, property;
this.sources.push(source) ;
 table_name  = source.get_table_name() ;
 for (var i in source.core_properties) {
property = source.core_properties[i];
 {
      if (property.name  != source.primary_key  || include_primary_key) {
        this.add_field(table_name  + '.'  + property.field_name) ;
 
}

}
} source.parent_query(this) ;

},
add_filter: function(clause) {
    this.filters.push(clause) ;

},
add_field: function(clause) {
    this.fields.push(clause) ;

},
add_join: function(clause) {
    this.joins.push(clause) ;

},
add_post: function(clause) {
    this.post_clauses.push(clause) ;

}});