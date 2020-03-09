
library(demest)
library(dplyr)
library(docopt)

'
Usage:
forecast_full.R [options]

Options:
--variant [default: Baseline]
--forecast_length [default: 25]
--seed [default: 0]
' -> doc
opts <- docopt(doc)
variant <- opts$variant
forecast_length <- opts$forecast_length %>% as.integer()
seed <- opts$seed %>% as.numeric()

set.seed(seed)

filename_est <- sprintf("out/model_%s_full.est", variant)
filename_pred <- sprintf("out/model_%s_full.pred", variant)

predictModel(filenameEst = filename_est,
             filenamePred = filename_pred,
             n = forecast_length)
