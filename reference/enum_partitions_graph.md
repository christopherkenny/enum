# Enumerate partitions of a graph

Enumerate all partitions of an arbitrary graph into `num_parts`
connected subgraphs, where each subgraph has between `min_size` and
`max_size` vertices. Accepts `igraph` objects and `adj` objects
(1-indexed adjacency lists).

## Usage

``` r
enum_partitions_graph(graph, num_parts, min_size, max_size, file = NULL)
```

## Arguments

- graph:

  An `igraph` or `adj` object. Must be undirected and connected. An
  `adj` object is a list where element `i` contains the integer indices
  (1-indexed) of vertices adjacent to vertex `i`.

- num_parts:

  Integer. Number of parts to partition the graph into.

- min_size:

  Integer. Minimum number of vertices per part.

- max_size:

  Integer. Maximum number of vertices per part.

- file:

  Character or `NULL`. If a file path is provided, partitions are
  written to a binary file instead of returned as a matrix. Each
  partition is stored as one 32-bit integer per vertex. Use
  [`enum_read_partitions()`](http://christophertkenny.com/enum/reference/enum_read_partitions.md)
  to read the file back into R. When `file` is not `NULL`, the function
  returns the partition count invisibly.

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
#>      [,1] [,2] [,3]
#> [1,]    1    1    1
#> [2,]    1    1    2
#> [3,]    2    1    2
#> [4,]    2    2    2
#> [5,]    2    2    1
#> [6,]    1    2    1
```
