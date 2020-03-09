
library(methods)
library(dplyr)
library(magrittr)
library(dembase)

population <- readRDS("out/population.rds")

region <- population %>%
    dimnames() %>%
    extract2("region")

conc_capital <- data.frame(from = region,
                   to = ifelse(region == "Capital", "Capital", "Other")) %>%
    Concordance()
    
saveRDS(conc_capital,
        file = "out/conc_capital.rds")
