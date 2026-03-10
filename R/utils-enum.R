build_enumeration_core <- function(graph, min_size, max_size) {
  total <- as.integer(igraph::vcount(graph))
  sizes <- min_size:max_size
  bad_holes <- bad_hole_sizes(min_size, max_size)

  tmp_ominos <- make_omino_set(1L, graph)
  ominos <- if (1L %in% sizes) tmp_ominos else list()

  if (max_size >= 2L) {
    for (sz in 2:max_size) {
      tmp_ominos <- grow_ominos(tmp_ominos, graph)
      if (sz %in% sizes) {
        ominos <- c(ominos, tmp_ominos)
      }
    }
  }

  if (length(ominos) == 0L) {
    return(list(
      ominos_mat = matrix(integer(0), nrow = total, ncol = 0L),
      fd_ptr = integer(total + 1L),
      fd_data = integer(0L),
      cp_ptr = integer(1L),
      cp_data = integer(0L),
      n_ominos = 0L,
      total = total
    ))
  }

  ominos_mat <- matrix(unlist(ominos, use.names = FALSE), nrow = total)

  adj_list <- igraph::as_adj_list(graph, mode = "all")
  adj_ptr <- c(0L, cumsum(lengths(adj_list, use.names = FALSE)))
  adj_data <- unlist(lapply(adj_list, as.integer), use.names = FALSE) - 1L

  c_result <- .Call(
    C_build_conflicts,
    ominos_mat,
    as.integer(bad_holes),
    adj_ptr,
    adj_data,
    as.integer(total),
    as.integer(ncol(ominos_mat))
  )

  list(
    ominos_mat = c_result$ominos,
    fd_ptr = c_result$fd_ptr,
    fd_data = c_result$fd_data,
    cp_ptr = c_result$cp_ptr,
    cp_data = c_result$cp_data,
    n_ominos = ncol(c_result$ominos),
    total = total
  )
}

verify_plan <- function(plan, compatible) {
  n <- length(plan)
  if (n < 2L) {
    return(TRUE)
  }
  new_idx <- plan[n]
  for (i in seq_len(n - 1L)) {
    if (!(new_idx %in% compatible[[plan[i]]])) {
      return(FALSE)
    }
  }
  TRUE
}

# Run the recursive partition enumeration via C. When collect = TRUE, returns a
# matrix; when collect = FALSE, returns only the integer count.
run_enumeration <- function(core, num_parts, collect) {
  if (core$n_ominos == 0L) {
    if (collect) {
      return(matrix(integer(0), nrow = core$total, ncol = 0L))
    } else {
      return(0L)
    }
  }

  .Call(
    C_run_enumeration,
    core$ominos_mat,
    core$fd_ptr,
    core$fd_data,
    core$cp_ptr,
    core$cp_data,
    as.integer(core$total),
    as.integer(core$n_ominos),
    as.integer(num_parts),
    collect
  )
}

# Kept for backward compatibility with tests in test-utils.R.
build_conflicts <- function(ominos, bad_holes, graph) {
  n_om <- length(ominos)
  n <- igraph::vcount(graph)

  first_dict <- vector('list', n)
  for (i in seq_len(n)) {
    first_dict[[i]] <- integer(0)
  }
  for (i in seq_len(n_om)) {
    k <- first_one(ominos[[i]])
    first_dict[[k]] <- c(first_dict[[k]], i)
  }

  compatible <- vector('list', n_om)
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
