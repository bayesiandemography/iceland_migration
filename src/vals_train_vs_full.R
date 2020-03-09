
library(demest)
library(dplyr)
library(tidyr)
library(docopt)

'
Usage:
vals_train_vs_full.R [options]

Options:
--variant [default: Revised]
' -> doc
opts <- docopt(doc)
variant <- opts$variant

filename_train <- sprintf("out/model_%s_train.est", variant)
filename_full <- sprintf("out/model_%s_full.est", variant)

rates_train <- fetch(filename_train, where = c("model", "likelihood", "rate")) %>%
    collapseIterations(prob = c(0.025, 0.5, 0.975), na.rm = TRUE) %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    filter(!is.na(value)) %>%
    mutate(type = "train")

rates_full <- fetch(filename_full, where = c("model", "likelihood", "rate")) %>%
    collapseIterations(prob = c(0.025, 0.5, 0.975), na.rm = TRUE) %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    filter(!is.na(value)) %>%
    mutate(type = "full")

y <- fetch(filename_full, where = "y")
exposure <- fetch(filename_full, where = "exposure")
rates_direct <- (y / exposure) %>%
    resetDiag(reset = NA) %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    filter(!is.na(value)) %>%
    mutate(type = "direct") %>%
    mutate(quantile = "50%")

vals_train_vs_full <- bind_rows(rates_train, rates_full, rates_direct) %>%
    spread(key = quantile, value = value) %>%
    rename(ymin = "2.5%", median = "50%", ymax = "97.5%") %>%
    mutate(time = as.integer(time))

saveRDS(vals_train_vs_full,
        file = "out/vals_train_vs_full.rds")
