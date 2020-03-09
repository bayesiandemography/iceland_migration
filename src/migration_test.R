
library(dembase)
library(dplyr)
library(docopt)

'
Usage:
migration_test.R [options]

Options:
--last_year_train [default: 2008]
' -> doc
opts <- docopt(doc)
last_year_train <- opts$last_year_train %>% as.integer()

migration <- readRDS("out/migration.rds")

migration_test <- migration %>%
    subarray(time > last_year_train)

saveRDS(migration_test,
        file = "out/migration_test.rds")




