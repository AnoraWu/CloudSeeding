* regress 
* instructions:  数据加总在prefecture-year level，Y是这个地方这一年的冰雹次数，X是这个地方这一年做了多少次人工降雨（分别试一下全年的数量，或者夏季的数量）。table第一列没有FE，第二列控制prefecture FE, 第三列prefecture FE和year FE.

cd "C:\Users\Anora\OneDrive\Desktop\data"
clear all 


************ hails **********

* all disasters
use disaster_cloudseeding_panel_hails.dta, clear
gen year = year(dofm(modate))
gen month = month(dofm(modate))

* all year
preserve 

collapse (sum) directeconomiclosses differentdamage affectedpopulation cropsaffectedarea cropscroparea disaster cloudseeding, by (citycode year)

xtset citycode year

label var cloudseeding "Num. of Cloud Seeding"

est clear
foreach x of varlist disaster {
 qui sum `x'
 local outcome_mean = r(mean)   // Store the mean before regression
	
 eststo: reghdfe `x'  cloudseeding, vce(cluster citycode)
 estadd scalar outcome_mean = `outcome_mean'  // Add the mean after regression
  estadd local FE  "NO"
  estadd local TE  "NO"
  
 eststo: reghdfe `x'  cloudseeding, a(citycode) vce(cluster citycode)
 estadd scalar outcome_mean = `outcome_mean'  // Add the mean after regression
  estadd local FE  "YES"
  estadd local TE  "NO"
  
 eststo: reghdfe `x'  cloudseeding, a(citycode year) vce(cluster citycode)
 estadd scalar outcome_mean = `outcome_mean'  // Add the mean after regression
  estadd local FE  "YES"
  estadd local TE  "YES"
 }

esttab using "hails_allyear.tex", replace   ///
 b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
 label booktabs nonotes noobs collabels(none)  ///
 scalars("outcome_mean Outcome mean" "FE City FE" "TE Year FE" "N Observations") sfmt("%9.1f" "%9.0fc" "%9.0fc" "%9.0fc") nocons ///
 mtitles("Num. of Hails" "Num. of Hails" "Num. of Hails")
 
restore


