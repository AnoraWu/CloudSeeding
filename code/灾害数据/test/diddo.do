clear all

cd "D:\Git Local\CloudSeeding\code\灾害数据"

use "disaster_cloudseeding_panel.dta",clear

replace cloudseeding = 0 if cloudseeding >=.
gen treated = (cloudseeding != 0)

* recode time variable
bys citycode (modate): gen month = _n

* gen gvar1
gen gvar1 = month if treated == 1
bys citycode: egen gvar = min(gvar1)
replace gvar = 0 if gvar ==.


foreach var in directeconomiclosses differentdamage affectedpopulation cropsaffectedarea cropscroparea disaster {
    replace `var' = 0 if `var' >= .
}

export delimited using "did_data", replace

replace gvar = 3000 if gvar == 0
replace treated = 1 if month >= gvar

reghdfe disaster treated, absorb(citycode month) cluster(citycode)