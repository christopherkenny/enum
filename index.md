# enum

`enum` enumerates all partitions of a graph into `k` connected pieces
within given piece-size bounds. It is a reimplementation of the Julia
[enumerator](https://github.com/zschutzman/enumerator) package by
Zachary Schutzman, with core algorithms written in C and support for
[igraph](https://r.igraph.org/) objects as input. Piece sizes can be
constrained as a range (`min_size`/`max_size`) or as an exact set of
allowed sizes (`exact_sizes`).

## Installation

``` r

# install.packages('pak')
pak::pak('christopherkenny/enum')
```

## Usage

### Grid partitions

The primary interface partitions rectangular grids under rook or queen
contiguity. Each column of the returned matrix is one valid partition;
each row corresponds to a grid cell in row-major order, with integer
values giving part membership.

``` r

library(enum)

# All ways to split a 3x3 grid into 3 rook-connected pieces of size 3
enum_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3, progress = FALSE)
#>       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
#>  [1,]    1    1    1    1    1    1    1    1    1     1
#>  [2,]    2    1    1    2    2    2    1    1    1     1
#>  [3,]    2    2    2    2    3    2    2    1    1     1
#>  [4,]    1    1    1    1    1    1    3    2    2     2
#>  [5,]    1    2    3    2    2    3    1    3    2     2
#>  [6,]    2    2    2    3    3    2    2    3    3     2
#>  [7,]    3    3    3    1    1    1    3    2    2     3
#>  [8,]    3    3    3    3    2    3    3    2    3     3
#>  [9,]    3    3    2    3    3    3    2    3    3     3
```

For example, one valid partition of the 3×3 grid

``` R
1 1 2
1 2 2
3 3 3
```

is stored as the column `c(1, 1, 2, 1, 2, 2, 3, 3, 3)`.

We can also count the number, which is faster if you don’t need the full
output:

``` r

enum_count_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3, progress = FALSE)
#> [1] 10
```

Instead of a size range, pass `exact_sizes` to restrict parts to a
specific set of allowed sizes. This is useful when parts must satisfy a
particular integer relationship—for example, parts of size `k` and `2k`:

``` r

# 4x4 grid into 3 parts, each exactly size 4 or 8 (i.e. 4+4+8=16 cells)
enum_count_partitions(4, 4, num_parts = 3, exact_sizes = c(4, 8), progress = FALSE)
#> [1] 326
```

### Graph partitions

For arbitrary graphs, pass an `igraph` object (or an [`adj`
object](https://alarm-redist.org/adj/)):

``` r

library(igraph)
#> Warning: package 'igraph' was built under R version 4.5.2
#> 
#> Attaching package: 'igraph'
#> The following object is masked from 'package:testthat':
#> 
#>     compare
#> The following objects are masked from 'package:stats':
#> 
#>     decompose, spectrum
#> The following object is masked from 'package:base':
#> 
#>     union

g <- make_ring(6)
enum_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3, progress = FALSE)
#>      [,1] [,2] [,3]
#> [1,]    1    1    1
#> [2,]    1    1    2
#> [3,]    2    1    2
#> [4,]    2    2    2
#> [5,]    2    2    1
#> [6,]    1    2    1
```

### Writing to file

For large enumerations that would exceed available memory, pass a file
path to write partitions directly to disk. Each partition is appended as
it is found, so memory use stays flat.

``` r

tmp <- tempfile()
n <- enum_partitions(4, 4, num_parts = 4, min_size = 4, max_size = 4, file = tmp, progress = FALSE)
n  # number of partitions written
#> [1] 117
```

Read them back all at once, or in chunks using `skip` and `n`:

``` r

# All 117 partitions
mat <- enum_read_partitions(tmp)
dim(mat)
#> [1]  16 117

# Partitions 11–20 only
enum_read_partitions(tmp, skip = 10, n = 10)
#>       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
#>  [1,]    1    1    1    1    1    1    1    1    1     1
#>  [2,]    1    1    1    1    1    2    2    2    2     1
#>  [3,]    1    1    1    1    1    2    2    2    2     2
#>  [4,]    2    2    2    2    2    2    2    2    2     2
#>  [5,]    3    3    3    3    3    1    1    1    1     3
#>  [6,]    1    1    1    1    1    1    1    1    1     1
#>  [7,]    2    2    2    4    4    1    1    1    1     4
#>  [8,]    2    2    2    2    2    2    2    2    2     2
#>  [9,]    3    3    3    3    3    3    3    3    3     3
#> [10,]    3    3    4    3    4    3    3    4    3     1
#> [11,]    3    4    4    4    4    4    3    4    3     4
#> [12,]    2    2    2    2    2    4    3    4    4     2
#> [13,]    4    3    3    3    3    3    4    3    3     3
#> [14,]    4    4    3    4    3    3    4    3    4     3
#> [15,]    4    4    4    4    4    4    4    3    4     4
#> [16,]    4    4    4    2    2    4    4    4    4     4
```
