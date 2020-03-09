
library(methods)
library(ggplot2)

plot_theme <- theme(text = element_text(size = 7),
                    legend.title = element_blank(),
                    legend.position = "top")

saveRDS(plot_theme,
        file = "out/plot_theme.rds")
