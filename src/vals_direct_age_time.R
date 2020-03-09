
library(methods)
library(dembase)
library(dplyr)

migration <- readRDS("out/migration_train.rds") %>%
    collapseDimension(margin = c("age", "time"))

exposure <- readRDS("out/exposure_train.rds") %>%
    collapseDimension(margin = c("age", "time"))

vals_direct_age_time <- (migration / exposure) %>%
    as.data.frame(midpoints = "age")

saveRDS(vals_direct_age_time,
        file = "out/vals_direct_age_time.rds")
