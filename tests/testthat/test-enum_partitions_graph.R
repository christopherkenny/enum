test_that('enum_partitions_graph works on a path graph', {
  g <- igraph::make_ring(4, circular = FALSE)
  result <- enum_partitions_graph(g, num_parts = 2, min_size = 2, max_size = 2)
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 4)
  expect_equal(ncol(result), 1)
  expect_equal(result[, 1], c(1L, 1L, 2L, 2L))
})

test_that('enum_partitions_graph works on a cycle graph', {
  g <- igraph::make_ring(6)
  result <- enum_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3)
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 6)
  expect_true(all(apply(result, 2, function(col) all(tabulate(col) == 3L))))
})

test_that('enum_partitions_graph matches grid version on a lattice', {
  g <- igraph::make_lattice(c(2, 2))
  expect_equal(
    ncol(enum_partitions_graph(g, num_parts = 2, min_size = 2, max_size = 2)),
    ncol(enum_partitions(2, 2, num_parts = 2, min_size = 2, max_size = 2))
  )
})

test_that('enum_count_partitions_graph matches enum_partitions_graph', {
  g <- igraph::make_ring(6)
  expect_equal(
    enum_count_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3),
    ncol(enum_partitions_graph(g, num_parts = 2, min_size = 3, max_size = 3))
  )
})

test_that('enum_partitions_graph returns 0-column matrix when no valid partition exists', {
  # Star graph: center connected to all leaves, leaves not connected to each other.
  # Any part of size 2 that excludes the center requires two adjacent leaves,
  # which don't exist, so no valid 2-part partition of size 2 is possible.
  g <- igraph::make_star(4, mode = 'undirected')
  result <- enum_partitions_graph(g, num_parts = 2, min_size = 2, max_size = 2)
  expect_equal(ncol(result), 0)
})

test_that('enum_count_partitions_graph returns 1 for single-part covering', {
  g <- igraph::make_ring(4)
  expect_equal(
    enum_count_partitions_graph(g, num_parts = 1, min_size = 4, max_size = 4),
    1L
  )
})

test_that('enum_count_partitions_graph queen yields at least as many as rook', {
  rook <- enum_count_partitions(
    3,
    3,
    num_parts = 3,
    min_size = 3,
    max_size = 3,
    contiguity = 'rook'
  )
  queen <- enum_count_partitions(
    3,
    3,
    num_parts = 3,
    min_size = 3,
    max_size = 3,
    contiguity = 'queen'
  )
  expect_gte(queen, rook)
})

test_that('enum_partitions_graph accepts adj objects', {
  adj_obj <- list(c(2L, 3L), c(1L, 3L), c(1L, 2L))
  class(adj_obj) <- 'adj'
  result <- enum_partitions_graph(
    adj_obj,
    num_parts = 1,
    min_size = 3,
    max_size = 3
  )
  expect_equal(ncol(result), 1)
  expect_equal(result[, 1], c(1L, 1L, 1L))
})

test_that('enum_partitions_graph validates inputs', {
  expect_snapshot(
    enum_partitions_graph(
      'not_a_graph',
      num_parts = 2,
      min_size = 2,
      max_size = 3
    ),
    error = TRUE
  )
  expect_snapshot(
    enum_partitions_graph(
      igraph::make_star(4, mode = 'mutual'),
      num_parts = 2,
      min_size = 2,
      max_size = 2
    ),
    error = TRUE
  )
})

test_that('enum_partitions_graph on a path graph of 6 into 3 parts of size 2', {
  g <- igraph::make_ring(6, circular = FALSE)
  result <- enum_partitions_graph(g, num_parts = 3, min_size = 2, max_size = 2)
  expect_equal(ncol(result), 1)
})
