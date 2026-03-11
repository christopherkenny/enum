build_enumeration_core <- function(graph, sizes) {
  total <- as.integer(igraph::vcount(graph))
  bad_holes <- bad_hole_sizes_exact(sizes, total)

  adj_list <- igraph::as_adj_list(graph, mode = 'all')
  adj_ptr  <- c(0L, cumsum(lengths(adj_list, use.names = FALSE)))
  adj_data <- unlist(lapply(adj_list, as.integer), use.names = FALSE) - 1L

  ominos_mat <- .Call(
    C_generate_ominos,
    adj_ptr,
    adj_data,
    as.integer(total),
    as.integer(sizes)
  )

  if (ncol(ominos_mat) == 0L) {
    return(list(
      ominos_mat = ominos_mat,
      fd_ptr = integer(total + 1L),
      fd_data = integer(0L),
      cp_ptr = integer(1L),
      cp_data = integer(0L),
      n_ominos = 0L,
      total = total
    ))
  }

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
# matrix (two-pass: count then fill); when collect = FALSE, returns the count.
# When progress = TRUE, a cli progress bar is shown from within C.
run_enumeration <- function(core, num_parts, collect, progress = TRUE) {
  if (core$n_ominos == 0L) {
    if (collect) {
      return(matrix(integer(0), nrow = core$total, ncol = 0L))
    } else {
      return(0L)
    }
  }

  count <- .Call(
    C_run_enumeration,
    core$ominos_mat,
    core$fd_ptr,
    core$fd_data,
    core$cp_ptr,
    core$cp_data,
    as.integer(core$total),
    as.integer(core$n_ominos),
    as.integer(num_parts),
    isTRUE(progress)
  )

  if (!collect) return(count)
  if (count == 0L) return(matrix(integer(0), nrow = core$total, ncol = 0L))

  out <- matrix(0L, nrow = core$total, ncol = count)
  .Call(
    C_fill_enumeration,
    core$ominos_mat,
    core$fd_ptr,
    core$fd_data,
    core$cp_ptr,
    core$cp_data,
    as.integer(core$total),
    as.integer(core$n_ominos),
    as.integer(num_parts),
    out,
    FALSE
  )
  out
}

stream_enumeration <- function(core, num_parts, file, progress = TRUE) {
  if (core$n_ominos == 0L) {
    return(0L)
  }

  .Call(
    C_stream_enumeration,
    core$ominos_mat,
    core$fd_ptr,
    core$fd_data,
    core$cp_ptr,
    core$cp_data,
    as.integer(core$total),
    as.integer(core$n_ominos),
    as.integer(num_parts),
    as.character(file),
    isTRUE(progress)
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
