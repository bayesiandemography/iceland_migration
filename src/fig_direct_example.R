
library(methods)
library(dembase)
library(dplyr)
library(ggplot2)

migration <- readRDS("out/migration_train.rds")

param_example <- readRDS("out/param_example.rds")

plot_theme <- readRDS("out/plot_theme.rds")


data <- migration %>%
    subarray(time == param_example$time) %>%
    subarray(sex == param_example$sex) %>%
    subarray(region_orig %in% param_example$region) %>%
    subarray(region_dest %in% param_example$region) %>%
    resetDiag(reset = NA) %>%
    as.data.frame(midpoints = "age", stringsAsFactors = FALSE)

p <- ggplot(data, aes(y = count, x = age)) +
    facet_grid(rows = vars(region_orig), cols = vars(region_dest)) +
    geom_line(size = 0.4) +
    plot_theme +
    xlab("Age") +
    ylab("")

graphics.off()
pdf("out/fig_direct_example.pdf",
    width = 4,
    height = 4)
plot(p)
dev.off()
