clear all

cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/灾害数据"

use "region_time_cleaned.dta",clear
gen year = year(date)
gen month = month(date)
gen modate=ym(year,month)
format modate %tm
drop date 

drop if substr(string(adcode), -4, 4) == "0000" & adcode != 120000 & adcode != 110000 & adcode != 500000 & adcode != 310000

gen citycode = substr(string(adcode), 1, 4)
* counties directly under province
replace citycode = string(adcode) if substr(string(adcode), 3, 2) == "90"
destring citycode, replace

replace citycode = 1100 if (substr(string(citycode), 1, 2) == "11")
replace citycode = 1200 if (substr(string(citycode), 1, 2) == "12")
replace citycode = 3100 if (substr(string(citycode), 1, 2) == "31")
replace citycode = 5000 if (substr(string(citycode), 1, 2) == "50")

duplicates drop citycode modate, force
drop adcode year month 
save region_month_cleaned.dta,replace


***** disaster *****
// import delimited "disaster_adcode.csv", clear 
import delimited "disaster_adcode_hails.csv", clear 

* keep relevant variable
encode eventclassify, gen(class)
fre class
keep if inlist(class,2)

keep eventstartdate directeconomiclosses differentdamage affectedpopulation cropsaffectedarea cropscroparea citycode2 provincecode

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


collapse (sum) directeconomiclosses differentdamage affectedpopulation cropsaffectedarea cropscroparea disaster, by (citycode modate)

tempfile disaster
save `disaster'

use region_month_cleaned.dta, clear
merge 1:1 citycode modate using `disaster'

drop _merge
tempfile disaster_panel
save `disaster_panel'

***** cloudseeding *****
* I didn't use the 2020 adcode here. I used the cpca package version
import delimited "cloudseeding_adcode.csv", clear 
keep op_date adcode

ren op_date date
gen year = year(date)
gen month = month(date)
gen modate=ym(year,month)
format modate %tm

drop if date==.
drop date 

drop if substr(string(adcode), -4, 4) == "0000" & adcode != 120000 & adcode != 110000 & adcode != 500000 & adcode != 310000

gen citycode = substr(string(adcode), 1, 4)
* counties directly under province
replace citycode = string(adcode) if substr(string(adcode), 3, 2) == "90"
destring citycode, replace
replace citycode = 	3701 if citycode == 3712
replace citycode = 	4228 if citycode == 4290

replace citycode = 1100 if (substr(string(citycode), 1, 2) == "11")
replace citycode = 1200 if (substr(string(citycode), 1, 2) == "12")
replace citycode = 3100 if (substr(string(citycode), 1, 2) == "31")
replace citycode = 5000 if (substr(string(citycode), 1, 2) == "50")

gen cloudseeding = 1

collapse (sum) cloudseeding, by (citycode modate)

merge 1:1 citycode modate using `disaster_panel'
drop _merge

save disaster_cloudseeding_panel_hails.dta, replace
