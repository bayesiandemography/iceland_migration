
library(methods)
library(dembase)
library(dplyr)
library(ggplot2)

plot_theme <- readRDS("out/plot_theme.rds")

migration <- readRDS("out/migration_train.rds") %>%
    collapseDimension(margin = c("region_orig", "region_dest", "time"))

exposure <- readRDS("out/exposure_train.rds") %>%
    collapseDimension(margin = c("region_orig", "region_dest", "time"))

data <- (migration / exposure) %>%
    resetDiag(reset = NA) %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    mutate(time = as.integer(time))

p <- ggplot(data, aes(y = value, x = time)) +
    facet_grid(rows = vars(region_orig),
               cols = vars(region_dest)) +
    geom_line(size = 0.3) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    plot_theme +
    xlab("Year") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 90,
                                     vjust = 0.5,
                                     hjust = 1))
    
graphics.off()
pdf("out/fig_direct_region_time.pdf",
    width = 4.8,
    height = 4.8)
plot(p)
dev.off()
