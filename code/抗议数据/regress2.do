* input dir
cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"

use "final_panel_newweibo.dta",clear

* output dir
cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/output/抗议数据"


********************************************************
***************** county day regression ****************
********************************************************

label var n_cloudseeding "num of cloudseeding"
label var n_prt_weibo "number of protests from weibo"
label var n_prt_rfa   "number of protests from rfa"
label var size_rfa "size of rfa protests"
label var size_weibo "size of weibo protests"
label var size_original_weibo "size of weibo protests (original)"
label var size_original_rfa "size of rfa protests (original)"


**** use the original size variable ****
preserve 

xtset adcode date

drop if city == 1

* use the previous three day mean rainfall to avoid reverse causality
forvalues i = 1(1)3{
	bys adcode (date): gen rain_`i' = L`i'.rainfall
}
drop rainfall
gen rainfall = (rain_1 + rain_2 + rain_3)/3
label var rainfall "rainfall"
drop rain_*

gen interaction_weibo = size_original_weibo * n_prt_weibo
label var interaction_weibo "protests (weibo) \times size"

gen interaction_rfa = size_original_rfa * n_prt_rfa
label var interaction_rfa "protests (rfa) \times size"




*** no fixed effects
* weibo
est clear

eststo: reg n_cloudseeding n_prt_weibo, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo rainfall, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* rfa
eststo: reg n_cloudseeding n_prt_rfa, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_rfa rainfall, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* weibo and rfa
eststo: reg n_cloudseeding n_prt_weibo n_prt_rfa, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reg n_cloudseeding n_prt_weibo n_prt_rfa rainfall, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

esttab using "5a.tex", replace   ///
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

eststo: reghdfe n_cloudseeding n_prt_weibo rainfall, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa rainfall, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa rainfall, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

esttab using "5b.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("county-day panel regression, clustered at county level, county fixed effects")

*** time and entity fixed effects
* weibo
est clear

eststo: reghdfe n_cloudseeding n_prt_weibo, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"


eststo: reghdfe n_cloudseeding n_prt_weibo rainfall, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"


eststo: reghdfe n_cloudseeding n_prt_rfa rainfall, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"


eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa rainfall, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"
 
esttab using "5c.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("county-day panel regression, clustered at county level, county and day fixed effects")

restore




********************************************************
*************** city day regression ************
********************************************************

* replace rainfall as missing if all counties within a city has missing rainfall data
bysort citycode date: egen mnrainfall = mean(rainfall) 
replace rainfall = -999999999  if(mnrainfall == .) 

* keep missing if, for all the available protests, one of the their size is missing
* Create an indicator for missing protest size where protest > 0
gen size_original_weibo_missing = missing(size_original_weibo) if n_prt_weibo>0
gen size_original_rfa_missing = missing(size_original_rfa) if n_prt_rfa>0

collapse (sum) n_cloudseeding n_prt_rfa n_prt_weibo size_weibo ///
			   size_original_weibo size_rfa size_original_rfa rainfall ///
		 (max) size_original_weibo_missing size_original_rfa_missing, ///
		 by (citycode date)

replace rainfall =. if rainfall < 0
replace size_original_rfa = . if size_original_rfa_missing == 1 & n_prt_rfa > 0
replace size_original_rfa = . if n_prt_rfa == 0
replace size_original_weibo = . if size_original_weibo_missing == 1 & n_prt_weibo > 0
replace size_original_weibo = . if n_prt_weibo == 0

drop size_original_weibo_missing size_original_rfa_missing

label var n_cloudseeding "num of cloudseeding"
label var n_prt_weibo "number of protests from weibo"
label var n_prt_rfa   "number of protests from rfa"
label var size_rfa "size of rfa protests"
label var size_weibo "size of weibo protests"
label var size_original_weibo "size of weibo protests (original)"
label var size_original_rfa "size of rfa protests (original)"
label var rainfall "rainfall"


**** use the original size variable ****
preserve 

xtset citycode date

* use the previous three day mean rainfall to avoid reverse causality
forvalues i = 1(1)3{
	bys citycode (date): gen rain_`i' = L`i'.rainfall
}
drop rainfall
gen rainfall = (rain_1 + rain_2 + rain_3)/3
label var rainfall "rainfall"
drop rain_*

gen interaction_weibo = size_original_weibo * n_prt_weibo
label var interaction_weibo "protests (weibo) \times size"

gen interaction_rfa = size_original_rfa * n_prt_rfa
label var interaction_rfa "protests (rfa) \times size"


*** no fixed effects
* weibo
est clear

eststo: reg n_cloudseeding n_prt_weibo, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"


eststo: reg n_cloudseeding n_prt_weibo rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* rfa
eststo: reg n_cloudseeding n_prt_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"


