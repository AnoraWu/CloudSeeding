***********************************************************************************************************
** this do file 
** data files used: 
** data files produced:
** last update: 22/04/2025
***********************************************************************************************************
clear all
set more off

if c(username)=="dengzichen" {
	global dir "~/Dropbox/Cloud Seeding"
}
else if c(username)=="13429" {
	global dir "E:/Dropbox/Cloud Seeding"
}
else if c(username)=="sw" {
	global dir "/Users/shaoda/Dropbox/Cloud Seeding"
}
else if c(username)=="AW" {
	global dir "F:\dropbox\Dropbox\Cloud Seeding"
}
else {
	global dir ""
}

cd "$dir"
global raw_data "$dir/data/raw"
global data "$dir/data"
global out_files "$dir/output"

***************************************************************************************************
// define output directories
global data_tem "$data/tem/match/forecast_rain"
global output_figure "$out_files/figure/forecast_rain_nodrop" 
global output_notitle "$out_files/figure/forecast_rain_nodrop_notitle"
global output_table "$out_files/table/match"


*** (1) Matching using integer value of rainfall and forecast  ========================
**** data preparation 
use "$raw_data/skeleton_merged2024.dta", clear

gen date = mdy(month, day, year)
tsset dt_adcode date

forval i = 1/7 {
	gen mars_pre`i' = int(1*l`i'.pre_mars)
}


forval i = 1/2 {
	gen mars_late`i' = int(1*f`i'.pre_mars)
}

gen rain_pre1 = int(1*l1.rain_IDW)	
replace pre_mars = int(1*pre_mars)

keep mars_pre7 mars_pre6 mars_pre5 mars_pre4 mars_pre3 mars_pre2 mars_pre1 pre_mars mars_late1 mars_late2 rain_pre1 county prov city dt_adcode ct_adcode pr_adcode year month day imply county_level city_level 

merge 1:1 dt_adcode ct_adcode pr_adcode year month day using "$data_tem/pscore.dta"
drop _merge
drop if pscore ==. // delete those useless observations 
gen id_t = _n if imply == 1
gen id_c = _n if imply == 0

save "$data_tem/int_forecast_rain.dta", replace

********treated group 
keep if imply == 1
drop id_c 
drop prov city county 
rename pscore pscore_t

drop if mars_pre7==. | mars_pre6==.|mars_pre5==.|mars_pre4==.|mars_pre3==.| mars_pre2==.| mars_pre1==.| pre_mars==.| mars_late1==.| mars_late2==. 
drop if rain_pre1 == . // 64,639 treatments left

drop if mars_pre7==0 & mars_pre6==0 & mars_pre5==0 & mars_pre4==0 & mars_pre3 ==0 & mars_pre2 ==0 & mars_pre1==0 &mars_late1==0 &mars_late2==0 & pre_mars==0 & rain_pre1==0 // 58,950 left

save "$data_tem/treated_no0.dta", replace

*** Control group
use "$data_tem/int_forecast_rain.dta", clear

drop if imply == 1

drop if mars_pre7==. | mars_pre6==.|mars_pre5==.|mars_pre4==.|mars_pre3==.| mars_pre2==.| mars_pre1==.| pre_mars==.| mars_late1==.| mars_late2==. 
drop if rain_pre1 == . 
drop if mars_pre7==0 & mars_pre6==0 & mars_pre5==0 & mars_pre4==0 & mars_pre3 ==0 & mars_pre2 ==0 & mars_pre1==0 &mars_late1==0 &mars_late2==0 & pre_mars==0 & rain_pre1==0 // 2,286,520 observations deleted

drop id_t
drop prov city county city_level county_level
rename pscore pscore_c

egen control_id = group(mars_pre7 mars_pre6 mars_pre5 mars_pre4 mars_pre3 mars_pre2 mars_pre1 pre_mars mars_late1 mars_late2 rain_pre1) 

save "$data_tem/control_no0_all.dta", replace


**** exact matching 
drop dt_adcode ct_adcode pr_adcode year month day imply id_c pscore_c
duplicates drop control_id, force

joinby mars_pre7 mars_pre6 mars_pre5 mars_pre4 mars_pre3 mars_pre2 mars_pre1 pre_mars mars_late1 mars_late2 rain_pre1 using "$data_tem/treated_no0.dta"

keep control_id id_t pscore_t imply 

save "$data_tem/matchid_no0.dta", replace


