***********************************************************************************************************
** this do file 
** data files used: 
** data files produced:
** last update: 03/07/2025
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
global data_tem "$data/tem/match/pm_5_int"
global output_figure "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\output" 
global output_notitle "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\output"
global output_table "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\output"


*** (1) Matching using integer value of rainfall and forecast  ========================
**** data preparation 
use "$raw_data/skeleton_merged2024.dta", clear

drop date
gen date = mdy(month, day, year)
tsset dt_adcode date

forval i = 1/7 {
	gen mars_pre`i' = int(1*l`i'.pre_mars)
}


forval i = 1/2 {
	gen mars_late`i' = int(1*f`i'.pre_mars)
}

forval i = 1/7 {
	gen tem_pre`i' = int(1*l`i'.tem_IDW)
}

gen rain_pre1 = int(1*l1.rain_IDW)		
replace pre_mars = int(1*pre_mars)

keep mars_pre7 mars_pre6 mars_pre5 mars_pre4 mars_pre3 mars_pre2 mars_pre1 pre_mars mars_late1 mars_late2 rain_pre1 tem_pre7 tem_pre6 tem_pre5 tem_pre4 tem_pre3 tem_pre2 tem_pre1 county prov city dt_adcode ct_adcode pr_adcode year month day imply county_level city_level 

merge 1:1 dt_adcode ct_adcode pr_adcode year month day using "$data_tem/pscore.dta"
drop _merge
drop if pscore ==. // delete those useless observations 
gen id_t = _n if imply == 1
gen id_c = _n if imply == 0

save "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\int_forecast_rain_temperature_01.dta", replace

********treated group 
keep if imply == 1
drop id_c 
drop prov city county 
rename pscore pscore_t

drop if mars_pre7==. | mars_pre6==.|mars_pre5==.|mars_pre4==.|mars_pre3==.| mars_pre2==.| mars_pre1==.| pre_mars==.| mars_late1==.| mars_late2==. 
drop if rain_pre1 == . 
drop if tem_pre7 ==. | tem_pre6 ==. | tem_pre5 ==. | tem_pre4 ==. | tem_pre3 ==. | tem_pre2 ==. | tem_pre1==. // 64,639 treatments left

drop if mars_pre7==0 & mars_pre6==0 & mars_pre5==0 & mars_pre4==0 & mars_pre3 ==0 & mars_pre2 ==0 & mars_pre1==0 &mars_late1==0 &mars_late2==0 & pre_mars==0 & rain_pre1==0  & tem_pre7 == 0 & tem_pre6==0 & tem_pre5==0 & tem_pre4==0 & tem_pre3==0 & tem_pre2 ==0 & tem_pre1 ==0 // 0 observations deleted

save "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\treated_no0.dta", replace

*** Control group
use "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\int_forecast_rain_temperature_01.dta", clear

drop if imply == 1

drop if mars_pre7==. | mars_pre6==.|mars_pre5==.|mars_pre4==.|mars_pre3==.| mars_pre2==.| mars_pre1==.| pre_mars==.| mars_late1==.| mars_late2==. 
drop if rain_pre1 == . 
drop if tem_pre7 ==. | tem_pre6 ==. | tem_pre5 ==. | tem_pre4 ==. | tem_pre3 ==. | tem_pre2 ==. | tem_pre1==. // 

drop if mars_pre7==0 & mars_pre6==0 & mars_pre5==0 & mars_pre4==0 & mars_pre3 ==0 & mars_pre2 ==0 & mars_pre1==0 &mars_late1==0 &mars_late2==0 & pre_mars==0 & rain_pre1==0  & tem_pre7 == 0 & tem_pre6==0 & tem_pre5==0 & tem_pre4==0 & tem_pre3==0 & tem_pre2 ==0 & tem_pre1 ==0 // 52 observations deleted

drop id_t
drop prov city county city_level county_level
rename pscore pscore_c

egen control_id = group(mars_pre7 mars_pre6 mars_pre5 mars_pre4 mars_pre3 mars_pre2 mars_pre1 pre_mars mars_late1 mars_late2 rain_pre1 tem_pre7 tem_pre6 tem_pre5 tem_pre4 tem_pre3 tem_pre2 tem_pre1) 

save "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\control_no0_all.dta", replace


**** exact matching 
drop dt_adcode ct_adcode pr_adcode year month day imply id_c pscore_c
duplicates drop control_id, force

joinby mars_pre7 mars_pre6 mars_pre5 mars_pre4 mars_pre3 mars_pre2 mars_pre1 pre_mars mars_late1 mars_late2 rain_pre1 tem_pre7 tem_pre6 tem_pre5 tem_pre4 tem_pre3 tem_pre2 tem_pre1 using "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\treated_no0.dta"

keep control_id id_t pscore_t imply 

save "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\matchid_no0.dta", replace


****only keep treatments matched with controls 
keep id_t
merge 1:1 id_t using "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\treated_no0.dta"
keep if _merge==3 // 15408 matched
drop _merge

