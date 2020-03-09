
library(demest)
library(dplyr)

library(ggplot2)
library(docopt)

'
Usage:
fig_replicate_data.R [options]

Options:
--variant [default: Baseline]
--seed [default: 0]
' -> doc
opts <- docopt(doc)
variant <- opts$variant
seed <- opts$seed %>% as.numeric()

set.seed(seed) # for 'jitter'

plot_theme <- readRDS("out/plot_theme.rds")

ylim_replicate_data <- readRDS("out/ylim_replicate_data.rds")

file <- sprintf("out/vals_replicate_data_%s.rds", variant)
data <- readRDS(file)

p <- ggplot(data, aes(x = dataset, y = slope)) +
    geom_jitter(shape = 1, width = 0.2, size = 0.7, alpha = 0.4) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    plot_theme +
    xlab("") +
    ylab("") +
    ylim_replicate_data
    
file <- sprintf("out/fig_replicate_data_%s.pdf", variant)
graphics.off()
pdf(file,
    width = 4.8,
    height = 2.6)
plot(p)
dev.off()