****only keep treatments matched with controls 
keep id_t
merge 1:1 id_t using "$data_tem/treated_no0.dta"
keep if _merge==3 // 31371 matched
drop _merge

* Drop treatments that occur within 14 days of the first cloud seeding event at a given location
gen date = mdy(month, day, year)
gen drop_flag = 0
bysort dt_adcode ct_adcode pr_adcode (date): replace drop_flag = 1 if _n > 1 & date - date[_n-1] <= 14	

drop if drop_flag == 1 // 9619 deleted

foreach var of varlist mars_pre1-rain_pre1{
	drop `var'
}
drop pre_mars date drop_flag

save "$data_tem/treated_no0_matched.dta", replace


***Adjust the matchid based on treatment
use "$data_tem/matchid_no0.dta", clear

merge 1:1 id_t using "$data_tem/treated_no0_matched.dta"
keep if _merge==3
keep control_id id_t pscore_t imply

save "$data_tem/matchid_no0.dta", replace


***control group 
use "$data_tem/control_no0_all.dta", clear

keep dt_adcode ct_adcode pr_adcode year month day control_id id_c pscore_c imply

xtile quart_bp = id_c, nq(10) // divided into 10 subsamples -- it's faster than matching in one file 
tab quart_bp

save "$data_tem/control_no0_all_quart.dta", replace

* It takes approximately 10min to run the loop below. 
forvalues i = 1/10{
    use "$data_tem/control_no0_all_quart.dta", clear
    keep if quart_bp == `i'
	
	joinby control_id using "$data_tem/matchid_no0.dta"
	drop quart_bp control_id
	
	gen pscore_d = abs(pscore_t-pscore_c)
	sort id_t pscore_d
	by id_t: keep if _n==1
	
	drop pscore_c pscore_t
	save "$data_tem/match_no0/match_`i'.dta", replace
	
	keep id_c id_t
	merge 1:1 id_t using "$data_tem/treated_no0_matched.dta", keep(match)
	drop _merge pscore_t
	
	append using "$data_tem/match_no0/match_`i'.dta"
	
	sort id_t imply
	replace pscore_d = pscore_d[_n-1] if pscore_d==.
	tab imply
	save "$data_tem/match_no0/match_`i'.dta", replace
}

** Combine mathced data and find the best psm ones. 
clear
cd "$data_tem/match_no0"
openall

sort id_t imply pscore_d
by id_t imply: keep if _n ==1
tab imply

bys id_t id_c: replace city_level = city_level[_n+1] if city_level==.
bys id_t id_c: replace county_level = county_level[_n+1] if county_level==.

save "$data_tem/psm_no0_matched.dta"


****(2) matching for all 0 ones ===================================================
** Same steps as in (1)
**** data preparation
use "$data_tem/int_forecast_rain.dta", clear

keep if mars_pre1 ==0 & mars_pre2 ==0 & mars_pre3 ==0 & mars_pre4 ==0 & mars_pre5 ==0 & mars_pre6 ==0 & mars_pre7 ==0 & pre_mars ==0 & mars_late1 ==0 & mars_late2 ==0 & rain_pre1==0

foreach var of varlist mars_pre1 - rain_pre1{
	drop `var'
}

drop pre_mars

merge 1:1 prov city county year month day using "$raw_data/skeleton_merged2024.dta"
keep prov city county year month day dt_adcode ct_adcode pr_adcode pre_mars rain_IDW id_t id_c pscore city_level county_level imply _merge

gen date = mdy(month, day, year)
tsset dt_adcode date

forval i = 1/7 {
	gen mars_pre`i' = round(l`i'.pre_mars, 0.1)
}

forval i = 1/2 {
	gen mars_late`i' = round(f`i'.pre_mars,0.1)
}

gen rain_pre1 = round(l1.rain_IDW, 0.1)	
replace pre_mars = round(pre_mars, 0.1)

*keep if id_t !=. | id_c !=.
keep if _m == 3
drop _m rain_IDW

save "$data_tem/int_forecast_rain_01.dta", replace


**** treated group
keep if imply == 1
drop id_c date 
drop prov city county 
rename pscore pscore_t

drop if mars_pre7==. | mars_pre6==.|mars_pre5==.|mars_pre4==.|mars_pre3==.| mars_pre2==.| mars_pre1==.| pre_mars==.| mars_late1==.| mars_late2==. 
drop if rain_pre1 == . // 5689 treatments left

save "$data_tem/treated_01.dta", replace


