# Count partitions of a graph

Count the number of valid partitions of an arbitrary graph into
`num_parts` connected subgraphs. Part sizes can be constrained either as
a range via `min_size` and `max_size`, or as an explicit set of allowed
sizes via `exact_sizes`. Prefer this over
[`enum_partitions_graph()`](http://christophertkenny.com/enum/reference/enum_partitions_graph.md)
when only the count is needed, as it avoids storing all partitions in
memory.

## Usage

``` r
enum_count_partitions_graph(
  graph,
  num_parts,
  min_size = NULL,
  max_size = NULL,
  exact_sizes = NULL,
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

- progress:

  Logical. Whether to report enumeration progress. Default `TRUE`.

## Value

A single integer giving the number of valid partitions.

## Examples

``` r
g <- igraph::make_ring(6)
enum_count_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3)
#>  ■                                  0% |  ETA: ?
#>  ■■■■■■■■■■■                       33% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■             67% |  ETA:  0s
#> [1] 3
```
