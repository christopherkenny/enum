#' Count partitions of a graph
#'
#' Count the number of valid partitions of an arbitrary graph into `num_parts`
#' connected subgraphs. Part sizes can be constrained either as a range via
#' `min_size` and `max_size`, or as an explicit set of allowed sizes via
#' `exact_sizes`. Prefer this over [enum_partitions_graph()] when only the
#' count is needed, as it avoids storing all partitions in memory.
#'
#' @inheritParams enum_partitions_graph
#'
#' @return A single integer giving the number of valid partitions.
#' @export
#'
#' @examples
#' g <- igraph::make_ring(6)
#' enum_count_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3)
enum_count_partitions_graph <- function(
  graph,
  num_parts,
  min_size = NULL,
  max_size = NULL,
  exact_sizes = NULL,
  progress = TRUE
) {
  graph <- to_igraph(graph)
  check_graph(graph)
  total <- igraph::vcount(graph)
  check_num_parts_graph(num_parts, total)
  sizes <- resolve_sizes_graph(min_size, max_size, exact_sizes, num_parts, total)

  num_parts <- as.integer(num_parts)

  core <- build_enumeration_core(graph, sizes)
  run_enumeration(core, num_parts, collect = FALSE, progress = progress)
}
