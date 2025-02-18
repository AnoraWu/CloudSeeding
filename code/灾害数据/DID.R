library(fixest)
library(dplyr)
library(did)
library(haven)
library(ggplot2)

setwd("D:/Git Local/CloudSeeding/code/灾害数据")

data <- read.csv("did_data.csv")

# Include covariates to partially account for fixed effects
cs_results <- att_gt(
  yname = "affectedpopulation",
  tname = "month",
  idname = "citycode",
  gname = "gvar",
  data = data
)

# Aggregate the ATT dynamically
es <- aggte(cs_results,
            type = "dynamic",
            min_e = -5, max_e = 5
)

ggdid(es)
