
library(demest)
library(dplyr)
library(xtable)


baseline <- readRDS("out/vals_performance_Baseline.rds")
revised <- readRDS("out/vals_performance_Revised.rds")

param_performance <- readRDS("out/param_performance.rds")

tab <- rbind(baseline, revised) %>%
    as.matrix()

rownames(tab) <- paste(rep(c("Baseline", "Revised"), each = 2),
                       rep(c("Capital", "Other"), times = 2),
                       sep = ": ")                  
colnames(tab) <- c("Median abs. error", "Median width", "Coverage")

caption <- sprintf("Comparison of performance of baseline and revised models, using %s percent credible intervals",
                   param_performance$coverage)

xt <- xtable(tab,
             align = c("l", rep("c", 3)),
             label = "tab:performance",
             caption = caption,
             digits = c(5, 5, 5, 2))

print(xt,
      file = "out/tab_performance.tex",
      caption.placement = "top")
