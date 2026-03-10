#' Enumerate partitions of a graph
#'
#' Enumerate all partitions of an arbitrary graph into `num_parts` connected
#' subgraphs, where each subgraph has between `min_size` and `max_size`
#' vertices. Accepts `igraph` objects and `adj` objects (1-indexed adjacency
#' lists).
#'
#' @param graph An `igraph` or `adj` object. Must be undirected and connected.
#'   An `adj` object is a list where element `i` contains the integer indices
#'   (1-indexed) of vertices adjacent to vertex `i`.
#' @param num_parts Integer. Number of parts to partition the graph into.
#' @param min_size Integer. Minimum number of vertices per part.
#' @param max_size Integer. Maximum number of vertices per part.
#'
#' @return An integer matrix where each column is a partition and each row
#'   corresponds to a vertex (in igraph vertex order). Cell values are integers
#'   from `1` to `num_parts` indicating part membership.
#' @export
#'
#' @examples
#' g <- igraph::make_ring(6)
#' enum_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3)
enum_partitions_graph <- function(graph, num_parts, min_size, max_size) {
  graph <- to_igraph(graph)
  check_graph(graph)
  total <- igraph::vcount(graph)
  check_num_parts_graph(num_parts, total)
  check_sizes_graph(min_size, max_size, num_parts, total)

  num_parts <- as.integer(num_parts)
  min_size <- as.integer(min_size)
  max_size <- as.integer(max_size)

  core <- build_enumeration_core(graph, min_size, max_size)
  run_enumeration(core, num_parts, collect = TRUE)
}
