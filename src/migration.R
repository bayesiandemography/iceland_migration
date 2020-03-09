
library(methods)
library(readr)
library(dplyr)
library(tidyr)
library(forcats)
library(dembase)

## Source: Table "Internal migration between regions
## by sex and age 1986-2017 - Division into municipalities as
## of 1 January 2018" on the Statistics Iceland website
## (downloaded on 19 March 2019).

levels_region <- readRDS("out/levels_region.rds")

filenames <- c("data/MAN01001.csv",
               "data/MAN01001-2.csv",
               "data/MAN01001-3.csv",
               "data/MAN01001-4.csv",
               "data/MAN01001-5.csv")

migration <- bind_rows(lapply(filenames, read_csv, skip = 2)) %>%
    gather(key = "age_dest",
           value = "count", `Under 1 year To capital area`:`80 years and over To within country unknown`) %>%
    separate(col = "age_dest", into = c("age", "region_dest"), sep = " To ") %>%
    filter(`Region migrated from` != "From within country unknown") %>% # no cases
    filter(region_dest != "within country unknown") %>% # no cases
    mutate(age = cleanAgeGroup(age)) %>%
    mutate(sex = fct_recode(Sex, Female = "Females", Male = "Males")) %>%
    mutate(region_orig = sub("^From ", "", `Region migrated from`),
           region_orig = fct_recode(region_orig,
                                    Capital = "capital area"),
           region_orig = fct_relevel(region_orig, levels_region)) %>%
    mutate(region_dest = fct_recode(region_dest,
                                    Capital = "capital area",
                                    Northeast = "Norrheast"),
           region_dest = fct_relevel(region_dest, levels_region)) %>%
    mutate(time = Year + 1L) %>% # convert to 'label-using-end-date' convention
    dtabs(count ~ age + sex + region_orig + region_dest + time) %>%
    Counts(dimscales = c(time = "Intervals"))

saveRDS(migration,
        file = "out/migration.rds")
