
library(methods)

param_example <- list(time = "2008",
                      age = c("10", "20", "30", "40"),
                      sex = "Female",
                      region = c("Capital", "Southwest", "Westfjords"))

saveRDS(param_example,
        file = "out/param_example.rds")
