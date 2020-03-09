
library(methods)
library(dplyr)
library(ggplot2)

plot_theme <- readRDS("out/plot_theme.rds")

vals <- readRDS("out/vals_estimate_region_age.rds")

vals_estimate <- vals %>%
    filter(!is.na(median))

vals_direct <- vals %>%
    filter(!is.na(direct)) %>%
    mutate(color_direct = ifelse(direct == 0, "grey40", "black"))


p <- ggplot(vals_estimate, aes(ymin = ymin, ymax = ymax, x = age)) +
    facet_grid(rows = vars(region_orig),
               cols = vars(region_dest)) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    geom_ribbon(fill = "grey70") +
    geom_line(aes(y = median, x = age), color = "white", size = 0.2) +
    geom_point(aes(y = direct, x = age),
               data = vals_direct,
               color = vals_direct$color_direct,
               size = 0.1) +
    plot_theme +
    xlab("Age") +
    ylab("")
    
graphics.off()
pdf("out/fig_estimate_region_age.pdf",
    width = 4.8,
    height = 5.1)
plot(p)
dev.off()
