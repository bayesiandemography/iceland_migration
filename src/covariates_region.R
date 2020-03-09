
library(methods)
library(dplyr)
library(dembase)
library(docopt)

'
Usage:
covariates_region.R [options]

Options:
--last_year_train [default: 2008]
' -> doc
opts <- docopt(doc)
last_year_train <- opts$last_year_train

population_train <- readRDS("out/population_train.rds")

covariates_region <- population_train %>%
    subarray(time == last_year_train) %>%
    collapseDimension(margin = "region") %>%
    as.data.frame() %>%
    mutate(logpopn = log(count)) %>%
    mutate(is_capital = 1L * (region == "Capital")) %>%
    select(region, logpopn, is_capital)
    
saveRDS(covariates_region,
        file = "out/covariates_region.rds")




