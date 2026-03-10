test_that("enum_count_partitions matches ncol of enum_partitions for 2x2", {
  expect_equal(
    enum_count_partitions(2, 2, num_parts = 2, min_size = 2, max_size = 2),
    ncol(enum_partitions(2, 2, num_parts = 2, min_size = 2, max_size = 2))
  )
})

test_that("enum_count_partitions matches ncol of enum_partitions for 2x3", {
  expect_equal(
    enum_count_partitions(2, 3, num_parts = 2, min_size = 3, max_size = 3),
    ncol(enum_partitions(2, 3, num_parts = 2, min_size = 3, max_size = 3))
  )
})

test_that("enum_count_partitions matches ncol of enum_partitions for 3x3", {
  expect_equal(
    enum_count_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3),
    ncol(enum_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3))
  )
})

test_that("enum_count_partitions returns 1 for whole-grid single part", {
  expect_equal(
    enum_count_partitions(2, 2, num_parts = 1, min_size = 4, max_size = 4),
    1L
  )
})

test_that("enum_count_partitions queen yields at least as many as rook", {
  rook <- enum_count_partitions(
    3,
    3,
    num_parts = 3,
    min_size = 3,
    max_size = 3
  )
  queen <- enum_count_partitions(
    3,
    3,
    num_parts = 3,
    min_size = 3,
    max_size = 3,
    contiguity = "queen"
  )
  expect_gte(queen, rook)
})

test_that("enum_count_partitions validates bad inputs", {
  expect_snapshot(
    enum_count_partitions(0, 3, num_parts = 2, min_size = 3, max_size = 3),
    error = TRUE
  )
})
