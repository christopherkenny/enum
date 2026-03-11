#' Enumerate grid partitions
#'
#' Enumerate all partitions of an `nrow` by `ncol` grid into `num_parts`
#' connected pieces. Part sizes can be constrained either as a range via
#' `min_size` and `max_size`, or as an explicit set of allowed sizes via
#' `exact_sizes`. Exactly one of these two forms must be supplied.
#'
#' @param nrow Integer. Number of rows in the grid.
#' @param ncol Integer. Number of columns in the grid.
#' @param num_parts Integer. Number of parts to partition the grid into.
#' @param min_size Integer or `NULL`. Minimum number of cells per part. Must be
#'   supplied together with `max_size`; mutually exclusive with `exact_sizes`.
#' @param max_size Integer or `NULL`. Maximum number of cells per part. Must be
#'   supplied together with `min_size`; mutually exclusive with `exact_sizes`.
#' @param exact_sizes Integer vector or `NULL`. The exact set of allowed part
#'   sizes. For example, `exact_sizes = c(4, 8)` allows parts of size 4 or 8
#'   only. Mutually exclusive with `min_size`/`max_size`.
#' @param contiguity Character. Either `"rook"` (default) for edge-adjacency
#'   or `"queen"` for edge-and-corner adjacency.
#' @param file Character or `NULL`. If a file path is provided, partitions are
#'   written to a binary file instead of returned as a matrix. Each partition is
#'   stored as `nrow * ncol` consecutive 32-bit integers. Use
#'   [enum_read_partitions()] to read the file back into R. When `file` is not
#'   `NULL`, the function returns the partition count invisibly.
#' @param progress Logical. Whether to report enumeration progress. Default
#'   `TRUE`.
#'
#' @return When `file` is `NULL` (default), an integer matrix where each column
#'   is a partition and each row corresponds to a cell of the grid in row-major
#'   order. Cell values are integers from `1` to `num_parts` indicating part
#'   membership. When `file` is a path, returns the number of partitions
#'   written, invisibly.
#' @export
#'
#' @examples
#' # Partition a 2x3 grid into 2 rook-connected parts of size 3
#' enum_partitions(2, 3, num_parts = 2, min_size = 3, max_size = 3)
#'
#' # Allow only parts of size 4 or 8 (exact sizes)
#' enum_partitions(4, 4, num_parts = 3, exact_sizes = c(4, 8))
enum_partitions <- function(
  nrow,
  ncol,
  num_parts,
  min_size = NULL,
  max_size = NULL,
  exact_sizes = NULL,
  contiguity = c('rook', 'queen'),
  file = NULL,
  progress = TRUE
) {
  contiguity <- check_contiguity(contiguity)
  check_grid_dimensions(nrow, ncol)
  check_num_parts(num_parts, nrow, ncol)
  sizes <- resolve_sizes_grid(min_size, max_size, exact_sizes, num_parts, nrow, ncol)

  nrow <- as.integer(nrow)
  ncol <- as.integer(ncol)
  num_parts <- as.integer(num_parts)

  core <- build_enumeration_core(
    make_grid_graph(nrow, ncol, contiguity),
    sizes
  )

  if (!is.null(file)) {
    return(invisible(stream_enumeration(core, num_parts, file, progress = progress)))
  }

  run_enumeration(core, num_parts, collect = TRUE, progress = progress)
}
