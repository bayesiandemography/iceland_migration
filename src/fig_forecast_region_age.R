
library(methods)
library(dplyr)
library(ggplot2)
library(docopt)

'
Usage:
fig_forecast_region_age.R [options]

Options:
--region [default: Capital]
' -> doc
opts <- docopt(doc)
REGION <- opts$region

plot_theme <- readRDS("out/plot_theme.rds")


file <- sprintf("out/vals_forecast_region_age_%s.rds", REGION)
data <- readRDS(file)

p <- ggplot(data, aes(ymin = ymin, ymax = ymax, x = time)) +
    facet_grid(rows = vars(region),
               cols = vars(age)) +
    geom_ribbon(fill = "grey70") +
    geom_line(aes(y = median, x = time), color = "white", size = 0.2) +
    geom_line(aes(y = direct, x = time), color = "black", size = 0.2) +
    plot_theme +
    xlab("Time") +
    ylab("") +
    ylim(0, NA)
    
graphics.off()
file <- sprintf("out/fig_forecast_region_age_%s.pdf", REGION)
pdf(file = file,
    width = 4.8,
    height = 5.1)
plot(p)
dev.off()
