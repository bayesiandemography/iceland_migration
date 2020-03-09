
library(methods)
library(dembase)
library(dplyr)
library(ggplot2)

plot_theme <- readRDS("out/plot_theme.rds")

migration <- readRDS("out/migration_train.rds") %>%
    collapseDimension(margin = c("region_orig", "region_dest", "age", "sex")) %>%
    collapseIntervals(dimension = "age", width = 5)

exposure <- readRDS("out/exposure_train.rds") %>%
    collapseDimension(margin = c("region_orig", "region_dest", "age", "sex"))

data <- (migration / exposure) %>%
    resetDiag(reset = NA) %>%
    as.data.frame(stringsAsFactors = FALSE, midpoints = "age")

p <- ggplot(data, aes(y = value, x = age, linetype = sex)) +
    facet_grid(rows = vars(region_orig),
               cols = vars(region_dest)) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE),
                  limits = c(0.0005, NA)) +
    geom_line(size = 0.3) +
    plot_theme +
    xlab("Age") +
    ylab("")
    
graphics.off()
pdf("out/fig_direct_region_age_sex.pdf",
    width = 4.8,
    height = 5.1)
plot(p)
dev.off()
