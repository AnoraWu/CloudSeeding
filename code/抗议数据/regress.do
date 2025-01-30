cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding"

use "data/抗议数据/final_panel.dta",clear
gen date = mdy(month,day,year)


* county level
preserve
drop if city == 1

est clear

xtset adcode date

eststo: reg n_cloudseeding n_prt_rfa n_prt_weibo, vce(cluster adcode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa n_prt_weibo, absorb(adcode) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa n_prt_weibo, absorb(adcode date) vce(cluster adcode)
estadd local  FE  "YES"
estadd local  TE  "YES"

ereturn list
 
esttab using "output/抗议数据/reg_county.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("Perfecture-day panel regression")
 
restore


* city level
preserve 
gen citycode = real(substr(string(adcode, "%12.0f"), 1, 4))
collapse (sum) n_cloudseeding n_prt_rfa n_prt_weibo, by (citycode date)

label var n_cloudseeding "number of cloudseeding"
label var n_prt_weibo "number of protests from weibo"
label var n_prt_rfa   "number of protests from rfa"

est clear

xtset citycode date

eststo: reg n_cloudseeding n_prt_rfa n_prt_weibo, vce(cluster citycode)
estadd local  FE  "NO"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa n_prt_weibo, absorb(citycode) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "NO"

eststo: reghdfe n_cloudseeding n_prt_rfa n_prt_weibo, absorb(citycode date) vce(cluster citycode)
estadd local  FE  "YES"
estadd local  TE  "YES"


esttab using "output/抗议数据/reg_city.tex", replace   ///
 b(3) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label noobs nonotes nomtitle collabels(none) compress ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 title("City-day panel regression")

restore

