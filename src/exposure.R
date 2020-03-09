
library(methods)
library(dembase)
library(dplyr)

population <- readRDS("out/population.rds")

exposure <- exposure(population) %>%
    addPair(base = "region")

saveRDS(exposure,
        file = "out/exposure.rds")
