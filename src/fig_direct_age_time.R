
library(methods)
library(dplyr)
library(magrittr)
library(ggplot2)

plot_theme <- readRDS("out/plot_theme.rds")

data <- readRDS("out/vals_direct_age_time.rds") %>%
    filter(time %in% range(as.character(time)))

p <- ggplot(data, aes(y = value, x = age, linetype = time)) +
    geom_line(size = 0.4) +
    plot_theme +
    xlab("Age") +
    ylab("")
    
graphics.off()
pdf("out/fig_direct_age_time.pdf",
    width = 3.2,
    height = 2.4)
plot(p)
dev.off()
