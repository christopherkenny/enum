# Changelog

## enum 0.0.1

- The core enumeration algorithms have been rewritten in C, yielding
  large speed improvements for all grid and graph partition functions.
- [`enum_partitions()`](http://christophertkenny.com/enum/reference/enum_partitions.md)
  and
  [`enum_partitions_graph()`](http://christophertkenny.com/enum/reference/enum_partitions_graph.md)
  gain a `file` argument. When provided, partitions are streamed to a
  binary file instead of returned as a matrix, enabling enumeration of
  large cases that would otherwise exhaust memory.
- New
  [`enum_read_partitions()`](http://christophertkenny.com/enum/reference/enum_read_partitions.md)
  reads a binary file written by
  [`enum_partitions()`](http://christophertkenny.com/enum/reference/enum_partitions.md)
  or
  [`enum_partitions_graph()`](http://christophertkenny.com/enum/reference/enum_partitions_graph.md).
  The `skip` and `n` arguments allow reading arbitrary subsets without
  loading the full file into memory.
