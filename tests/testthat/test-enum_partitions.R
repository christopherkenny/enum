test_that('enum_partitions returns correct matrix for 2x3 into 2 parts of size 3', {
  result <- enum_partitions(2, 3, num_parts = 2, min_size = 3, max_size = 3)
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 6)
  expect_true(all(apply(result, 2, function(col) setequal(col, rep(1:2, each = 3)))))
})

test_that('enum_partitions returns integer matrix', {
  result <- enum_partitions(2, 2, num_parts = 1, min_size = 4, max_size = 4)
  expect_true(is.matrix(result))
  expect_type(result, 'integer')
})

test_that('enum_partitions 2x2 into 2 parts of size 2 (rook)', {
  result <- enum_partitions(2, 2, num_parts = 2, min_size = 2, max_size = 2)
  expect_equal(ncol(result), 2)
  expect_equal(nrow(result), 4)
})

test_that('enum_partitions queen contiguity yields at least as many as rook', {
  rook <- enum_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3)
  queen <- enum_partitions(
    3,
    3,
    num_parts = 3,
    min_size = 3,
    max_size = 3,
    contiguity = 'queen'
  )
  expect_gte(ncol(queen), ncol(rook))
})

test_that('enum_partitions single part covers whole grid', {
  result <- enum_partitions(2, 2, num_parts = 1, min_size = 4, max_size = 4)
  expect_equal(ncol(result), 1)
  expect_equal(result[, 1], c(1L, 1L, 1L, 1L))
})

test_that('enum_partitions 3x3 into 3 triominoes has 10 solutions', {
  result <- enum_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3)
  expect_equal(ncol(result), 10)
})

test_that('enum_partitions file argument writes and enum_read_partitions reads back', {
  tmp <- tempfile()
  on.exit(unlink(tmp))
  n <- enum_partitions(
    2,
    3,
    num_parts = 2,
    min_size = 3,
    max_size = 3,
    file = tmp
  )
  expect_equal(n, 3L)
  mat <- enum_read_partitions(tmp)
  expect_equal(
    mat,
    enum_partitions(2, 3, num_parts = 2, min_size = 3, max_size = 3)
  )
})

test_that('enum_partitions exact_sizes=c(3) matches min_size=max_size=3', {
  r1 <- enum_partitions(2, 3, num_parts = 2, min_size = 3, max_size = 3)
  r2 <- enum_partitions(2, 3, num_parts = 2, exact_sizes = c(3))
  expect_equal(r1, r2)
})

test_that('enum_partitions exact_sizes restricts to allowed sizes only', {
  # 4x4 into 3 parts where each part is exactly size 4 or 8 (4+4+8=16)
  result <- enum_partitions(4, 4, num_parts = 3, exact_sizes = c(4, 8))
  expect_equal(nrow(result), 16)
  # Every partition must have part sizes in {4, 8}
  expect_true(all(apply(result, 2, function(col) all(tabulate(col) %in% c(4L, 8L)))))
})

test_that('enum_partitions exact_sizes count matches enum_count_partitions', {
  n <- enum_count_partitions(4, 4, num_parts = 3, exact_sizes = c(4, 8))
  mat <- enum_partitions(4, 4, num_parts = 3, exact_sizes = c(4, 8))
  expect_equal(n, ncol(mat))
})

test_that('enum_partitions progress = TRUE returns correct result silently', {
  result <- enum_partitions(
    2, 3,
    num_parts = 2, min_size = 3, max_size = 3, progress = TRUE
  )
  expect_equal(ncol(result), 3L)
})

test_that('enum_partitions validates bad inputs', {
  expect_snapshot(
    enum_partitions(0, 3, num_parts = 2, min_size = 3, max_size = 3),
    error = TRUE
  )
  expect_snapshot(
    enum_partitions(2, 3, num_parts = 2, min_size = 5, max_size = 3),
    error = TRUE
  )
  expect_snapshot(
    enum_partitions(2, 3, num_parts = 100, min_size = 3, max_size = 3),
    error = TRUE
  )
  expect_snapshot(
    enum_partitions(2, 3, num_parts = 2, min_size = 1, max_size = 2),
    error = TRUE
  )
})

test_that('enum_partitions validates exact_sizes inputs', {
  # No size argument supplied
  expect_snapshot(
    enum_partitions(2, 3, num_parts = 2),
    error = TRUE
  )
  # Both exact_sizes and min_size supplied together
  expect_snapshot(
    enum_partitions(2, 3, num_parts = 2, min_size = 3, exact_sizes = c(3)),
    error = TRUE
  )
  # exact_sizes infeasible: parts too large to fit
  expect_snapshot(
    enum_partitions(2, 3, num_parts = 2, exact_sizes = c(4, 8)),
    error = TRUE
  )
})
