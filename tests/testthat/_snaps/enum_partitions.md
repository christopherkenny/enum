# enum_partitions validates bad inputs

    Code
      enum_partitions(0, 3, num_parts = 2, min_size = 3, max_size = 3)
    Condition
      Error in `check_grid_dimensions()`:
      ! `nrow` must be a single positive integer.

---

    Code
      enum_partitions(2, 3, num_parts = 2, min_size = 5, max_size = 3)
    Condition
      Error in `check_sizes()`:
      ! `min_size` (5) must be <= `max_size` (3).

---

    Code
      enum_partitions(2, 3, num_parts = 100, min_size = 3, max_size = 3)
    Condition
      Error in `check_num_parts()`:
      ! `num_parts` (100) cannot exceed the number of grid cells (6).

---

    Code
      enum_partitions(2, 3, num_parts = 2, min_size = 1, max_size = 2)
    Condition
      Error in `check_sizes()`:
      ! Impossible to tile: 2 parts of at most size 2 cannot cover 6 cells.

