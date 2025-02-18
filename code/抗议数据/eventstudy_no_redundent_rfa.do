use "D:\Git Local\CloudSeeding\code\抗议数据\temp_event.dta", clear

replace event = 0 if (event_id <.) & (event_id != num)
drop level_0 Unnamed__0 index n_prt_rfa to_day

* generate id variable
gen id_str = string(citycode) + string(num)
encode id_str, gen(id)
drop id_str

ren date date_str
gen date = date(date_str, "YMD")
drop date_str

gen protest_date = date if event == 1
bysort id (date): egen event_date = mean(protest_date)
bysort id (date): gen to_day = date - event_date
egen indi = max(event), by(id)
gen never_oper=(indi==0)
drop protest_date indi

* use the mean the previous three days to avoid reserve causality
forvalues i = 1(1)3{
	bys citycode num (date): gen rain_`i' = rainfall[_n-`i']
}
drop rainfall
gen rainfall = (rain_1 + rain_2 + rain_3)/3
replace rainfall =. if rain_1 ==. | rain_2 ==. | rain_3 ==. 
label var rainfall "rainfall"
drop rain_*

* generate event study variable
forvalues k = 7(-1)1{
	gen g_`k' = to_day == -`k'
}
forvalues k = 0/7{
	gen g`k' = to_day == `k'
}
replace g_1 = 0

* Declare panel data structure
drop if event_date == .

gen reserved = 0  // Create a variable to mark reserved observations

// Identify IDs where to_day == 0
gen mark = (to_day == 0)
levelsof date if mark, local(dates)

// Loop through each date and mark the range [-7, +7]
foreach d in `dates' {
    replace reserved = 1 if inrange(date, `d' - 7, `d' + 7)
}

// Keep only reserved observations
keep if reserved == 1

// Drop temporary variables
drop mark reserved




*reghdfe
reghdfe n_cloudseeding g_* g0-g7 rainfall, a(citycode date) vce(cluster citycode)
coefplot, keep(g_* g0 g1 g2 g3 g4 g5 g6 g7) vertical omitted xlabel(1 "≤ -7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "≥ 7", labsize(medsmall))  ///
xtitle("") ytitle("Estimated Coefficients", size(medsmall) margin(small)) ylabel(-0.01 "-0.01" 0 "0" 0.01 "0.01" , nogrid labsize(medsmall) angle(0)) ///
xline(8, lp(dash)) yscale(range(-0.03 0.03)) yline(0, lp(dash)) subtitle("weibo protests as events") scheme(s1mono)
graph export "2e.png", replace