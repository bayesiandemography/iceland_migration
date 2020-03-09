
library(methods)
library(demest)
library(dplyr)
library(tidyr)
library(magrittr)
library(ggplot2)
library(docopt)

'
Usage:
vals_forecast_region_age.R [options]

Options:
--variant [default: Revised]
--region [default: Capital]
' -> doc
opts <- docopt(doc)
variant <- opts$variant
REGION <- opts$region

param_forecast <- readRDS("out/param_forecast.rds")

filename_est <- sprintf("out/model_%s_full.est", variant)
filename_pred <- sprintf("out/model_%s_full.pred", variant)

migration <- readRDS("out/migration.rds")
exposure <- readRDS("out/exposure.rds")

rate_modelled <- fetchBoth(filenameEst = filename_est,
                           filenamePred = filename_pred,
                           where = c("model", "likelihood", "rate"))

rate_direct <- migration / exposure

vals_modelled <- rate_modelled %>%
    subarray(region_dest == REGION) %>%
    subarray(region != REGION) %>%
    subarray(age %in% param_forecast$age) %>%
    collapseIterations(prob = c(0.025, 0.5, 0.975), na.rm = TRUE) %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    spread(key = quantile, value = value) %>%
    rename(ymin = "2.5%", median = "50%", ymax = "97.5%")

vals_direct <- rate_direct %>%
    subarray(region_dest == REGION) %>%
    subarray(region != REGION) %>%
    subarray(age %in% param_forecast$age) %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    rename(direct = value)

vals_forecast_region_age <- vals_modelled %>%
    left_join(vals_direct, by = c("age", "sex", "region", "time")) %>%
    mutate(age = factor(age,
                        levels = param_forecast$age,
                        labels = paste("Age", param_forecast$age))) %>%
    mutate(time = as.integer(time))

file <- sprintf("out/vals_forecast_region_age_%s.rds", REGION)
saveRDS(vals_forecast_region_age,
        file = file)
