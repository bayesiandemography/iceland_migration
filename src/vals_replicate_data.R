
library(demest)
library(dplyr)
library(magrittr)
library(tidyr)
library(purrr)
library(docopt)

'
Usage:
vals_replicate_data.R [options]

Options:
--variant [default: Baseline]
--n_replicate [default: 19]
--seed [default: 0]
' -> doc
opts <- docopt(doc)
variant <- opts$variant
n_replicate <- opts$n_replicate %>% as.integer()
seed <- opts$seed %>% as.numeric()

set.seed(seed)

filename_est <- sprintf("out/model_%s_train.est", variant)

y_actual <- readRDS("out/migration_train.rds")

exposure <- readRDS("out/exposure_train.rds")

rate_replicate <- fetch(filename_est,
              where = c("model", "likelihood", "rate")) %>%
    thinIterations(n = n_replicate)

lambda_replicate <- exposure * rate_replicate

y_replicate <- rpois(n = length(lambda_replicate),
                     lambda = ifelse(is.na(lambda_replicate), 0, lambda_replicate))
y_replicate <- y_replicate %>%
    array(dim = dim(lambda_replicate), dimnames = dimnames(lambda_replicate)) %>%
    Counts(dimscales = c(time = "Intervals")) %>%
    resetDiag(reset = NA)
    
y_actual <- y_actual %>%
    collapseDimension(margin = c("region_orig", "region_dest", "time"))

y_replicate <- y_replicate %>%
    collapseDimension(margin = c("region_orig", "region_dest", "time"))

rate_actual <- (y_actual / exposure) %>%
    as.data.frame(midpoints = "time") %>%
    mutate(dataset = "Actual")
    
rate_replicate <- (y_replicate / exposure) %>%
    as.data.frame(midpoints = "time") %>%
    mutate(dataset = paste("Rep", iteration)) %>%
    select(-iteration)

levels_dataset <- c("Actual", paste("Rep", seq_len(n_replicate)))

vals_replicate_data <- bind_rows(rate_actual, rate_replicate) %>%
    filter(region_orig != region_dest) %>%
    mutate(dataset = factor(dataset, levels = levels_dataset)) %>%
    group_by(region_orig, region_dest, dataset) %>%
    nest() %>%
    mutate(model = map(data, function(x) lm(value ~ time, data = x))) %>%
    mutate(slope = map_dbl(model, function(x) coef(x)[["time"]]))

file <- sprintf("out/vals_replicate_data_%s.rds", variant)
saveRDS(vals_replicate_data,
        file = file)
