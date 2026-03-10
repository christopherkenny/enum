# Enumerate grid partitions

Enumerate all partitions of an `nrow` by `ncol` grid into `num_parts`
connected pieces, where each piece has between `min_size` and `max_size`
cells.

## Usage

``` r
enum_partitions(
  nrow,
  ncol,
  num_parts,
  min_size,
  max_size,
  contiguity = c("rook", "queen"),
  file = NULL
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

- file:

  Character or `NULL`. If a file path is provided, partitions are
  written to a binary file instead of returned as a matrix. Each
  partition is stored as `nrow * ncol` consecutive 32-bit integers. Use
  [`enum_read_partitions()`](http://christophertkenny.com/enum/reference/enum_read_partitions.md)
  to read the file back into R. When `file` is not `NULL`, the function
  returns the partition count invisibly.

## Value

When `file` is `NULL` (default), an integer matrix where each column is
a partition and each row corresponds to a cell of the grid in row-major
order. Cell values are integers from `1` to `num_parts` indicating part
membership. When `file` is a path, returns the number of partitions
written, invisibly.

## Examples

``` r
# Partition a 2x3 grid into 2 rook-connected parts of size 3
enum_partitions(2, 3, num_parts = 2, min_size = 3, max_size = 3)
#>      [,1] [,2] [,3]
#> [1,]    1    1    1
#> [2,]    1    1    2
#> [3,]    2    1    2
#> [4,]    1    2    1
#> [5,]    2    2    1
#> [6,]    2    2    2
```