eststo: reg n_cloudseeding n_prt_rfa rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* weibo and rfa
eststo: reg n_cloudseeding n_prt_weibo n_prt_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"


eststo: reg n_cloudseeding n_prt_weibo  n_prt_rfa  rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

esttab using "2a.tex", replace   ///
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


eststo: reghdfe n_cloudseeding n_prt_weibo rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"


eststo: reghdfe n_cloudseeding n_prt_rfa rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo  n_prt_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"


eststo: reghdfe n_cloudseeding n_prt_weibo  n_prt_rfa  rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

esttab using "2b.tex", replace   ///
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

eststo: reghdfe n_cloudseeding n_prt_weibo rainfall, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"


eststo: reghdfe n_cloudseeding n_prt_rfa rainfall, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"


eststo: reghdfe n_cloudseeding n_prt_weibo  n_prt_rfa  rainfall, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"
 
esttab using "2c.tex", replace   ///
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
*************** city week panel regression *************
********************************************************

* replace rainfall as missing if all days within a week has missing rainfall data
bysort citycode week: egen mnrainfall = mean(rainfall) 
replace rainfall = -999999999  if(mnrainfall == .) 

* keep missing if, for all the available protests, one of the their size is missing
* Create an indicator for missing protest size where protest > 0
gen size_original_weibo_missing = missing(size_original_weibo) if n_prt_weibo>0
gen size_original_rfa_missing = missing(size_original_rfa) if n_prt_rfa>0

collapse (sum) n_cloudseeding n_prt_rfa n_prt_weibo size_weibo ///
			   size_original_weibo size_rfa size_original_rfa rainfall ///
		 (max) size_original_weibo_missing size_original_rfa_missing, ///
		 by (citycode week)

replace rainfall =. if rainfall < 0
replace size_original_rfa = . if size_original_rfa_missing == 1 & n_prt_rfa > 0
replace size_original_rfa = . if n_prt_rfa == 0
replace size_original_weibo = . if size_original_weibo_missing == 1 & n_prt_weibo > 0
replace size_original_weibo = . if n_prt_weibo == 0

drop size_original_weibo_missing size_original_rfa_missing

label var n_cloudseeding "num of cloudseeding"
label var n_prt_weibo "number of protests from weibo"
label var n_prt_rfa   "number of protests from rfa"
label var size_rfa "size of rfa protests"
label var size_weibo "size of weibo protests"
label var size_original_weibo "size of weibo protests (original)"
label var size_original_rfa "size of rfa protests (original)"
label var rainfall "rainfall"

**** use the original size variable ****
preserve 

xtset citycode week

* use lasst week's rainfall
replace rainfall = L.rainfall

gen interaction_weibo = size_original_weibo * n_prt_weibo
label var interaction_weibo "protests (weibo) \times size"

gen interaction_rfa = size_original_rfa * n_prt_rfa
label var interaction_rfa "protests (rfa) \times size"

*** no fixed effects
* weibo
est clear

eststo: reg n_cloudseeding n_prt_weibo, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"


eststo: reg n_cloudseeding n_prt_weibo  rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* rfa
eststo: reg n_cloudseeding n_prt_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"


eststo: reg n_cloudseeding n_prt_rfa  rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

* weibo and rfa
eststo: reg n_cloudseeding n_prt_weibo n_prt_rfa, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"


eststo: reg n_cloudseeding n_prt_weibo  n_prt_rfa  rainfall, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

esttab using "4a.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("city-week panel regression, clustered at city level, no fixed effects")

*** entity fixed effects
* weibo
est clear

eststo: reghdfe n_cloudseeding n_prt_weibo, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"


eststo: reghdfe n_cloudseeding n_prt_weibo rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"


eststo: reghdfe n_cloudseeding n_prt_rfa rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo  n_prt_rfa, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"


eststo: reghdfe n_cloudseeding n_prt_weibo  n_prt_rfa  rainfall, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

esttab using "4b.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("city-week panel regression, clustered at city level, city fixed effects")

*** time and entity fixed effects
* weibo
est clear

eststo: reghdfe n_cloudseeding n_prt_weibo, absorb(citycode week) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"


eststo: reghdfe n_cloudseeding n_prt_weibo rainfall, absorb(citycode week) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* rfa
eststo: reghdfe n_cloudseeding n_prt_rfa, absorb(citycode week) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"


eststo: reghdfe n_cloudseeding n_prt_rfa rainfall, absorb(citycode week) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"

* weibo and rfa
eststo: reghdfe n_cloudseeding n_prt_weibo n_prt_rfa, absorb(citycode week) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"


eststo: reghdfe n_cloudseeding n_prt_weibo  n_prt_rfa  rainfall, absorb(citycode week) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"
 
esttab using "4c.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("city-week panel regression, clustered at city level, city and week fixed effects")

restore

