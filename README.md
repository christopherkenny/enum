
<!-- README.md is generated from README.Rmd. Please edit that file -->

# enum

<!-- badges: start -->

<!-- badges: end -->

`enum` enumerates all partitions of a graph into `k` connected pieces
within given piece-size bounds. It is a direct R translation of the
Julia [enumerator](https://github.com/zschutzman/enumerator) package by
Zachary Schutzman, reimplemented using [igraph](https://r.igraph.org/).

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
enum_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3)
#>       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
#>  [1,]    1    1    1    1    1    1    1    1    1     1
#>  [2,]    1    1    1    1    1    1    2    2    2     2
#>  [3,]    1    1    1    2    2    2    2    2    2     3
#>  [4,]    2    2    2    1    1    3    1    1    1     1
#>  [5,]    2    2    3    2    3    1    1    2    3     2
#>  [6,]    2    3    3    2    2    2    2    3    2     3
#>  [7,]    3    2    2    3    3    3    3    1    1     1
#>  [8,]    3    3    2    3    3    3    3    3    3     2
#>  [9,]    3    3    3    3    2    2    3    3    3     3
```

For example, one valid partition of the 3×3 grid

    1 1 2
    1 2 2
    3 3 3

is stored as the column `c(1, 1, 2, 1, 2, 2, 3, 3, 3)`.

We can also count the number, which is faster if you don’t need the full
output:

``` r
enum_count_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3)
#> [1] 10
```

### Graph partitions

For arbitrary graphs, pass an `igraph` object (or an [`adj`
object](https://alarm-redist.org/adj/)):

``` r
library(igraph)

g <- make_ring(6)
enum_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3)
```
