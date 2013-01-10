<?php

class Query {

  protected $trellises = array();
  public $main_table = 'node';
  public $joins = array();
  public $filters = array();
  public $post_clauses = array();
  public $limit = '';
  public $sources = array();
  public $links = array();
  public $trellis;
  public $db;

  public function __construct($trellis, $include_links = true) {
    if (get_class($trellis) != 'Trellis' && !is_subclass_of($trellis, 'Trellis')) {
      throw new Exception('An invalid trellis was passed to the Query constructor.');
    }
    $this->trellis = $trellis;
    $this->ground = $this->trellis->ground;
    $this->db = $this->ground->db;
    $this->main_table = $trellis->get_table_name();
    $this->add_source($trellis);
    if ($include_links) {
      $current_trellis = $trellis;
      do {
        foreach ($current_trellis->links as $link) {
          $this->add_link($link);
        }
      }
      while ($current_trellis = $current_trellis->parent);
    }
  }

  function add_source($source, $include_primary_key = true) {
    $this->sources[] = $source;
    $table_name = $source->get_table_name();
    foreach ($source->core_properties as $property) {
      if ($property->name != $source->primary_key || $include_primary_key)
        $this->add_field($table_name . '.' . $property->field_name);
    }

    $source->parent_query($this);
  }

  function add_filter($clause) {
    $this->filters[] = $clause;
  }

  function add_field($clause) {
    $this->fields[] = $clause;
  }

  function add_join($clause) {
    $this->joins[] = $clause;
  }

  function add_post($clause) {
    $this->post_clauses[] = $clause;
  }

}

?>
