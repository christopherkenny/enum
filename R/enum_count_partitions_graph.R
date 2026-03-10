#' Count partitions of a graph
#'
#' Count the number of valid partitions of an arbitrary graph into `num_parts`
#' connected subgraphs, where each subgraph has between `min_size` and
#' `max_size` vertices. Prefer this over [enum_partitions_graph()] when only
#' the count is needed, as it avoids storing all partitions in memory.
#'
#' @inheritParams enum_partitions_graph
#'
#' @return A single integer giving the number of valid partitions.
#' @export
#'
#' @examples
#' g <- igraph::make_ring(6)
#' enum_count_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3)
enum_count_partitions_graph <- function(graph, num_parts, min_size, max_size) {
  graph <- to_igraph(graph)
  check_graph(graph)
  total <- igraph::vcount(graph)
  check_num_parts_graph(num_parts, total)
  check_sizes_graph(min_size, max_size, num_parts, total)

  num_parts <- as.integer(num_parts)
  min_size <- as.integer(min_size)
  max_size <- as.integer(max_size)

  core <- build_enumeration_core(graph, min_size, max_size)
  run_enumeration(core, num_parts, collect = FALSE)
}
