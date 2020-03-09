
library(demest)
library(dplyr)
library(ggplot2)

replicate_data_Baseline <- readRDS("out/vals_replicate_data_Baseline.rds")
replicate_data_Revised <- readRDS("out/vals_replicate_data_Revised.rds")


extended_range <- 1.05 * range(c(replicate_data_Baseline$slope,
                                 replicate_data_Revised$slope))

ylim_replicate_data <- ylim(extended_range[1L], extended_range[2L])

saveRDS(ylim_replicate_data,
        file = "out/ylim_replicate_data.rds")
