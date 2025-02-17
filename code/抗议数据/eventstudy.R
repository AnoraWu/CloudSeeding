library(fixest)   
library(dplyr)
library(did)

setwd("~/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据")
data <- read.csv("eventstudy_data.csv")

data$event_date <- as.factor(data$event_date)

feols(n_cloudseeding ~ rainfall+sunab(event_date, to_day) | id + date, data=data,cluster = ~id)
