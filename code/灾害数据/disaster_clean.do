clear all

use "/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding/Cloud Seeding/data/raw/skeleton_merged2024.dta", clear

keep imply dt_adcode year month 
ren dt_adcode adcode 

gen modate=ym(year,month)
format modate %tm

gen citycode = substr(string(adcode), 1, 4)
* counties directly under province
replace citycode = string(adcode) if substr(string(adcode), 3, 2) == "90"
destring citycode, replace

replace citycode = 1100 if (substr(string(citycode), 1, 2) == "11")
replace citycode = 1200 if (substr(string(citycode), 1, 2) == "12")
replace citycode = 3100 if (substr(string(citycode), 1, 2) == "31")
replace citycode = 5000 if (substr(string(citycode), 1, 2) == "50")

collapse (sum) cloudseeding = imply, by (citycode modate)

cd "$datadir"
save region_month_cloudseeding.dta,replace


***** disaster *****
// import delimited "disaster_adcode.csv", clear 
import delimited "disaster_adcode_hails.csv", clear 

keep eventstartdate citycode2 provincecode

gen disaster = 1

ren citycode2 citycode 

* clean date variable
gen date = date(substr(eventstartdate, 1, 10), "YMD")

gen year = year(date)
gen month = month(date)
gen modate=ym(year,month)
format modate %tm

drop if date==.
drop date eventstartdate
replace citycode = 	3701 if citycode == 3712
replace citycode =  5406 if citycode == 5424
replace citycode = 	4228 if citycode == 4290

collapse (sum) disaster, by (citycode modate)

tempfile disaster
save `disaster'

use region_month_cloudseeding.dta, clear
merge 1:1 citycode modate using `disaster'

drop _merge

replace  disaster = 0 if disaster ==.
save disaster_cloudseeding_panel_hails.dta, replace
