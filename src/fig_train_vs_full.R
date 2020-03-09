
library(demest)
library(dplyr)
library(magrittr)
library(ggplot2)
library(docopt)

'
Usage:
fig_train_vs_full.R [options]

Options:
--seed [default: 0]
' -> doc
opts <- docopt(doc)
seed <- opts$seed %>% as.numeric()

set.seed(seed) # for selection of sample

plot_theme <- readRDS("out/plot_theme.rds")

data_all <- readRDS("out/vals_train_vs_full.rds")

cells <- data_all %>%
    select(age, sex, region_orig, region_dest) %>%
    unique() %>%
    mutate(group = sprintf("%s to %s, %ss aged %s",
                           region_orig,
                           region_dest,
                           tolower(sex),
                           age))

data_subset <- cells %>%
    sample_n(size = 6) %>%
    inner_join(data_all, by = c("age", "sex", "region_orig", "region_dest"))

p <- ggplot(filter(data_subset, type != "direct"),
            aes(y = median, x = time, color = type)) +
    facet_wrap(vars(group),
               scales = "free_y",
               nrow = 3,
               ncol = 2) +
    geom_linerange(aes(ymin = ymin, ymax = ymax),
                   position = position_dodge(width = 1)) +
    scale_color_manual(values = c("grey60", "grey20")) +
    geom_point(data = filter(data_subset, type == "direct"),
               color = "black",
               size = 0.3) +
    plot_theme +
    theme(legend.position = "none") +
    xlab("") +
    ylab("")

graphics.off()
pdf("out/fig_train_vs_full.pdf",
    width = 4.8,
    height = 4.6)
plot(p)
dev.off()
