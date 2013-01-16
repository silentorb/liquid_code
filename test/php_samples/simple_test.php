<?php

    switch ($type) {
      case 'int':
        return (int) $value;
        break;
      case 'string':
      case 'text':
      case 'reference':
        return $value;
        break;
      case 'bool':
        return str_to_bool($value);
        break;
      case 'double':
        return (float) $value;
        break;
    }

?>
