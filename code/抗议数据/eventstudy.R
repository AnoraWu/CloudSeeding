library(fixest)   
library(tidyverse) 
library(dplyr)
library(did)

setwd("~/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据")
data <- read.csv("eventstudy_data.csv")
data <- data %>% 
  mutate(event_date = if_else(is.na(event_date), 10000,
                              event_date)) %>% 
  mutate(to_day = if_else(is.na(to_day), 10000,
                              to_day)) %>% 
  select(n_cloudseeding, rainfall, event_date,to_day,id,date, citycode)

fixest::setFixest_nthreads(8)
res_sunab=fixest::feols(n_cloudseeding ~ rainfall+sunab(event_date, to_day, 
                                                        ref.c = 10000, ref.p = c(-1, -2))
                        | citycode + date, data=data,cluster = ~citycode)
