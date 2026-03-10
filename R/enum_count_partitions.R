#' Count grid partitions
#'
#' Count the number of valid partitions of an `nrow` by `ncol` grid into
#' `num_parts` connected pieces, where each piece has between `min_size` and
#' `max_size` cells. Prefer this over [enum_partitions()] when only the count
#' is needed, as it avoids storing all partitions in memory.
#'
#' @inheritParams enum_partitions
#'
#' @return A single integer giving the number of valid partitions.
#' @export
#'
#' @examples
#' # Count partitions of a 2x3 grid into 2 rook-connected parts of size 3
#' enum_count_partitions(2, 3, num_parts = 2, min_size = 3, max_size = 3)
enum_count_partitions <- function(
  nrow,
  ncol,
  num_parts,
  min_size,
  max_size,
  contiguity = c("rook", "queen")
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
  run_enumeration(core, num_parts, collect = FALSE)
}
