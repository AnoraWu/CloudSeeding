use "/Users/anorawu/Team MG Dropbox/Wanru Wu/Cloudseeding/data/7psm_cloud_pm25_sat_7days.dta", clear

drop if pscore_d > 0.005
egen sd = sd(station_20_20), by(imply)
egen sd_test = sd(pre_station), by(imply)
codebook sd sd_test

keep if imply == 1

gen day0_1 = (refy == 0 | refy == 1)
reg station_20_20 day0_1, r
