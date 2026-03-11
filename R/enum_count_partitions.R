#' Count grid partitions
#'
#' Count the number of valid partitions of an `nrow` by `ncol` grid into
#' `num_parts` connected pieces. Part sizes can be constrained either as a
#' range via `min_size` and `max_size`, or as an explicit set of allowed sizes
#' via `exact_sizes`. Prefer this over [enum_partitions()] when only the count
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
#'
#' # Count with exact sizes
#' enum_count_partitions(4, 4, num_parts = 3, exact_sizes = c(4, 8))
enum_count_partitions <- function(
  nrow,
  ncol,
  num_parts,
  min_size = NULL,
  max_size = NULL,
  exact_sizes = NULL,
  contiguity = c('rook', 'queen'),
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
  run_enumeration(core, num_parts, collect = FALSE, progress = progress)
}
