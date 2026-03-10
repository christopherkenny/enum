library(ggplot2)
devtools::load_all()

col1 <- '#1D3A20'
col2 <- '#6D454C'
bg <- '#C4B9A8'

mat <- enum_partitions(3, 2, num_parts = 2, min_size = 3, max_size = 3)

make_grid <- function(assignment, cx, cy, cell_size = 1, gap = 0.1) {
  s <- cell_size - gap
  nc <- 2
  nr <- 3
  col_idx <- rep(seq_len(nc), times = nr)
  row_idx <- rep(seq_len(nr), each = nc)
  y_idx <- nr + 1 - row_idx
  data.frame(
    xmin = cx + (col_idx - 1) * cell_size - nc * cell_size / 2 + gap / 2,
    xmax = cx + (col_idx - 1) * cell_size + s - nc * cell_size / 2 + gap / 2,
    ymin = cy + (y_idx - 1) * cell_size - nr * cell_size / 2 + gap / 2,
    ymax = cy + (y_idx - 1) * cell_size + s - nr * cell_size / 2 + gap / 2,
    part = factor(assignment)
  )
}

# Triangle: one grid on top, two on bottom
# Each grid is 2 wide x 3 tall; cell_size = 1
# Top center: (0, 2.2) → y spans [0.7, 3.7]
# Bottom centers: (±1.5, -1.4) → y spans [-2.9, 0.1], x spans [±0.5, ±2.5]
df <- rbind(
  make_grid(mat[, 2], cx = 0, cy = 2.2),
  make_grid(mat[, 1], cx = -1.5, cy = -1.4),
  make_grid(mat[, 3], cx = 1.5, cy = -1.4)
)

df |>
  ggplot() +
  geom_rect(
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = part),
    color = bg,
    linewidth = 1.5
  ) +
  scale_fill_manual(values = c('1' = col1, '2' = col2)) +
  coord_fixed(xlim = c(-4, 4), ylim = c(-4, 4)) +
  theme_void() +
  theme(
    legend.position = 'none',
    plot.background = element_rect(fill = bg, color = NA)
  )

ggsave(
  'data-raw/logo_insert.png',
  width = 4, height = 4, dpi = 300, bg = bg
)
