#' Read partitions from a binary file
#'
#' Read the binary file produced by [enum_partitions()] or
#' [enum_partitions_graph()] when called with the `file` argument.
#'
#' @param file Character. Path to the binary file.
#' @param skip Integer. Number of partitions to skip before reading.
#'   Defaults to `0`.
#' @param n Integer or `NULL`. Number of partitions to read. If `NULL`
#'   (default), reads all remaining partitions.
#'
#' @return An integer matrix with one row per cell/vertex and one column per
#'   partition read. Cell values are integers from `1` to the number of parts
#'   indicating part membership.
#' @export
#'
#' @examples
#' tmp <- tempfile()
#' enum_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3, file = tmp)
#' enum_read_partitions(tmp)
#' enum_read_partitions(tmp, skip = 5)
#' enum_read_partitions(tmp, skip = 2, n = 3)
enum_read_partitions <- function(file, skip = 0L, n = NULL) {
  skip <- as.integer(skip)
  con <- base::file(file, "rb")
  on.exit(close(con))
  n_cells <- readBin(con, what = integer(), n = 1L)
  if (skip > 0L) {
    seek(con, where = as.numeric(skip) * n_cells * 4, origin = "current")
  }
  n_ints <- if (is.null(n)) {
    file.info(file)$size / 4 - 1 - as.numeric(skip) * n_cells
  } else {
    as.integer(n) * n_cells
  }
  raw_data <- readBin(con, what = integer(), n = n_ints)
  matrix(raw_data, nrow = n_cells)
}
