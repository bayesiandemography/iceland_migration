
library(dembase)
library(dplyr)
library(docopt)

'
Usage:
exposure_test.R [options]

Options:
--last_year_train [default: 2008]
' -> doc
opts <- docopt(doc)
last_year_train <- opts$last_year_train %>% as.integer()

exposure <- readRDS("out/exposure.rds")

exposure_test <- exposure %>%
    subarray(time > last_year_train)

saveRDS(exposure_test,
        file = "out/exposure_test.rds")




