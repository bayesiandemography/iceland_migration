
library(methods)
library(dembase)
library(dplyr)
library(magrittr)
library(ggplot2)

population <- readRDS("out/population_train.rds")

plot_theme <- readRDS("out/plot_theme.rds")

max_time <- population %>%
    dimnames() %>%
    extract2("time") %>%
    max()

data <- population %>%
    subarray(time == max_time) %>%
    subarray(age < 80) %>%
    collapseDimension(dimension = "sex") %>%
    as.data.frame(midpoints = "age") %>%
    mutate(region = factor(region, levels = rev(levels(region))))

p <- ggplot(data, aes(y = count, x = age)) +
    facet_wrap(vars(region), scale = "free_y", nrow = 2, ncol = 4) +
    geom_rect(data = data.frame(xmin = 20, xmax = 30, ymin = -Inf, ymax = Inf),
              mapping = aes(xmin = xmin, ymin = ymin, xmax = xmax, ymax = ymax),
              inherit.aes = FALSE,
              fill = "white") +
    geom_line(size = 0.3) +
    plot_theme +
    xlab("Age") +
    ylab("") +
    ylim(0, NA)

    
graphics.off()
pdf("out/fig_population.pdf",
    width = 4.8,
    height = 3)
plot(p)
dev.off()
