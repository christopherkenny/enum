test_that('enum_read_partitions reads all partitions', {
  tmp <- tempfile()
  on.exit(unlink(tmp))
  enum_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3, file = tmp)
  expect_equal(
    enum_read_partitions(tmp),
    enum_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3)
  )
})

test_that('enum_read_partitions skip and n return the right columns', {
  tmp <- tempfile()
  on.exit(unlink(tmp))
  enum_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3, file = tmp)
  full <- enum_partitions(3, 3, num_parts = 3, min_size = 3, max_size = 3)
  expect_equal(enum_read_partitions(tmp, skip = 3), full[, 4:10])
  expect_equal(enum_read_partitions(tmp, n = 4), full[, 1:4])
  expect_equal(enum_read_partitions(tmp, skip = 2, n = 3), full[, 3:5])
})
