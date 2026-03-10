build_enumeration_core <- function(graph, min_size, max_size) {
  total <- igraph::vcount(graph)
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

  ominos <- Filter(\(o) check_holes(o, bad_holes, graph), ominos)

  if (length(ominos) == 0L) {
    return(list(
      ominos = list(),
      first_dict = vector('list', total),
      compatible = list(),
      total = total
    ))
  }

  dicts <- build_conflicts(ominos, bad_holes, graph)

  list(
    ominos = ominos,
    first_dict = dicts$first_dict,
    compatible = dicts$compatible,
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

# Run the recursive partition enumeration. Uses an environment for mutable
# state rather than lexical assignment. When collect = TRUE, returns a matrix;
# when collect = FALSE, returns only the integer count.
run_enumeration <- function(core, num_parts, collect) {
  env <- new.env(parent = emptyenv())
  env$count <- 0L
  if (collect) {
    env$results <- list()
  }

  recurs_part <- function(plan, steps) {
    current_sum <- Reduce(`+`, core$ominos[plan])
    total_covered <- sum(current_sum)

    if (steps == 0L) {
      if (total_covered == core$total) {
        env$count <- env$count + 1L
        if (collect) {
          env$results[[env$count]] <- Reduce(
            `+`,
            Map(`*`, seq_along(plan), core$ominos[plan])
          )
        }
      }
      return(invisible(NULL))
    }

    if (total_covered == core$total) {
      return(invisible(NULL))
    }

    fz <- first_zero(current_sum)
    for (q in core$first_dict[[fz]]) {
      new_plan <- c(plan, q)
      if (verify_plan(new_plan, core$compatible)) {
        recurs_part(new_plan, steps - 1L)
      }
    }
    invisible(NULL)
  }

  for (p in core$first_dict[[1L]]) {
    recurs_part(p, num_parts - 1L)
  }

  if (collect) {
    if (env$count == 0L) {
      matrix(integer(0), nrow = core$total, ncol = 0L)
    } else {
      do.call(cbind, env$results)
    }
  } else {
    env$count
  }
}
