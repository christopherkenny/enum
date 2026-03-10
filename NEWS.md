# enum 0.0.1

* The core enumeration algorithms have been rewritten in C, yielding large
  speed improvements for all grid and graph partition functions.
* `enum_partitions()` and `enum_partitions_graph()` gain a `file` argument.
  When provided, partitions are streamed to a binary file instead of
  returned as a matrix, enabling enumeration of large cases that would
  otherwise exhaust memory.
* New `enum_read_partitions()` reads a binary file written by
  `enum_partitions()` or `enum_partitions_graph()`. The `skip` and `n`
  arguments allow reading arbitrary subsets without loading the full file
  into memory.
