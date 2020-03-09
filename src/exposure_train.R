
library(dembase)
library(dplyr)
library(docopt)

'
Usage:
exposure_train.R [options]

Options:
--last_year_train [default: 2008]
' -> doc
opts <- docopt(doc)
last_year_train <- opts$last_year_train %>% as.integer()

exposure <- readRDS("out/exposure.rds")

exposure_train <- exposure %>%
    subarray(time < last_year_train)

saveRDS(exposure_train,
        file = "out/exposure_train.rds")




