* input dir
cd "/Users/anorawu/Team MG Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"
import delimited "eventstudy_weibo_city.csv", clear 

* regenerate date variable
gen date_stata = date(date, "YMD")
format date_stata %td
drop date
ren date_stata date

xtset citycode date

* set the bins
replace to_day = . if to_day > 10 & to_day!=. 
replace to_day = . if to_day< -7


* generate event study variable
forvalues k = 7(-1)1{
	gen g_`k' = to_day == -`k'
}
forvalues k = 0/10{
	gen g`k' = to_day == `k'
}
replace g_1 = 0


* use the mean the previous three days to avoid reserve causality
forvalues i = 1(1)3{
	bys citycode (date): gen rain_`i' = L`i'.rainfall
}
drop rainfall
gen rainfall = (rain_1 + rain_2 + rain_3)/3
label var rainfall "rainfall"
drop rain_*

*reghdfe
reghdfe n_cloudseeding g_* g0-g10 rainfall, a(i.citycode i.date) vce(cluster citycode)

coefplot, keep(g_* g0 g1 g2 g3 g4 g5 g6 g7 g8 g9 g10) vertical omitted xlabel(1 "-7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "7" 16 "8" 17 "9" 18 "10", labsize(medsmall))  ///
xtitle("") ytitle("Protest", size(medsmall) margin(small)) ///
xline(7.5, lc(cranberry)) yscale(range(-0.02 0.02)) yline(0) subtitle("Cloud Seeding & Protests") scheme(stcolor)
graph export "F:\dropbox\Dropbox\Cloud Seeding\data\tem\protest\protest.jpg", replace

