
library(dembase)
library(dplyr)
library(docopt)

'
Usage:
population_test.R [options]

Options:
--last_year_train [default: 2008]
' -> doc
opts <- docopt(doc)
last_year_train <- opts$last_year_train %>% as.integer()

population <- readRDS("out/population.rds")

population_test <- population %>%
    subarray(time >= last_year_train)

saveRDS(population_test,
        file = "out/population_test.rds")




