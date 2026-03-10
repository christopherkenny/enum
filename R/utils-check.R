check_grid_dimensions <- function(nrow, ncol) {
  if (
    !is.numeric(nrow) ||
      length(nrow) != 1L ||
      nrow < 1L ||
      nrow != as.integer(nrow)
  ) {
    cli::cli_abort("{.arg nrow} must be a single positive integer.")
  }
  if (
    !is.numeric(ncol) ||
      length(ncol) != 1L ||
      ncol < 1L ||
      ncol != as.integer(ncol)
  ) {
    cli::cli_abort("{.arg ncol} must be a single positive integer.")
  }
}

check_num_parts <- function(num_parts, nrow, ncol) {
  if (
    !is.numeric(num_parts) ||
      length(num_parts) != 1L ||
      num_parts < 1L ||
      num_parts != as.integer(num_parts)
  ) {
    cli::cli_abort("{.arg num_parts} must be a single positive integer.")
  }
  total <- nrow * ncol
  if (num_parts > total) {
    cli::cli_abort(
      "{.arg num_parts} ({num_parts}) cannot exceed the number of grid cells ({total})."
    )
  }
}

check_sizes <- function(min_size, max_size, num_parts, nrow, ncol) {
  if (
    !is.numeric(min_size) ||
      length(min_size) != 1L ||
      min_size < 1L ||
      min_size != as.integer(min_size)
  ) {
    cli::cli_abort("{.arg min_size} must be a single positive integer.")
  }
  if (
    !is.numeric(max_size) ||
      length(max_size) != 1L ||
      max_size < 1L ||
      max_size != as.integer(max_size)
  ) {
    cli::cli_abort("{.arg max_size} must be a single positive integer.")
  }
  if (min_size > max_size) {
    cli::cli_abort(
      "{.arg min_size} ({min_size}) must be <= {.arg max_size} ({max_size})."
    )
  }

  total <- nrow * ncol
  if (num_parts * max_size < total) {
    cli::cli_abort(
      paste0(
        "Impossible to tile: {num_parts} parts of at most size {max_size} ",
        "cannot cover {total} cells."
      )
    )
  }
  if (num_parts * min_size > total) {
    cli::cli_abort(
      paste0(
        "Impossible to tile: {num_parts} parts of at least size {min_size} ",
        "exceed {total} cells."
      )
    )
  }
}

check_contiguity <- function(contiguity) {
  match.arg(contiguity, c("rook", "queen"))
}

check_graph <- function(graph) {
  if (igraph::is_directed(graph)) {
    cli::cli_abort("{.arg graph} must be undirected.")
  }
  if (!igraph::is_connected(graph)) {
    cli::cli_abort("{.arg graph} must be connected.")
  }
  if (igraph::vcount(graph) == 0L) {
    cli::cli_abort("{.arg graph} must have at least one vertex.")
  }
}

check_num_parts_graph <- function(num_parts, total) {
  if (
    !is.numeric(num_parts) ||
      length(num_parts) != 1L ||
      num_parts < 1L ||
      num_parts != as.integer(num_parts)
  ) {
    cli::cli_abort("{.arg num_parts} must be a single positive integer.")
  }
  if (num_parts > total) {
    cli::cli_abort(
      "{.arg num_parts} ({num_parts}) cannot exceed the number of vertices ({total})."
    )
  }
}

check_sizes_graph <- function(min_size, max_size, num_parts, total) {
  if (
    !is.numeric(min_size) ||
      length(min_size) != 1L ||
      min_size < 1L ||
      min_size != as.integer(min_size)
  ) {
    cli::cli_abort("{.arg min_size} must be a single positive integer.")
  }
  if (
    !is.numeric(max_size) ||
      length(max_size) != 1L ||
      max_size < 1L ||
      max_size != as.integer(max_size)
  ) {
    cli::cli_abort("{.arg max_size} must be a single positive integer.")
  }
  if (min_size > max_size) {
    cli::cli_abort(
      "{.arg min_size} ({min_size}) must be <= {.arg max_size} ({max_size})."
    )
  }
  if (num_parts * max_size < total) {
    cli::cli_abort(
      paste0(
        "Impossible to partition: {num_parts} parts of at most size ",
        "{max_size} cannot cover {total} vertices."
      )
    )
  }
  if (num_parts * min_size > total) {
    cli::cli_abort(
      paste0(
        "Impossible to partition: {num_parts} parts of at least size ",
        "{min_size} exceed {total} vertices."
      )
    )
  }
}

# Convert an adjacency object to igraph. Accepts igraph objects (passed
# through) and `adj` objects (1-indexed adjacency lists where adj[[i]]
# contains the integer neighbors of vertex i).
to_igraph <- function(graph) {
  if (igraph::is_igraph(graph)) {
    return(graph)
  }
  if (inherits(graph, "adj")) {
    return(adj_to_igraph(graph))
  }
  cli::cli_abort(
    "{.arg graph} must be an {.cls igraph} or {.cls adj} object."
  )
}

adj_to_igraph <- function(adj_obj) {
  n <- length(adj_obj)
  edge_list <- integer(0)
  for (i in seq_len(n)) {
    for (j in adj_obj[[i]]) {
      if (j > i) {
        edge_list <- c(edge_list, i, j)
      }
    }
  }
  if (length(edge_list) == 0L) {
    igraph::make_empty_graph(n, directed = FALSE)
  } else {
    igraph::make_graph(edge_list, n = n, directed = FALSE)
  }
}