**** control group
use "$data_tem/int_forecast_rain_01.dta", clear

keep if imply == 0 
drop id_t date prov city county city_level county_level
rename pscore pscore_c

drop if mars_pre7==. | mars_pre6==.|mars_pre5==.|mars_pre4==.|mars_pre3==.| mars_pre2==.| mars_pre1==.| pre_mars==.| mars_late1==.| mars_late2==. 
drop if rain_pre1 == . // 2,286,520 treatments left

egen control_id = group(mars_pre7 mars_pre6 mars_pre5 mars_pre4 mars_pre3 mars_pre2 mars_pre1 pre_mars mars_late1 mars_late2 rain_pre1) 

save "$data_tem/control_01_all.dta", replace


**** exact matching 
drop dt_adcode ct_adcode pr_adcode year month day imply id_c pscore_c
duplicates drop control_id, force

joinby mars_pre7 mars_pre6 mars_pre5 mars_pre4 mars_pre3 mars_pre2 mars_pre1 pre_mars mars_late1 mars_late2 rain_pre1 using "$data_tem/treated_01.dta"

keep control_id id_t pscore_t imply 

save "$data_tem/matchid_01.dta", replace


****only keep treatments matched with controls 
keep id_t
merge 1:1 id_t using "$data_tem/treated_01.dta"
keep if _merge==3 // 4568 matched
drop _merge

* Drop treatments that occur within 14 days of the first cloud seeding event at a given location
gen date = mdy(month, day, year)
gen drop_flag = 0
bysort dt_adcode ct_adcode pr_adcode (date): replace drop_flag = 1 if _n > 1 & date - date[_n-1] <= 14	

drop if drop_flag == 1 // 1212 deleted

foreach var of varlist mars_pre1-rain_pre1{
	drop `var'
}
drop pre_mars date drop_flag

save "$data_tem/treated_01_matched.dta", replace


***Adjust the matchid based on treatment
use "$data_tem/matchid_01.dta", clear

merge 1:1 id_t using "$data_tem/treated_01_matched.dta"
keep if _merge==3 // 3356 left
keep control_id id_t pscore_t imply

save "$data_tem/matchid_01.dta", replace


***control group 
use "$data_tem/control_01_all.dta", clear

keep dt_adcode ct_adcode pr_adcode year month day control_id id_c pscore_c imply

xtile quart_bp = id_c, nq(10) // divided into 10 subsamples -- it's faster than matching in one file 
tab quart_bp

save "$data_tem/control_01_all_quart.dta", replace


* It takes approximately 30min to run the loop below. 
forvalues i = 1/10{
    use "$data_tem/control_01_all_quart.dta", clear
    keep if quart_bp == `i'
	
	joinby control_id using "$data_tem/matchid_01.dta"
	drop quart_bp control_id
	
	gen pscore_d = abs(pscore_t-pscore_c)
	sort id_t pscore_d
	by id_t: keep if _n==1
	
	drop pscore_c pscore_t
	save "$data_tem/match_01/match_`i'.dta", replace
	
	keep id_c id_t
	merge 1:1 id_t using "$data_tem/treated_01_matched.dta", keep(match)
	drop _merge pscore_t
	
	append using "$data_tem/match_01/match_`i'.dta"
	
	sort id_t imply
	replace pscore_d = pscore_d[_n-1] if pscore_d==.
	tab imply
	save "$data_tem/match_01/match_`i'.dta", replace
}

** Combine mathced data and find the best psm ones. 
clear
cd "$data_tem/match_01"
openall

sort id_t imply pscore_d
by id_t imply: keep if _n ==1
tab imply

bys id_t id_c: replace city_level = city_level[_n+1] if city_level==.
bys id_t id_c: replace county_level = county_level[_n+1] if county_level==.

save "$data_tem/psm_01_matched.dta"


**** combine dataset
use "$data_tem/psm_no0_matched.dta", clear
append using "$data_tem/psm_01_matched.dta"
tab imply 
drop if pscore_d > 0.005 // 24,749 treatment-control pairs left
save "$data_tem/psm_matched.dta"


use "$data_tem/psm_matched.dta", clear


** Expand the dataset to include a time window from -7 to +7 days relative to the cloud seeding event
gen date=mdy(month,day,year)

expand 18
sort dt_adcode date

bysort id_t id_c dt_adcode date: gen refy = _n - 8
tab refy 

