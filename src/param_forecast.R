
library(methods)

param_forecast <- list(sex = "Female",
                       age = c("10", "25", "40"))

saveRDS(param_forecast,
        file = "out/param_forecast.rds")
