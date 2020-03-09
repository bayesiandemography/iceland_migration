
library(demest)
library(dplyr)
library(magrittr)
library(docopt)

'
Usage:
vals_performance.R [options]

Options:
--variant [default: Baseline]
' -> doc
opts <- docopt(doc)
variant <- opts$variant

param_performance <- readRDS("out/param_performance.rds")

conc_capital <- readRDS("out/conc_capital.rds")

filename <- sprintf("out/model_%s_train.pred", variant)
migration_est <- fetch(filename, where = "y") %>%
    collapseDimension(margin = c("region_orig", "region_dest", "time"))

migration_truth <- readRDS("out/migration_test.rds") %>%
    collapseDimension(margin = c("region_orig", "region_dest", "time"))

exposure <- readRDS("out/exposure_test.rds") %>%
    collapseDimension(margin = c("region_orig", "region_dest", "time"))

rate_est <- migration_est / exposure

rate_truth <- migration_truth / exposure

rate_est_point <- collapseIterations(rate_est, FUN = median)

rate_est_interval <- credibleInterval(rate_est, width = param_performance$coverage)

MAE <- MSE(point = rate_est_point, # single cells, so equivalent to abs error
           truth = rate_truth) %>%
    resetDiag(reset = NA) %>%
    sqrt() %>%
    as.data.frame() %>%
    filter(!is.na(value)) %>%
    mutate(origin = ifelse(region_orig == "Capital", "Capital", "Other")) %>%
    group_by(origin) %>%
    summarise(median = median(value))
    
width <- intervalWidth(rate_est_interval) %>%
    resetDiag(reset = NA) %>%
    as.data.frame() %>%
    filter(!is.na(value)) %>%
    mutate(origin = ifelse(region_orig == "Capital", "Capital", "Other")) %>%
    group_by(origin) %>%
    summarise(median = median(value))

coverage <- intervalContainsTruth(interval = rate_est_interval,
                                  truth = rate_truth) %>%
    resetDiag(reset = NA) %>%
    as.data.frame() %>%
    filter(!is.na(value)) %>%
    mutate(origin = ifelse(region_orig == "Capital", "Capital", "Other")) %>%
    group_by(origin) %>%
    summarise(mean = mean(value))

vals_performance <- bind_cols(MAE = MAE$median,
                              width = width$median,
                              coverage = coverage$mean)

file <- sprintf("out/vals_performance_%s.rds", variant)
saveRDS(vals_performance,
        file = file)
