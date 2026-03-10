# enum_partitions_graph validates inputs

    Code
      enum_partitions_graph("not_a_graph", num_parts = 2, min_size = 2, max_size = 3)
    Condition
      Error in `to_igraph()`:
      ! `graph` must be an <igraph> or <adj> object.

---

    Code
      enum_partitions_graph(igraph::make_star(4, mode = "mutual"), num_parts = 2,
      min_size = 2, max_size = 2)
    Condition
      Error in `check_graph()`:
      ! `graph` must be undirected.