gen shifted_date = date + refy
replace month = month(shifted_date)
replace day = day(shifted_date)
replace year = year(shifted_date)
rename date event_date
rename shifted_date date

*merge prov city county
merge m:1 year month day dt_adcode ct_adcode pr_adcode using "$raw_data/skeleton.dta" , keep(match master)
sort _merge // 55 unmatched, all from 2024/09
drop _merge

*merge meteorological data
merge m:1 year month day prov city county using "$raw_data/skeleton_merged2024.dta", keep(match master) 
drop _merge

save "$data_tem/psm_10days.dta", replace



gen event = refy+7
fvset base 6 event


*************** Graphs
reghdfe pre_mars i.event##c.imply, absorb(date id_t) vce(cluster city)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (-0.6(0.3) 1.2, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "$output_notitle/forecast.png", replace

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (-0.6(0.3) 1.2, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") subtitle("Rainfall: Forecast") scheme(stcolor)
graph export "$output_figure/forecast.png", replace


reghdfe rain_IDW i.event##c.imply, absorb(date id_t) vce(cluster city)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7" 16 "8" 17 "9" 18 "10", labsize(medsmall)) ylabel (-0.6(0.3) 1.2, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "$output_notitle/10d_rain_no20234.png", replace

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (-0.6(0.3) 1.2, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") subtitle("Rainfall") scheme(stcolor)
graph export "$output_figure/10d_rain_no20234.png", replace

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7" 16 "8" 17 "9" 18 "10", labsize(medsmall)) ylabel (-0.6(0.3) 1.2, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") subtitle("Rainfall") scheme(stcolor)

reghdfe GPM_20_20 i.event##c.imply, absorb(date id_t) vce(cluster city)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (-0.6(0.3) 1.2, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "$output_notitle/rain_satellite.png", replace

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (-0.6(0.3) 1.2, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") subtitle("Rainfall: Satellite") scheme(stcolor)
graph export "$output_figure/rain_satellite.png", replace


reghdfe tem_IDW i.event##c.imply, absorb(date id_t) cluster(city)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "$output_notitle/temperature.png", replace

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") subtitle("Temperature") scheme(stcolor)
graph export "$output_figure/temperature.png", replace


reghdfe pm25_satellite i.event##c.imply, absorb(date id_t) cluster(city)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (-4(1)2, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "$output_notitle/pm25.png", replace

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (-4(1)2, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") subtitle("PM2.5") scheme(stcolor)
graph export "$output_figure/pm25.png", replace


reghdfe thickness i.event##c.imply, absorb(date id_t) vce(cluster city)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "$output_notitle/thickness.png", replace

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") subtitle("Cloud Optical Thickness") scheme(stcolor)
graph export "$output_figure/thickness.png", replace


reghdfe fraction i.event##c.imply, absorb(date id_t) vce(cluster city)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "$output_notitle/fraction.png", replace

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") subtitle("Cloud Mask Fraction") scheme(stcolor)
graph export "$output_figure/fraction.png", replace


reghdfe velocity i.event##c.imply, absorb(date id_t) vce(cluster city)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "$output_notitle/velocity.png", replace

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") subtitle("Vertical Velocity") scheme(stcolor)
graph export "$output_figure/velocity.png", replace


reghdfe air_fraction_mean i.event##c.imply, absorb(date id_t) vce(cluster city)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "$output_notitle/air.png", replace

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") subtitle("Updraft Areal Fraction") scheme(stcolor)
graph export "$output_figure/air.png", replace


*****regression 
// Create program to output regression results to LaTeX table
capture program drop reg_to_latex
program define reg_to_latex

    use "$data_tem/psm_7days.dta", clear
	drop if abs(refy) > 7
	drop if pscore_d > 0.005
	
	gen event = refy+7
	fvset base 6 event
	 
    // Run first regression
    gen day_dummy = 0
    replace day_dummy = 1 if refy == 0 | refy == 1
    replace day_dummy = 2 if refy > 1 
    
	// should use absorb(date i.id#i.dt_adcode)
    reghdfe rain_IDW i.day_dummy##c.imply, absorb(date id_t) vce(cluster ct_adcode)
    
    // Save coefficients, standard errors, and p-values
    local b1 = _b[1.day_dummy#c.imply]
    local se1 = _se[1.day_dummy#c.imply]
    local t1 = `b1'/`se1'
    local p1 = 2*normal(-abs(`t1'))
    
    local b2 = _b[2.day_dummy#c.imply]
    local se2 = _se[2.day_dummy#c.imply]
    local t2 = `b2'/`se2'
    local p2 = 2*normal(-abs(`t2'))
    
    // Add stars for significance
    local stars1 = ""
    if `p1' < 0.01 {
        local stars1 = "***"
    }
    else if `p1' < 0.05 {
        local stars1 = "**"
    }
    else if `p1' < 0.1 {
        local stars1 = "*"
    }
    
    local stars2 = ""
    if `p2' < 0.01 {
        local stars2 = "***"
    }
    else if `p2' < 0.05 {
        local stars2 = "**"
    }
    else if `p2' < 0.1 {
        local stars2 = "*"
    }
    
    // Calculate mean of outcome variable in regression sample
    summarize rain_IDW if e(sample)
    local mean_outcome1 = r(mean)
    local obs1 = e(N)
    
    // Run second regression
    gen day_post = 0 
    replace day_post = 1 if refy >= 0
    
	// should use absorb(date i.id#i.dt_adcode)
    reghdfe rain_IDW i.day_post##c.imply, absorb(date id_t) vce(cluster ct_adcode)
    
    // Save coefficients, standard errors, and p-values
    local b3 = _b[1.day_post#c.imply]
    local se3 = _se[1.day_post#c.imply]
    local t3 = `b3'/`se3'
    local p3 = 2*normal(-abs(`t3'))
    
    // Add stars for significance
    local stars3 = ""
    if `p3' < 0.01 {
        local stars3 = "***"
    }
    else if `p3' < 0.05 {
        local stars3 = "**"
    }
    else if `p3' < 0.1 {
        local stars3 = "*"
    }
    
    // Calculate mean of outcome variable in regression sample
    summarize rain_IDW if e(sample)
    local mean_outcome2 = r(mean)
    local obs2 = e(N)
    
    // Create temporary dataset for output
    clear
    set obs 10
    
    // Create variables for output
    gen str50 rowname = ""
    gen str20 col1 = ""
    gen str20 col2 = ""
    
    // Fill data
    replace rowname = "Day 0-1 * Treatment" in 1
    replace col1 = string(`b1', "%9.4f") + "`stars1'" in 1
    replace col2 = "" in 1
    
    replace rowname = "" in 2
    replace col1 = "(" + string(`se1', "%9.3f") + ")" in 2
    replace col2 = "" in 2
    
    replace rowname = "Day 2-7 * Treatment" in 3
    replace col1 = string(`b2', "%9.4f") + "`stars2'" in 3
    replace col2 = "" in 3
    
    replace rowname = "" in 4
    replace col1 = "(" + string(`se2', "%9.3f") + ")" in 4
    replace col2 = "" in 4
    
    replace rowname = "Day 0-7 * Treatment" in 5
    replace col1 = "" in 5
    replace col2 = string(`b3', "%9.4f") + "`stars3'" in 5
    
    replace rowname = "" in 6
    replace col1 = "" in 6
    replace col2 = "(" + string(`se3', "%9.3f") + ")" in 6
    
    replace rowname = "Outcome mean" in 7
    replace col1 = string(`mean_outcome1', "%9.4f") in 7
    replace col2 = string(`mean_outcome2', "%9.4f") in 7
    
    replace rowname = "Pair FE" in 8
    replace col1 = "YES" in 8
    replace col2 = "YES" in 8
    
    replace rowname = "Date FE" in 9
    replace col1 = "YES" in 9
    replace col2 = "YES" in 9
    
    replace rowname = "Observations" in 10
    replace col1 = string(`obs1', "%12.0fc") in 10
    replace col2 = string(`obs2', "%12.0fc") in 10
    
    // output to LaTeX
    #delimit ;
    listtex rowname col1 col2 
        using "$output_table/rain_no20234_7d.tex", 
        replace 
        rstyle(tabular) 
        head(
        "\begin{table}[H]"
        "    \centering"
        "    \renewcommand{\arraystretch}{1.15}"
		"    \resizebox{0.8\textwidth}{!}{"
        "    \begin{tabular}{l c c}"
        "    \hline \hline"
        "    ~ & (1) & (2) \\ "
        "        ~ & Rainfall & Rainfall \\ \hline"
        )
        foot(
        "    \hline"
        "    \end{tabular}"
		"    }"
        "\end{table}"
        )
        ;
    #delimit cr
    
    // Display created LaTeX code
    type "$output_table/rain_no20234_7d.tex"
    
end

reg_to_latex 



