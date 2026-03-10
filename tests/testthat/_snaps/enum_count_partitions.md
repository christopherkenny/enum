# enum_count_partitions validates bad inputs

    Code
      enum_count_partitions(0, 3, num_parts = 2, min_size = 3, max_size = 3)
    Condition
      Error in `check_grid_dimensions()`:
      ! `nrow` must be a single positive integer.

