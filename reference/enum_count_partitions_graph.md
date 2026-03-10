# Count partitions of a graph

Count the number of valid partitions of an arbitrary graph into
`num_parts` connected subgraphs, where each subgraph has between
`min_size` and `max_size` vertices. Prefer this over
[`enum_partitions_graph()`](http://christophertkenny.com/enum/reference/enum_partitions_graph.md)
when only the count is needed, as it avoids storing all partitions in
memory.

## Usage

``` r
enum_count_partitions_graph(graph, num_parts, min_size, max_size)
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

## Value

A single integer giving the number of valid partitions.

## Examples

``` r
g <- igraph::make_ring(6)
enum_count_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3)
#> [1] 3
```
