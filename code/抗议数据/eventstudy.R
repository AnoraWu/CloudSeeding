library(fixest)   
library(tidyverse) 
library(dplyr)
library(did)

setwd("C:/Users/Anora/OneDrive/Desktop/data")
data <- read.csv("rfa_event_study_data_for_R.csv")
data <- data %>% 
  mutate(event_date = if_else(is.na(event_date), 10000,
                              event_date)) %>% 
  mutate(to_day = if_else(is.na(to_day), 10000,
                              to_day)) %>% 
  select(n_cloudseeding, rainfall, event_date,to_day,id,date, citycode)

res_sunab=fixest::feols(n_cloudseeding ~ rainfall+sunab(event_date, to_day, 
                                                        ref.c = 10000, ref.p = c(-1, -2),
                                                        bin.c = "bin::7",bin.c = "bin::7")
                        | citycode + date, data=data,cluster = ~citycode)
