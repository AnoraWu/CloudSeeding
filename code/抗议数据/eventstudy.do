
* input dir
cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"

use "final_panel.dta",clear

* output dir
cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/output/抗议数据"



**************** event study at county level *****************

gen protest_date = date if n_prt_weibo >= 0
bys adcode (date): egen first_oper = min(protest_date)
drop protest_date
gen rd = date - first_oper
gen never_protest = (first_oper == .)

replace rd = 4 if rd>=4 & rd!=. // bin the lead and
replace rd = -4 if rd<=-4

forvalues k = 4(-1)2 {
	   gen g_`k' = rd == -`k'
	}
	forvalues k = 0/4 {
		 gen g`k' = rd == `k'
	}


eventstudyinteract n_cloudseeding g_* g0-g4, cohort(first_oper) control_cohort(never_protest) ///
 covariates(rainfall) absorb(i.adcode i.date) vce(cluster adcode)
 
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C
coefplot matrix(C[1]), se(C[2]) 

