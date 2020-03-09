
library(demest)
library(dplyr)
library(docopt)

'
Usage:
model_Revised.R [options]

Options:
--dataset [default: train]
--n_burnin [default: 5]
--n_sim [default: 5]
--n_chain [default: 4]
--n_thin [default: 1]
--seed [default: 0]
' -> doc
opts <- docopt(doc)
dataset <- opts$dataset
n_burnin <- opts$n_burnin %>% as.integer()
n_sim <- opts$n_sim %>% as.integer()
n_chain <- opts$n_chain %>% as.integer()
n_thin <- opts$n_thin %>% as.integer()
seed <- opts$seed %>% as.numeric()

set.seed(seed)

if (dataset == "train") {
    migration <- readRDS("out/migration_train.rds")
    exposure <- readRDS("out/exposure_train.rds")
} else if (dataset == "full") {
    migration <- readRDS("out/migration.rds")
    exposure <- readRDS("out/exposure.rds")
} else {
    stop("invalid value for 'dataset' : ", dataset)
}

covariates_region <- readRDS("out/covariates_region.rds")
covariates_region_age <- readRDS("out/covariates_region_age.rds")

model <- Model(y ~ Poisson(mean ~ region_orig * region_dest + region_dest * age + sex + 
                               region_orig * time + region_dest * time + age * time,
                           structuralZeros = "diag"),
               region_orig ~ Exch(covariates = Covariates(mean ~ logpopn + is_capital,
                                                          data = covariates_region)),
               region_dest ~ Exch(covariates = Covariates(mean ~ logpopn + is_capital,
                                                          data = covariates_region)),
               age ~ DLM(damp = NULL),
               time ~ DLM(trend = NULL,
                          damp = NULL),
               region_dest:age ~ Exch(covariates = Covariates(mean ~ logpopn,
                                                              data = covariates_region_age)),
               region_orig:time ~ DLM(trend = NULL,
                                      damp = NULL),
               region_dest:time ~ DLM(trend = NULL,
                                      damp = NULL),
               age:time ~ DLM(trend = NULL,
                              damp = NULL),
               jump = 0.5)

Sys.time()
filename <- sprintf("out/model_Revised_%s.est", dataset)
estimateModel(model,
              y = migration,
              exposure = exposure,
              filename = filename,
              nBurnin = n_burnin,
              nSim = n_sim,
              nChain = n_chain,
              nThin = n_thin)
Sys.time()

options(width = 120)
fetchSummary(filename)
