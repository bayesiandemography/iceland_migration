
library(methods)
library(readr)
library(dplyr)
library(tidyr)
library(forcats)
library(dembase)

## Source: Table "Population by municipality, age and sex 1998-2018
## - Division into municipalities as of 1 January 2018"
## on the Statistics Iceland website
## (downloaded on 19 March 2019).

levels_region <- readRDS("out/levels_region.rds")

population <- read_csv("data/MAN02005.csv", skip = 2) %>%
    gather(key = "time_sex", value = "count", `1998 Males`:`2018 Females`) %>%
    separate(col = time_sex, into = c("time", "sex")) %>%
    mutate(region = sub("\\\xf0", "", Municipality), # remove hexidecimal
           region = case_when(region == "Capital region" ~ "Capital",
                              region == "Suurnes" ~ "Southwest",
                              TRUE ~ region),
           region = factor(region, levels = levels_region)) %>%
    mutate(age = cleanAgeGroup(Age),
           age = ifelse(as.integer(age) >= 80, "80+", age)) %>% # to make consistent with 'migration'
    mutate(sex = fct_recode(sex, Female = "Females", Male = "Males")) %>%
    dtabs(count ~ age + sex + region + time) %>%
    Counts(dimscales = c(time = "Points"))

saveRDS(population,
        file = "out/population.rds")
