test_that("make_grid_graph creates correct rook graph", {
  g <- make_grid_graph(2, 3, "rook")
  expect_equal(igraph::vcount(g), 6)
  expect_equal(igraph::ecount(g), 7)
})

test_that("make_grid_graph creates correct queen graph", {
  g <- make_grid_graph(2, 3, "queen")
  expect_equal(igraph::vcount(g), 6)
  expect_equal(igraph::ecount(g), 11)
})

test_that("first_zero finds first zero", {
  expect_equal(first_zero(c(1, 1, 0, 1)), 3)
  expect_equal(first_zero(c(0, 1, 1)), 1)
})

test_that("first_one finds first one", {
  expect_equal(first_one(c(0, 0, 1, 0)), 3)
  expect_equal(first_one(c(1, 0, 0)), 1)
})

test_that("valid_omino detects connected ominos", {
  g <- make_grid_graph(2, 2, "rook")
  expect_true(valid_omino(c(1L, 1L, 1L, 0L), g))
})

test_that("valid_omino rejects disconnected ominos", {
  g <- make_grid_graph(2, 2, "rook")
  expect_false(valid_omino(c(1L, 0L, 0L, 1L), g))
})

test_that("valid_omino accepts diagonal under queen contiguity", {
  g <- make_grid_graph(2, 2, "queen")
  expect_true(valid_omino(c(1L, 0L, 0L, 1L), g))
})

test_that("valid_omino rejects cells with value > 1", {
  g <- make_grid_graph(2, 2, "rook")
  expect_false(valid_omino(c(2L, 0L, 0L, 0L), g))
})

test_that("make_omino_set generates one omino per vertex for size 1", {
  g <- make_grid_graph(2, 3, "rook")
  expect_length(make_omino_set(1L, g), 6)
})

test_that("make_omino_set generates correct count for size 2 on 2x2 rook grid", {
  g <- make_grid_graph(2, 2, "rook")
  expect_length(make_omino_set(2L, g), 4)
})

test_that("grow_ominos increases each omino by exactly one cell", {
  g <- make_grid_graph(2, 2, "rook")
  size1 <- make_omino_set(1L, g)
  size2 <- grow_ominos(size1, g)
  expect_length(size2, 4)
  expect_true(all(vapply(size2, sum, integer(1)) == 2L))
})

test_that("bad_hole_sizes returns correct forbidden sizes", {
  expect_equal(bad_hole_sizes(3, 3), c(1, 2, 4, 5))
  expect_equal(bad_hole_sizes(4, 6), c(1, 2, 3, 7))
  expect_equal(bad_hole_sizes(1, 1), integer(0))
})

test_that("check_holes rejects ominos leaving forbidden complement components", {
  g <- make_grid_graph(3, 3, "rook")
  bad <- c(1L, 2L, 4L, 5L)
  expect_false(check_holes(c(1L, 1L, 1L, 1L, 1L, 1L, 1L, 0L, 0L), bad, g))
})

test_that("check_holes accepts ominos with valid complement", {
  g <- make_grid_graph(3, 3, "rook")
  bad <- c(1L, 2L, 4L, 5L)
  expect_true(check_holes(c(1L, 1L, 1L, 1L, 1L, 1L, 0L, 0L, 0L), bad, g))
})

test_that("build_conflicts returns correct structure", {
  g <- make_grid_graph(2, 2, "rook")
  ominos <- make_omino_set(2L, g)
  bad <- bad_hole_sizes(2, 2)
  result <- build_conflicts(ominos, bad, g)
  expect_named(result, c("first_dict", "compatible"))
  expect_length(result$first_dict, 4)
  expect_length(result$compatible, length(ominos))
})

test_that("adj_to_igraph converts a 1-indexed adjacency list", {
  adj_obj <- list(c(2L, 3L), c(1L, 3L), c(1L, 2L))
  g <- adj_to_igraph(adj_obj)
  expect_equal(igraph::vcount(g), 3)
  expect_equal(igraph::ecount(g), 3)
})
