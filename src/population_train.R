
library(dembase)
library(dplyr)
library(docopt)

'
Usage:
population_train.R [options]

Options:
--last_year_train [default: 2008]
' -> doc
opts <- docopt(doc)
last_year_train <- opts$last_year_train %>% as.integer()

population <- readRDS("out/population.rds")

population_train <- population %>%
    subarray(time <= last_year_train)

saveRDS(population_train,
        file = "out/population_train.rds")




