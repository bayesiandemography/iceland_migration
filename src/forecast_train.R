
library(demest)
library(dplyr)
library(magrittr)
library(docopt)

'
Usage:
forecast_train.R [options]

Options:
--variant [default: Baseline]
--seed [default: 0]
' -> doc
opts <- docopt(doc)
variant <- opts$variant
seed <- opts$seed %>% as.numeric()

set.seed(seed)

exposure <- readRDS("out/exposure_test.rds")

n <- exposure %>%
    dimnames() %>%
    extract2("time") %>%
    length()

filename_est <- sprintf("out/model_%s_train.est", variant)
filename_pred <- sprintf("out/model_%s_train.pred", variant)

predictModel(filenameEst = filename_est,
             filenamePred = filename_pred,
             n = n,
             exposure = exposure)
