# Enumerate partitions of a graph

Enumerate all partitions of an arbitrary graph into `num_parts`
connected subgraphs. Part sizes can be constrained either as a range via
`min_size` and `max_size`, or as an explicit set of allowed sizes via
`exact_sizes`. Accepts `igraph` objects and `adj` objects (1-indexed
adjacency lists).

## Usage

``` r
enum_partitions_graph(
  graph,
  num_parts,
  min_size = NULL,
  max_size = NULL,
  exact_sizes = NULL,
  file = NULL,
  progress = TRUE
)
```

## Arguments

- graph:

  An `igraph` or `adj` object. Must be undirected and connected. An
  `adj` object is a list where element `i` contains the integer indices
  (1-indexed) of vertices adjacent to vertex `i`.

- num_parts:

  Integer. Number of parts to partition the graph into.

- min_size:

  Integer or `NULL`. Minimum number of vertices per part. Must be
  supplied together with `max_size`; mutually exclusive with
  `exact_sizes`.

- max_size:

  Integer or `NULL`. Maximum number of vertices per part. Must be
  supplied together with `min_size`; mutually exclusive with
  `exact_sizes`.

- exact_sizes:

  Integer vector or `NULL`. The exact set of allowed part sizes.
  Mutually exclusive with `min_size`/`max_size`.

- file:

  Character or `NULL`. If a file path is provided, partitions are
  written to a binary file instead of returned as a matrix. Each
  partition is stored as one 32-bit integer per vertex. Use
  [`enum_read_partitions()`](http://christophertkenny.com/enum/reference/enum_read_partitions.md)
  to read the file back into R. When `file` is not `NULL`, the function
  returns the partition count invisibly.

- progress:

  Logical. Whether to report enumeration progress. Default `TRUE`.

## Value

When `file` is `NULL` (default), an integer matrix where each column is
a partition and each row corresponds to a vertex (in igraph vertex
order). Cell values are integers from `1` to `num_parts` indicating part
membership. When `file` is a path, returns the number of partitions
written, invisibly.

## Examples

``` r
g <- igraph::make_ring(6)
enum_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3)
#>  ■                                  0% |  ETA: ?
#>  ■■■■■■■■■■■                       33% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■             67% |  ETA:  0s
#>      [,1] [,2] [,3]
#> [1,]    1    1    1
#> [2,]    1    1    2
#> [3,]    2    1    2
#> [4,]    2    2    2
#> [5,]    2    2    1
#> [6,]    1    2    1
```
