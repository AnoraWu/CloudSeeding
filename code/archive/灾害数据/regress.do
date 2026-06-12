* regress 
* instructions:  数据加总在prefecture-year level，Y是这个地方这一年的冰雹次数，X是这个地方这一年做了多少次人工降雨（分别试一下全年的数量，或者夏季的数量）。table第一列没有FE，第二列控制prefecture FE, 第三列prefecture FE和year FE.

cd "$datadir"


clear all 


************ hails **********

* all disasters
use disaster_cloudseeding_panel_hails.dta, clear
gen year = year(dofm(modate))
gen month = month(dofm(modate))

* all year
preserve 

replace disaster = 0 if disaster ==.
collapse (sum) directeconomiclosses differentdamage affectedpopulation cropsaffectedarea cropscroparea disaster cloudseeding, by (citycode year)

xtset citycode year

label var cloudseeding "Num. of Cloud Seeding"

est clear
foreach x of varlist disaster cropsaffectedarea directeconomiclosses {
 eststo: reghdfe `x'  cloudseeding L.disaster, vce(cluster citycode)
  estadd local FE  "NO"
  estadd local TE  "NO"
  
 eststo: reghdfe `x'  cloudseeding L.disaster, a(citycode) vce(cluster citycode)
  estadd local FE  "YES"
  estadd local TE  "NO"
  
 eststo: reghdfe `x'  cloudseeding L.disaster, a(citycode year) vce(cluster citycode)
  estadd local FE  "YES"
  estadd local TE  "NO"
 }

esttab using "hails_allyear_allreg.tex", replace   ///
 b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
 label booktabs nonotes noobs nomtitle collabels(none)  ///
 scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
 mgroups("number of disasters" "crops affected area" "direct economic losses", pattern(1 0 0 1 0 0 1 0 0) ///
 prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) alignment(D{.}{.}{-1}) ///
 title("All year data, include only hails")

restore

// * only summer 
// preserve 
//
// keep if inlist(month, 6, 7, 8) // 只保留6-8月数据
//
// collapse (sum) directeconomiclosses differentdamage affectedpopulation cropsaffectedarea cropscroparea disaster cloudseeding, by (citycode year)
//
// xtset citycode year
//
// est clear
// foreach x of varlist disaster cropsaffectedarea directeconomiclosses {
//  eststo: reghdfe `x'  cloudseeding, vce(cluster citycode)
//   estadd local FE  "NO"
//   estadd local TE  "NO"
//  
//  eststo: reghdfe `x'  cloudseeding, a(citycode) vce(cluster citycode)
//   estadd local FE  "YES"
//   estadd local TE  "NO"
//  
//  eststo: reghdfe `x'  cloudseeding, a(citycode year) vce(cluster citycode)
//   estadd local FE  "YES"
//   estadd local TE  "YES"
//  }
//
// esttab using "hails_summer.tex", replace   ///
//  b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
//  label booktabs nonotes noobs nomtitle collabels(none)  ///
//  scalars("r2 R-squared" "TE Time Effects" "FE Fixed effects") sfmt(3 0) ///
//  mgroups("number of disasters" "crops affected area" "direct economic losses", pattern(1 0 0 1 0 0 1 0 0) ///
//  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) alignment(D{.}{.}{-1}) ///
//  title("Summer data, include only hails")
//
// restore
//
