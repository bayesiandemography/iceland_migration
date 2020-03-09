
library(methods)
library(dplyr)
library(dembase)
library(docopt)

'
Usage:
covariates_region_age.R [options]

Options:
--last_year_train [default: 2008]
' -> doc
opts <- docopt(doc)
last_year_train <- opts$last_year_train

population_train <- readRDS("out/population_train.rds")

covariates_region_age <- population_train %>%
    subarray(time == last_year_train) %>%
    collapseDimension(margin = c("region", "age")) %>%
    as.data.frame() %>%
    mutate(logpopn = log(count)) %>%
    select(region, age, logpopn)
    
saveRDS(covariates_region_age,
        file = "out/covariates_region_age.rds")




