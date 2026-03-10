# Count grid partitions

Count the number of valid partitions of an `nrow` by `ncol` grid into
`num_parts` connected pieces, where each piece has between `min_size`
and `max_size` cells. Prefer this over
[`enum_partitions()`](http://christophertkenny.com/enum/reference/enum_partitions.md)
when only the count is needed, as it avoids storing all partitions in
memory.

## Usage

``` r
enum_count_partitions(
  nrow,
  ncol,
  num_parts,
  min_size,
  max_size,
  contiguity = c("rook", "queen")
)
```

## Arguments

- nrow:

  Integer. Number of rows in the grid.

- ncol:

  Integer. Number of columns in the grid.

- num_parts:

  Integer. Number of parts to partition the grid into.

- min_size:

  Integer. Minimum number of cells per part.

- max_size:

  Integer. Maximum number of cells per part.

- contiguity:

  Character. Either `"rook"` (default) for edge-adjacency or `"queen"`
  for edge-and-corner adjacency.

## Value

A single integer giving the number of valid partitions.

## Examples

``` r
# Count partitions of a 2x3 grid into 2 rook-connected parts of size 3
enum_count_partitions(2, 3, num_parts = 2, min_size = 3, max_size = 3)
#> [1] 3
```
