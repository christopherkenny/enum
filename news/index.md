# Changelog

## enum 0.0.1

- The core enumeration algorithms have been rewritten in C, yielding
  large speed improvements for all grid and graph partition functions.
- Polyomino generation (`grow_ominos`) has been rewritten in C with an
  open-addressed hash set for deduplication, eliminating the bottleneck
  for cases with large or widely-spaced allowed sizes
  (e.g. `exact_sizes = c(5, 15)` on a 5×5 grid now takes seconds rather
  than hours).
- [`enum_partitions()`](http://christophertkenny.com/enum/reference/enum_partitions.md),
  [`enum_count_partitions()`](http://christophertkenny.com/enum/reference/enum_count_partitions.md),
  [`enum_partitions_graph()`](http://christophertkenny.com/enum/reference/enum_partitions_graph.md),
  and
  [`enum_count_partitions_graph()`](http://christophertkenny.com/enum/reference/enum_count_partitions_graph.md)
  gain an `exact_sizes` argument. Pass an integer vector of allowed part
  sizes (e.g. `exact_sizes = c(4, 8)`) instead of a
  `min_size`/`max_size` range. This is useful when part sizes must
  satisfy a specific integer relationship, such as parts of size `k` and
  `2k`.
- [`enum_partitions()`](http://christophertkenny.com/enum/reference/enum_partitions.md)
  and
  [`enum_partitions_graph()`](http://christophertkenny.com/enum/reference/enum_partitions_graph.md)
  gain a `progress` argument (default `TRUE`). A progress bar powered by
  the [cli](https://cli.r-lib.org/) C API is displayed during
  enumeration, updating from within the C backtracking loop. Interrupt
  support (`R_CheckUserInterrupt`) is also present throughout the C
  code.
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
