
library(methods)
library(demest)
library(dplyr)
library(tidyr)
library(magrittr)
library(ggplot2)
library(docopt)

'
Usage:
vals_estimate_region_age.R [options]

Options:
--variant [default: Baseline]
' -> doc
opts <- docopt(doc)
variant <- opts$variant

param_forecast <- readRDS("out/param_forecast.rds")

time_max <- readRDS("out/migration.rds") %>%
    dimnames() %>%
    extract2("time") %>%
    max()


## direct

migration <- readRDS("out/migration.rds") %>%
    subarray(sex == param_forecast$sex) %>%
    subarray(time == time_max) %>%
    collapseIntervals(dimension = "age", width = 5)

exposure <- readRDS("out/exposure.rds") %>%
    subarray(sex == param_forecast$sex) %>%
    subarray(time == time_max) %>%
    collapseDimension(margin = c("region_orig", "region_dest", "age"))

direct <- (migration / exposure) %>%
    resetDiag(reset = NA) %>%
    as.data.frame(midpoints = "age", stringsAsFactors = FALSE) %>%
    rename(direct = value)


## modelled

filename <- sprintf("out/model_%s_full.est", variant)
rate <- fetch(filename, where = c("model", "likelihood", "rate"))

modelled <- rate %>%
    subarray(time == time_max) %>%
    subarray(sex == param_forecast$sex) %>%
    resetDiag(reset = NA) %>%
    collapseIterations(prob = c(0.025, 0.5, 0.975), na.rm = TRUE) %>%
    as.data.frame(midpoints = "age", stringsAsFactors = FALSE) %>%
    spread(key = quantile, value = value) %>%
    rename(ymin = "2.5%", median = "50%", ymax = "97.5%")

## combine and save

vals_estimate_region_age <- modelled %>%
    left_join(direct, by = c("region_orig", "region_dest", "age"))

saveRDS(vals_estimate_region_age,
        file = "out/vals_estimate_region_age.rds")
