var Query = Meta_Object.subclass('Query', {
trellises: [],
main_table:,
joins: [],
filters: [],
post_clauses: [],
limit:,
sources: [],
links: [],
trellis: '',
db: '',
initialize: function(trellis, include_links) {
    var ground, db, main_table, current_trellis, parent, links, link;
if (get_class(trellis) != && is_subclass_of(trellis, )) {
      
}
 trellis = trellis ;
 ground = ground ;
 db = db ;
 main_table = get_table_name() ;
 add_source(trellis) ;
 if (include_links) {
      current_trellis = trellis ;
 do {
        for (var i in links) {
link = links[i];
 {
          add_link(link) ;

}
}
}
while (current_trellis = parent);

}

},
add_source: function(source, include_primary_key) {
    var sources, table_name, core_properties, property, name, primary_key, field_name;
sourcesundefined ;
 table_name = get_table_name() ;
 for (var i in core_properties) {
property = core_properties[i];
 {
      if (name != primary_key || include_primary_key) {
        add_field(table_name + + field_name) ;

}

}
} parent_query(this) ;

},
add_filter: function(clause) {
    var filters;
filtersundefined ;

},
add_field: function(clause) {
    var fields;
fieldsundefined ;

},
add_join: function(clause) {
    var joins;
joinsundefined ;

},
add_post: function(clause) {
    var post_clauses;
post_clausesundefined ;

}});