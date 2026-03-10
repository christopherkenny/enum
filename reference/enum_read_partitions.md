# Read partitions from a binary file

Read the binary file produced by
[`enum_partitions()`](http://christophertkenny.com/enum/reference/enum_partitions.md)
or
[`enum_partitions_graph()`](http://christophertkenny.com/enum/reference/enum_partitions_graph.md)
when called with the `file` argument.

## Usage

``` r
enum_read_partitions(file, skip = 0L, n = NULL)
```

## Arguments

- file:

  Character. Path to the binary file.

- skip:

  Integer. Number of partitions to skip before reading. Defaults to `0`.

- n:

  Integer or `NULL`. Number of partitions to read. If `NULL` (default),
  reads all remaining partitions.

## Value

An integer matrix with one row per cell/vertex and one column per
partition read. Cell values are integers from `1` to the number of parts
indicating part membership.

## Examples

``` r
tmp <- tempfile()
enum_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3, file = tmp)
enum_read_partitions(tmp)
#>       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
#>  [1,]    1    1    1    1    1    1    1    1    1     1
#>  [2,]    1    1    1    1    1    1    2    2    2     2
#>  [3,]    2    2    1    1    1    2    2    2    2     3
#>  [4,]    1    1    2    2    2    3    1    1    1     1
#>  [5,]    2    3    2    2    3    1    1    2    3     2
#>  [6,]    2    2    3    2    3    2    2    3    2     3
#>  [7,]    3    3    2    3    2    3    3    1    1     1
#>  [8,]    3    3    3    3    2    3    3    3    3     2
#>  [9,]    3    2    3    3    3    2    3    3    3     3
enum_read_partitions(tmp, skip = 5)
#>       [,1] [,2] [,3] [,4] [,5]
#>  [1,]    1    1    1    1    1
#>  [2,]    1    2    2    2    2
#>  [3,]    2    2    2    2    3
#>  [4,]    3    1    1    1    1
#>  [5,]    1    1    2    3    2
#>  [6,]    2    2    3    2    3
#>  [7,]    3    3    1    1    1
#>  [8,]    3    3    3    3    2
#>  [9,]    2    3    3    3    3
enum_read_partitions(tmp, skip = 2, n = 3)
#>       [,1] [,2] [,3]
#>  [1,]    1    1    1
#>  [2,]    1    1    1
#>  [3,]    1    1    1
#>  [4,]    2    2    2
#>  [5,]    2    2    3
#>  [6,]    3    2    3
#>  [7,]    2    3    2
#>  [8,]    3    3    2
#>  [9,]    3    3    3
```
