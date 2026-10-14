make_plot <- function(data, vars, start, end) {

  recent <- data %>%
    filter(
      as.Date(TIMESTAMP) >= start,
      as.Date(TIMESTAMP) <= end
    ) %>%
    select(all_of(c("TIMESTAMP", vars))) %>%
    pivot_longer(vars)
  
  p <- ggplot(recent, aes(TIMESTAMP, value, color = name)) +
    geom_point(size = 0.3) +
    theme_grey() +
    facet_wrap(~name, scales = "free_y") +
    coord_cartesian(
      xlim = c(
        lubridate::ymd(start, tz = "EST"),
        lubridate::ymd(end + 1, tz = "EST")
      )
    ) +
    theme(axis.title.x = element_blank(), legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1),
          strip.text = element_text(size = 14, face = "bold")) 
  
  
  plotly::ggplotly(p, tooltip = c("TIMESTAMP", "value"))
}