* Drop treatments that occur within 14 days of the first cloud seeding event at a given location
gen date = mdy(month, day, year)
gen drop_flag = 0
bysort dt_adcode ct_adcode pr_adcode (date): replace drop_flag = 1 if _n > 1 & date - date[_n-1] <= 14	

drop if drop_flag == 1 // 13,158 deleted

foreach var of varlist mars_pre1-tem_pre7{
	drop `var'
}
drop pre_mars date drop_flag

save "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\treated_no0_matched.dta", replace


***Adjust the matchid based on treatment
use "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\matchid_no0.dta", clear

merge 1:1 id_t using "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\treated_no0_matched.dta"
keep if _merge==3 // 10921 left
keep control_id id_t pscore_t imply

save "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\matchid_no0.dta", replace


***control group 
use "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\control_no0_all.dta", clear

keep dt_adcode ct_adcode pr_adcode year month day control_id id_c pscore_c imply

xtile quart_bp = id_c, nq(10) // divided into 10 subsamples -- it's faster than matching in one file 
tab quart_bp

save "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\control_no0_all_quart.dta", replace

use "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\control_no0_all_quart.dta", clear
* It takes approximately 20min to run the loop below. (这里是因为之前不加soil的匹配上的非常多，所以要花很长时间；如果匹配上的不多，或许可以不需要这个循环，直接运行)
//在这里要注意提前创建\match_no0\文件夹避免报错，以及更改改文件为可阅读
forvalues i = 1/10{
    use "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\control_no0_all_quart.dta", clear
    keep if quart_bp == `i'
	
	joinby control_id using "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\matchid_no0.dta"
	drop quart_bp control_id
	
	gen pscore_d = abs(pscore_t-pscore_c)
	sort id_t pscore_d
	by id_t: keep if _n==1
	
	drop pscore_c pscore_t
	save "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\match_no0\match_`i'.dta", replace
	
	keep id_c id_t
	merge 1:1 id_t using "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\treated_no0_matched.dta", keep(match)
	drop _merge pscore_t
	
	append using "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\match_no0\match_`i'.dta"
	
	sort id_t imply
	replace pscore_d = pscore_d[_n-1] if pscore_d==.
	tab imply
	save "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\match_no0\match_`i'.dta", replace
}

** Combine mathced data and find the best psm ones. 
clear
cd "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\match_no0"
openall

sort id_t imply pscore_d
by id_t imply: keep if _n ==1
tab imply

bys id_t id_c: replace city_level = city_level[_n+1] if city_level==.
bys id_t id_c: replace county_level = county_level[_n+1] if county_level==.

save "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\psm_no0_matched.dta", replace


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

save "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\psm_10days.dta", replace


use "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\psm_10days.dta", clear
gen event = refy+7
fvset base 6 event

egen unique_county=group(dt_adcode id_t)

egen doy=group(month day)

egen calendar_month=group(year month)

gen cluster=.
replace cluster = id_t if imply==1
replace cluster = id_c if imply==0


*************** Graphs
reghdfe tem_IDW i.event##c.imply, absorb(unique_county i.refy#i.id_t year doy) vce(cluster cluster calendar_month)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\output\draft\psm_temperature.png", replace



//weighted results
//1.weighted by county area
clear all
use "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\psm_10days.dta", clear
gen event = refy+7
fvset base 6 event

egen unique_county=group(dt_adcode id_t)

egen doy=group(month day)

egen calendar_month=group(year month)

gen cluster=.
replace cluster = id_t if imply==1
replace cluster = id_c if imply==0

merge m:1 year prov city county using "F:\research\dataset\county\county_panel_line.dta"
keep if _merge == 3
drop _merge 

reghdfe tem_IDW i.event##c.imply [aw=county_area], absorb(unique_county i.refy#i.id_t year doy) vce(cluster cluster calendar_month)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\output\draft\psm_temperature_weightedby_area.png", replace


//2.weighted by agriculture area
clear all
use "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\data\temperature\psm_10days.dta", clear
gen event = refy+7
fvset base 6 event

egen unique_county=group(dt_adcode id_t)

egen doy=group(month day)

egen calendar_month=group(year month)

gen cluster=.
replace cluster = id_t if imply==1
replace cluster = id_c if imply==0

merge m:1 year prov city county using "F:\research\dataset\county\county_panel_line.dta"
keep if _merge == 3
drop _merge 

reghdfe tem_IDW i.event##c.imply [aw=population], absorb(unique_county i.refy#i.id_t year doy) vce(cluster cluster calendar_month)

coefplot, yline(0, lp(solid) lc(cranberry)) xline(7.5, lp(dash) lc(black)) baselevels omitted vert keep(*event#c.imply) xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7", labsize(medsmall)) ylabel (, nogrid) ciopt(lcolor(black)) mcolor(black)  ///
    xtitle("Days Relative to Cloud Seeding Day") scheme(stcolor)	
graph export "F:\dropbox\Dropbox\Predoc_Project\Cloud_Seeding\output\draft\psm_temperature_weightedby_population.png", replace





