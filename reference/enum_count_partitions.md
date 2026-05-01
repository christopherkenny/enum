# Count grid partitions

Count the number of valid partitions of an `nrow` by `ncol` grid into
`num_parts` connected pieces. Part sizes can be constrained either as a
range via `min_size` and `max_size`, or as an explicit set of allowed
sizes via `exact_sizes`. Prefer this over
[`enum_partitions()`](http://christophertkenny.com/enum/reference/enum_partitions.md)
when only the count is needed, as it avoids storing all partitions in
memory.

## Usage

``` r
enum_count_partitions(
  nrow,
  ncol,
  num_parts,
  min_size = NULL,
  max_size = NULL,
  exact_sizes = NULL,
  contiguity = c("rook", "queen"),
  progress = TRUE
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

  Integer or `NULL`. Minimum number of cells per part. Must be supplied
  together with `max_size`; mutually exclusive with `exact_sizes`.

- max_size:

  Integer or `NULL`. Maximum number of cells per part. Must be supplied
  together with `min_size`; mutually exclusive with `exact_sizes`.

- exact_sizes:

  Integer vector or `NULL`. The exact set of allowed part sizes. For
  example, `exact_sizes = c(4, 8)` allows parts of size 4 or 8 only.
  Mutually exclusive with `min_size`/`max_size`.

- contiguity:

  Character. Either `"rook"` (default) for edge-adjacency or `"queen"`
  for edge-and-corner adjacency.

- progress:

  Logical. Whether to report enumeration progress. Default `TRUE`.

## Value

A single integer giving the number of valid partitions.

## Examples

``` r
# Count partitions of a 2x3 grid into 2 rook-connected parts of size 3
enum_count_partitions(2, 3, num_parts = 2, min_size = 3, max_size = 3)
#>  ■                                  0% |  ETA: ?
#>  ■■■■■■■■■■■                       33% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■             67% |  ETA:  0s
#> [1] 3

# Count with exact sizes
enum_count_partitions(4, 4, num_parts = 3, exact_sizes = c(4, 8))
#>  ■                                  0% |  ETA: ?
#>  ■                                  1% |  ETA:  1s
#>  ■■                                 2% |  ETA:  1s
#>  ■■                                 3% |  ETA:  1s
#>  ■■                                 4% |  ETA:  1s
#>  ■■                                 5% |  ETA:  1s
#>  ■■■                                5% |  ETA:  1s
#>  ■■■                                6% |  ETA:  1s
#>  ■■■                                7% |  ETA:  1s
#>  ■■■                                8% |  ETA:  1s
#>  ■■■■                               9% |  ETA:  1s
#>  ■■■■                              10% |  ETA:  1s
#>  ■■■■                              11% |  ETA:  1s
#>  ■■■■■                             12% |  ETA:  1s
#>  ■■■■■                             13% |  ETA:  1s
#>  ■■■■■                             14% |  ETA:  1s
#>  ■■■■■                             14% |  ETA:  1s
#>  ■■■■■■                            15% |  ETA:  1s
#>  ■■■■■■                            16% |  ETA:  1s
#>  ■■■■■■                            17% |  ETA:  1s
#>  ■■■■■■                            18% |  ETA:  1s
#>  ■■■■■■■                           19% |  ETA:  1s
#>  ■■■■■■■                           20% |  ETA:  1s
#>  ■■■■■■■                           21% |  ETA:  1s
#>  ■■■■■■■                           22% |  ETA:  1s
#>  ■■■■■■■■                          23% |  ETA:  1s
#>  ■■■■■■■■                          23% |  ETA:  1s
#>  ■■■■■■■■                          24% |  ETA:  1s
#>  ■■■■■■■■■                         25% |  ETA:  1s
#>  ■■■■■■■■■                         26% |  ETA:  1s
#>  ■■■■■■■■■                         27% |  ETA:  1s
#>  ■■■■■■■■■                         28% |  ETA:  1s
#>  ■■■■■■■■■■                        29% |  ETA:  1s
#>  ■■■■■■■■■■                        30% |  ETA:  1s
#>  ■■■■■■■■■■                        31% |  ETA:  1s
#>  ■■■■■■■■■■                        32% |  ETA:  1s
#>  ■■■■■■■■■■■                       32% |  ETA:  1s
#>  ■■■■■■■■■■■                       33% |  ETA:  1s
#>  ■■■■■■■■■■■                       34% |  ETA:  1s
#>  ■■■■■■■■■■■■                      35% |  ETA:  1s
#>  ■■■■■■■■■■■■                      36% |  ETA:  1s
#>  ■■■■■■■■■■■■                      37% |  ETA:  1s
#>  ■■■■■■■■■■■■                      38% |  ETA:  1s
#>  ■■■■■■■■■■■■■                     39% |  ETA:  1s
#>  ■■■■■■■■■■■■■                     40% |  ETA:  1s
#>  ■■■■■■■■■■■■■                     41% |  ETA:  1s
#>  ■■■■■■■■■■■■■                     41% |  ETA:  1s
#>  ■■■■■■■■■■■■■■                    42% |  ETA:  1s
#>  ■■■■■■■■■■■■■■                    43% |  ETA:  1s
#>  ■■■■■■■■■■■■■■                    44% |  ETA:  1s
#>  ■■■■■■■■■■■■■■■                   45% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■                   46% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■                   47% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■                   48% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■                  49% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■                  50% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■                  50% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■                  51% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■                 52% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■                 53% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■                 54% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■                 55% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■                56% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■                57% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■                58% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■               59% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■               59% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■               60% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■               61% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■              62% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■              63% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■              64% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■              65% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■             66% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■             67% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■             68% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■            68% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■            69% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■            70% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■            71% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■           72% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■           73% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■           74% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■           75% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■          76% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■          77% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■          77% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■         78% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■         79% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■         80% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■         81% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■        82% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■        83% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■        84% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■        85% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■       86% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■       86% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■       87% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■       88% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      89% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      91% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     92% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     93% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     94% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     95% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■    95% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■    96% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■    97% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■    98% |  ETA:  0s
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■   99% |  ETA:  0s
#> [1] 326
```
