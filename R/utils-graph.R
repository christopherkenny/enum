make_grid_graph <- function(nrow, ncol, contiguity) {
  g <- igraph::make_lattice(c(ncol, nrow))

  if (contiguity == "queen") {
    edges <- integer(0)
    for (i in seq_len(nrow - 1L)) {
      for (j in seq_len(ncol - 1L)) {
        v <- (i - 1L) * ncol + j
        edges <- c(edges, v, v + ncol + 1L)
      }
      for (j in 2:ncol) {
        v <- (i - 1L) * ncol + j
        edges <- c(edges, v, v + ncol - 1L)
      }
    }
    g <- igraph::add_edges(g, edges)
  }

  g
}

first_zero <- function(vec) {
  which.min(vec)
}

first_one <- function(vec) {
  which.max(vec)
}

valid_omino <- function(omino, graph) {
  ones <- which(omino == 1L)
  if (length(ones) == 0L) {
    return(FALSE)
  }
  if (any(omino > 1L)) {
    return(FALSE)
  }
  igraph::is_connected(igraph::induced_subgraph(graph, ones))
}

make_omino_set <- function(cells, graph) {
  n <- igraph::vcount(graph)

  if (cells == 1L) {
    ominos <- vector("list", n)
    for (i in seq_len(n)) {
      om <- integer(n)
      om[i] <- 1L
      ominos[[i]] <- om
    }
    return(ominos)
  }

  combos <- utils::combn(seq_len(n), cells)
  ominos <- list()
  for (k in seq_len(ncol(combos))) {
    om <- integer(n)
    om[combos[, k]] <- 1L
    if (valid_omino(om, graph)) {
      ominos <- c(ominos, list(om))
    }
  }
  ominos
}

grow_ominos <- function(ominos, graph) {
  n <- igraph::vcount(graph)
  seen <- list()
  result <- list()

  for (om in ominos) {
    for (pos in seq_len(n)) {
      if (om[pos] == 0L) {
        candidate <- om
        candidate[pos] <- 1L
        if (valid_omino(candidate, graph)) {
          key <- paste0(candidate, collapse = "")
          if (is.null(seen[[key]])) {
            seen[[key]] <- TRUE
            result <- c(result, list(candidate))
          }
        }
      }
    }
  }

  result
}

bad_hole_sizes <- function(min_size, max_size) {
  low <- if (min_size > 1L) seq_len(min_size - 1L) else integer(0)
  high_start <- max_size + 1L
  high_end <- 2L * min_size - 1L
  high <- if (high_start <= high_end) high_start:high_end else integer(0)
  c(low, high)
}

check_holes <- function(omino, bad_holes, graph) {
  zeros <- which(omino == 0L)
  if (length(zeros) == 0L) {
    return(TRUE)
  }
  comps <- igraph::components(igraph::induced_subgraph(graph, zeros))
  !any(comps$csize %in% bad_holes)
}

build_conflicts <- function(ominos, bad_holes, graph) {
  n_om <- length(ominos)
  n <- igraph::vcount(graph)

  first_dict <- vector("list", n)
  for (i in seq_len(n)) {
    first_dict[[i]] <- integer(0)
  }
  for (i in seq_len(n_om)) {
    k <- first_one(ominos[[i]])
    first_dict[[k]] <- c(first_dict[[k]], i)
  }

  compatible <- vector("list", n_om)
  for (i in seq_len(n_om)) {
    compatible[[i]] <- integer(0)
  }

  for (i in seq_len(n_om - 1L)) {
    for (j in (i + 1L):n_om) {
      combined <- ominos[[i]] + ominos[[j]]
      if (!any(combined > 1L) && check_holes(combined, bad_holes, graph)) {
        compatible[[i]] <- c(compatible[[i]], j)
        compatible[[j]] <- c(compatible[[j]], i)
      }
    }
  }

  list(first_dict = first_dict, compatible = compatible)
}
