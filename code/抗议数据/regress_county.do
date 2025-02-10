* input dir
cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"

use "final_panel.dta",clear

* output dir
cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/output/抗议数据"


********************************************************
*************** county day panel regression ************
********************************************************


preserve 

gen interaction_weibo = size_weibo * n_prt_weibo
label var interaction_weibo "protests (weibo) \times size"

gen interaction_rfa = size_rfa * n_prt_rfa
label var interaction_rfa "protests (rfa) \times size"

drop if city == 1


xtset adcode date

*** no fixed effects
* weibo
est clear

eststo: reg n_cloudseeding n_prt_weibo, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo rainfall, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* rfa
eststo: reg n_cloudseeding n_prt_rfa, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_rfa interaction_rfa, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_rfa interaction_rfa rainfall, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* weibo and rfa
eststo: reg n_cloudseeding n_prt_weibo n_prt_rfa, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

esttab using "reg_no_fixed_effects.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("county-day panel regression, clustered at county level, no fixed effects")

*** entity fixed effects
* weibo
est clear

eststo: reghdfe n_cloudseeding n_prt_weibo, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo rainfall, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa rainfall, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

esttab using "reg_county_fixed_effects.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("county-day panel regression, clustered at county level, county fixed effects")

 
****** time and entity fixed effects ******
* weibo
est clear

eststo: reghdfe n_cloudseeding n_prt_weibo, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo rainfall, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa rainfall, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"
 
esttab using "reg_county_day_fixed_effects.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("county-day panel regression, clustered at county level, county and day fixed effects")

restore


********************************************************
*************** city day panel regression ************
********************************************************

preserve 

* replace rainfall as missing if all counties within a city has missing rainfall data
bysort citycode date: egen mnrainfall = mean(rainfall) 
replace rainfall = -999999999  if(mnrainfall == .) 

collapse (sum) n_cloudseeding n_prt_rfa n_prt_weibo size_weibo size_rfa rainfall, by (citycode date)
replace rainfall =. if rainfall < 0

label var n_cloudseeding "num of cloudseeding"
label var n_prt_weibo "number of protests from weibo"
label var n_prt_rfa   "number of protests from rfa"
label var size_rfa "size of rfa protests (sum)"
label var size_weibo "max size of weibo protests (sum)"
label var rainfall "rainfall"

gen interaction_weibo = size_weibo * n_prt_weibo
label var interaction_weibo "protests (weibo) \times size"

gen interaction_rfa = size_rfa * n_prt_rfa
label var interaction_rfa "protests (rfa) \times size"


xtset citycode date

*** no fixed effects
* weibo
est clear

eststo: reg n_cloudseeding n_prt_weibo, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"


eststo: reg n_cloudseeding n_prt_weibo interaction_weibo, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* rfa
eststo: reg n_cloudseeding n_prt_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_rfa interaction_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_rfa interaction_rfa rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* weibo and rfa
eststo: reg n_cloudseeding n_prt_weibo n_prt_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

esttab using "reg_no_fixed_effects_city.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("city-day panel regression, clustered at city level, no fixed effects")

*** entity fixed effects
* weibo
est clear

eststo: reghdfe n_cloudseeding n_prt_weibo, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo  n_prt_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

esttab using "reg_city_fixed_effects.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("city-day panel regression, clustered at city level, city fixed effects")

*** time and entity fixed effects
* weibo
est clear

eststo: reghdfe n_cloudseeding n_prt_weibo, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo rainfall, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa rainfall, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"
 
esttab using "reg_city_day_fixed_effects.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("city-day panel regression, clustered at city level, city and day fixed effects")

restore




* input dir
cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"

use "final_panel.dta",clear

* output dir
cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/output/抗议数据"


********************************************************
*************** county week panel regression ************
********************************************************

preserve 



gen interaction_weibo = size_weibo * n_prt_weibo
label var interaction_weibo "protests (weibo) \times size"

gen interaction_rfa = size_rfa * n_prt_rfa
label var interaction_rfa "protests (rfa) \times size"

drop if city == 1


xtset adcode date

*** no fixed effects
* weibo
est clear

eststo: reg n_cloudseeding n_prt_weibo, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo rainfall, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* rfa
eststo: reg n_cloudseeding n_prt_rfa, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_rfa interaction_rfa, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_rfa interaction_rfa rainfall, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* weibo and rfa
eststo: reg n_cloudseeding n_prt_weibo n_prt_rfa, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

esttab using "reg_no_fixed_effects.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("county-day panel regression, clustered at county level, no fixed effects")

*** entity fixed effects
* weibo
est clear

eststo: reghdfe n_cloudseeding n_prt_weibo, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo rainfall, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa rainfall, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

esttab using "reg_county_fixed_effects.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("county-day panel regression, clustered at county level, county fixed effects")

 
****** time and entity fixed effects ******
* weibo
est clear

eststo: reghdfe n_cloudseeding n_prt_weibo, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo rainfall, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa rainfall, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"
 
esttab using "reg_county_day_fixed_effects.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("county-day panel regression, clustered at county level, county and day fixed effects")

restore


********************************************************
*************** city week panel regression ************
********************************************************

preserve 

* replace rainfall as missing if all counties within a city has missing rainfall data
bysort citycode date: egen mnrainfall = mean(rainfall) 
replace rainfall = -999999999  if(mnrainfall == .) 

collapse (sum) n_cloudseeding n_prt_rfa n_prt_weibo size_weibo size_rfa rainfall, by (citycode date)
replace rainfall =. if rainfall < 0

label var n_cloudseeding "num of cloudseeding"
label var n_prt_weibo "number of protests from weibo"
label var n_prt_rfa   "number of protests from rfa"
label var size_rfa "size of rfa protests (sum)"
label var size_weibo "max size of weibo protests (sum)"
label var rainfall "rainfall"

gen interaction_weibo = size_weibo * n_prt_weibo
label var interaction_weibo "protests (weibo) \times size"

gen interaction_rfa = size_rfa * n_prt_rfa
label var interaction_rfa "protests (rfa) \times size"


xtset citycode date

*** no fixed effects
* weibo
est clear

eststo: reg n_cloudseeding n_prt_weibo, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"


eststo: reg n_cloudseeding n_prt_weibo interaction_weibo, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* rfa
eststo: reg n_cloudseeding n_prt_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_rfa interaction_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_rfa interaction_rfa rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* weibo and rfa
eststo: reg n_cloudseeding n_prt_weibo n_prt_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

esttab using "reg_no_fixed_effects_city.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("city-day panel regression, clustered at city level, no fixed effects")

*** entity fixed effects
* weibo
est clear

eststo: reghdfe n_cloudseeding n_prt_weibo, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo  n_prt_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

esttab using "reg_city_fixed_effects.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("city-day panel regression, clustered at city level, city fixed effects")

*** time and entity fixed effects
* weibo
est clear

eststo: reghdfe n_cloudseeding n_prt_weibo, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo rainfall, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_rfa interaction_rfa rainfall, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

eststo: reghdfe n_cloudseeding n_prt_weibo interaction_weibo n_prt_rfa interaction_rfa rainfall, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"
 
esttab using "reg_city_day_fixed_effects.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("city-day panel regression, clustered at city level, city and day fixed effects")

restore



