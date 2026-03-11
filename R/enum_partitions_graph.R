#' Enumerate partitions of a graph
#'
#' Enumerate all partitions of an arbitrary graph into `num_parts` connected
#' subgraphs. Part sizes can be constrained either as a range via `min_size`
#' and `max_size`, or as an explicit set of allowed sizes via `exact_sizes`.
#' Accepts `igraph` objects and `adj` objects (1-indexed adjacency lists).
#'
#' @param graph An `igraph` or `adj` object. Must be undirected and connected.
#'   An `adj` object is a list where element `i` contains the integer indices
#'   (1-indexed) of vertices adjacent to vertex `i`.
#' @param num_parts Integer. Number of parts to partition the graph into.
#' @param min_size Integer or `NULL`. Minimum number of vertices per part. Must
#'   be supplied together with `max_size`; mutually exclusive with
#'   `exact_sizes`.
#' @param max_size Integer or `NULL`. Maximum number of vertices per part. Must
#'   be supplied together with `min_size`; mutually exclusive with
#'   `exact_sizes`.
#' @param exact_sizes Integer vector or `NULL`. The exact set of allowed part
#'   sizes. Mutually exclusive with `min_size`/`max_size`.
#' @param file Character or `NULL`. If a file path is provided, partitions are
#'   written to a binary file instead of returned as a matrix. Each partition is
#'   stored as one 32-bit integer per vertex. Use [enum_read_partitions()] to
#'   read the file back into R. When `file` is not `NULL`, the function returns
#'   the partition count invisibly.
#' @param progress Logical. Whether to report enumeration progress. Default
#'   `TRUE`.
#'
#' @return When `file` is `NULL` (default), an integer matrix where each column
#'   is a partition and each row corresponds to a vertex (in igraph vertex
#'   order). Cell values are integers from `1` to `num_parts` indicating part
#'   membership. When `file` is a path, returns the number of partitions
#'   written, invisibly.
#' @export
#'
#' @examples
#' g <- igraph::make_ring(6)
#' enum_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3)
enum_partitions_graph <- function(
  graph,
  num_parts,
  min_size = NULL,
  max_size = NULL,
  exact_sizes = NULL,
  file = NULL,
  progress = TRUE
) {
  graph <- to_igraph(graph)
  check_graph(graph)
  total <- igraph::vcount(graph)
  check_num_parts_graph(num_parts, total)
  sizes <- resolve_sizes_graph(min_size, max_size, exact_sizes, num_parts, total)

  num_parts <- as.integer(num_parts)

  core <- build_enumeration_core(graph, sizes)

  if (!is.null(file)) {
    return(invisible(stream_enumeration(core, num_parts, file, progress = progress)))
  }

  run_enumeration(core, num_parts, collect = TRUE, progress = progress)
}
