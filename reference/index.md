# Package index

## Grid partitions

Enumerate or count all connected partitions of a rectangular grid within
given piece-size bounds.

- [`enum_partitions()`](http://christophertkenny.com/enum/reference/enum_partitions.md)
  : Enumerate grid partitions
- [`enum_count_partitions()`](http://christophertkenny.com/enum/reference/enum_count_partitions.md)
  : Count grid partitions

## Graph partitions

Enumerate or count all connected partitions of an arbitrary graph within
given piece-size bounds. Accepts `igraph` and `adj` objects.

- [`enum_partitions_graph()`](http://christophertkenny.com/enum/reference/enum_partitions_graph.md)
  : Enumerate partitions of a graph
- [`enum_count_partitions_graph()`](http://christophertkenny.com/enum/reference/enum_count_partitions_graph.md)
  : Count partitions of a graph

## File I/O

Read partitions written to a binary file by
[`enum_partitions()`](http://christophertkenny.com/enum/reference/enum_partitions.md)
or
[`enum_partitions_graph()`](http://christophertkenny.com/enum/reference/enum_partitions_graph.md).

- [`enum_read_partitions()`](http://christophertkenny.com/enum/reference/enum_read_partitions.md)
  : Read partitions from a binary file
