#' Enumerate grid partitions
#'
#' Enumerate all partitions of an `nrow` by `ncol` grid into `num_parts`
#' connected pieces, where each piece has between `min_size` and `max_size`
#' cells.
#'
#' @param nrow Integer. Number of rows in the grid.
#' @param ncol Integer. Number of columns in the grid.
#' @param num_parts Integer. Number of parts to partition the grid into.
#' @param min_size Integer. Minimum number of cells per part.
#' @param max_size Integer. Maximum number of cells per part.
#' @param contiguity Character. Either `"rook"` (default) for edge-adjacency
#'   or `"queen"` for edge-and-corner adjacency.
#' @param file Character or `NULL`. If a file path is provided, partitions are
#'   written to a binary file instead of returned as a matrix. Each partition is
#'   stored as `nrow * ncol` consecutive 32-bit integers. Use
#'   [enum_read_partitions()] to read the file back into R. When `file` is not
#'   `NULL`, the function returns the partition count invisibly.
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
enum_partitions <- function(
  nrow,
  ncol,
  num_parts,
  min_size,
  max_size,
  contiguity = c('rook', 'queen'),
  file = NULL
) {
  contiguity <- check_contiguity(contiguity)
  check_grid_dimensions(nrow, ncol)
  check_num_parts(num_parts, nrow, ncol)
  check_sizes(min_size, max_size, num_parts, nrow, ncol)

  nrow <- as.integer(nrow)
  ncol <- as.integer(ncol)
  num_parts <- as.integer(num_parts)
  min_size <- as.integer(min_size)
  max_size <- as.integer(max_size)

  core <- build_enumeration_core(
    make_grid_graph(nrow, ncol, contiguity),
    min_size,
    max_size
  )

  if (!is.null(file)) {
    return(invisible(stream_enumeration(core, num_parts, file)))
  }

  run_enumeration(core, num_parts, collect = TRUE)
}
