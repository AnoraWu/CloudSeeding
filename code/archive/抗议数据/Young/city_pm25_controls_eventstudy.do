// =========================================================
// city_pm2.5 merged with controls: event study (no controls, control pop & ntl, all controls)
// =========================================================

clear all
set more off

macro def dir "D:/npp_env"
capture cd "$dir"

global reac_pth "$dir/reactors"
global coalpp_pth "$dir/coalpp"
global ctrl_pth "$dir/controls"
global dta_pth "$dir/dta"
global res_pth "$dir/reg_res/coalpp_env"
global res_pic "$dir/res_pic/coalpp_env/event study"
global summary "$dir/city_pm25_summary"

***NPP Operation on pm2.5***
use "$dta_pth/pm25_city.dta", clear
sort npp year
xtset npp year


/// controls
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
// global lst_control "lst_m lst_dif lst_daynight"


/// define time to treat
gen npp_year = year if npp_oper == 1
bys npp: egen first_oper = min(npp_year)
drop npp_year
gen ry = year - first_oper
gen never_oper = (first_oper == .)
gen lpm25_m_city = log(1+pm25_m_city)

replace ry = 5 if ry>=5 & ry!=. // bin the lead and
replace ry = -6 if ry<=-6

forvalues k = 6(-1)1{
	gen g_`k' = ry == -`k'
}
forvalues k = 0/5{
	gen g`k' = ry == `k'
}
replace g_1 = 0


/// event study
** unadjusted
* no controls
reghdfe pm25_m_city g_* g0-g5, a(i.npp i.year) vce(cluster npp)
coefplot, keep(g_* g0 g1 g2 g3 g4 g5) vertical omitted xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall))  ///
xtitle("") ytitle("Estimated Coefficients", size(medsmall) margin(small)) ylabel(-5 "-5" 0 "0" 5 "5" 10 "10", nogrid labsize(medsmall) angle(0)) ///
xline(6, lp(dash)) yscale(range(-5 10)) yline(0, lp(dash)) subtitle("NPP construction on PM2.5 (city-level)") scheme(s1mono)
graph export "$res_pic/city_PM25.png", replace

* control pop and ntl
reghdfe pm25_m_city pop_m_city ntl_m_city g_* g0-g5, a(i.npp i.year) vce(cluster npp)
coefplot, keep(g_* g0 g1 g2 g3 g4 g5) vertical omitted xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall))  ///
xtitle("") ytitle("Estimated Coefficients", size(medsmall) margin(small)) ylabel(-5 "-5" 0 "0" 5 "5" 10 "10", nogrid labsize(medsmall) angle(0)) ///
xline(6, lp(dash)) yscale(range(-5 10)) yline(0, lp(dash)) subtitle("NPP construction on PM2.5 (city-level, control pop & NTL)") scheme(s1mono)
graph export "$res_pic/city_PM25_pop_ntl.png", replace

* all controls
reghdfe pm25_m_city pop_m_city ntl_m_city $lst_control g_* g0-g5, a(i.npp i.year $geo_control $dpi_control) vce(cluster npp)
coefplot, keep(g_* g0 g1 g2 g3 g4 g5) vertical omitted xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall))  ///
xtitle("") ytitle("Estimated Coefficients", size(medsmall) margin(small)) ylabel(-5 "-5" 0 "0" 5 "5" 10 "10", nogrid labsize(medsmall) angle(0)) ///
xline(6, lp(dash)) yscale(range(-5 10)) yline(0, lp(dash)) subtitle("NPP construction on PM2.5 (city-level, all controls)") scheme(s1mono)
graph export "$res_pic/city_PM25_all_controls.png", replace


** sun adjusted
set matsize 800
* no controls
eventstudyinteract pm25_m_city g_* g0-g5, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year) vce(cluster npp)
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C
coefplot matrix(C[1]), se(C[2]) vertical  yline(0, lp(dash)) ylabel(-5 "-5" 0 "0" 5 "5" 10 "10", nogrid labsize(medsmall) angle(0)) ///
xline(6, lp(dash)) yscale(range(-5 10)) scheme(s1mono) ///
xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall)) ///
subtitle("NPP Construction on PM2.5 (city-level)") ytitle("Estimated Coefficients", size(medsmall) margin(small))
graph export "$res_pic/city_PM25_sun.png", replace

* control pop and ntl
eventstudyinteract pm25_m_city g_* g0-g5, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year) vce(cluster npp) covariates(pop_m_city ntl_m_city)
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C
coefplot matrix(C[1]), se(C[2]) vertical  yline(0, lp(dash)) ylabel(-5 "-5" 0 "0" 5 "5" 10 "10", nogrid labsize(medsmall) angle(0)) ///
xline(6, lp(dash)) yscale(range(-5 10)) scheme(s1mono) ///
xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall)) ///
subtitle("NPP Construction on PM2.5 (city-level, control pop & NTL, Sun)") ytitle("Estimated Coefficients", size(medsmall) margin(small))
graph export "$res_pic/city_PM25_pop_ntl_sun.png", replace

* all controls
eventstudyinteract pm25_m_city g_* g0-g5, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year $geo_control $dpi_control) vce(cluster npp) covariates(pop_m_city ntl_m_city $lst_control)
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C
coefplot matrix(C[1]), se(C[2]) vertical  yline(0, lp(dash)) ylabel(-5 "-5" 0 "0" 5 "5" 10 "10", nogrid labsize(medsmall) angle(0)) ///
xline(6, lp(dash)) yscale(range(-5 10)) scheme(s1mono) ///
xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall)) ///
subtitle("NPP Construction on PM2.5 (city-level, all controls, Sun)") ytitle("Estimated Coefficients", size(medsmall) margin(small))
graph export "$res_pic/city_PM25_all_controls_sun.png", replace


*********
** DID estimator
*********
** unadjusted
* no controls
reghdfe pm25_m_city npp_oper, a(i.npp i.year) vce(cluster npp)
estadd local pop_ntl "N", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store unadjusted_nocontrol

* control pop and ntl
reghdfe pm25_m_city npp_oper pop_m_city ntl_m_city, a(i.npp i.year) vce(cluster npp)
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store unadjusted_control

* all controls
reghdfe pm25_m_city npp_oper pop_m_city ntl_m_city $lst_control, a(i.npp i.year $geo_control $dpi_control) vce(cluster npp)
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "Y", replace
estadd local lbc_yfe "Y", replace
estadd local mt "Y", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store unadjusted_control2


** sun adjusted
* no controls
eventstudyinteract pm25_m_city npp_oper, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year) vce(cluster npp)
estadd local pop_ntl "N", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store adjusted_nocontrol

* control pop and ntl
eventstudyinteract pm25_m_city npp_oper, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year) vce(cluster npp) covariates(pop_m_city ntl_m_city)
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store adjusted_control

* all controls
eventstudyinteract pm25_m_city npp_oper, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year $geo_control $dpi_control) vce(cluster npp) covariates(pop_m_city ntl_m_city $lst_control)
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "Y", replace
estadd local lbc_yfe "Y", replace
estadd local mt "Y", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store adjusted_control2

local s "using $summary/city_pm25_reg_full.tex" 
local test "unadjusted_nocontrol unadjusted_control unadjusted_control2 adjusted_nocontrol adjusted_control adjusted_control2"
local mg "Controls_unadjusted Controls_adjusted"
local mt "(1) (2) (3) (1) (2) (3)"

esttab `test' `s', b(%6.3f) se(%6.3f) nogap compress  ///
	mtitle(`mt') nonumbers mgroup(`mg', pattern(1 0 0 1 0 0) span  ///
                prefix(\multicolumn{@span}{c}{) suffix(})  ///
                erepeat(\cmidrule(lr){@span}))  ///
                booktabs page(dcolumn) alignment(c)  ///
	note(Note: Robust standard errors in parentheses are clustered at the city level.) coef(_cons "Constant")  ///
	stats(pop_ntl dpi_yfe lbc_yfe mt city_fe year_fe N r2_a, fmt(%3s %3s %3s %3s %3s %3s %12.0f %9.3f) label("Lagged population/nighttime lights" "Other energy DPI $\times$ Year FE" "(Latitude, Border, Coast) $\times$ Year FE" "Mean temperature" "City FE" "Year FE" "Observations" "Adjusted {R}²"))  ///
	star(* 0.1 ** 0.05 *** 0.01)  ///
    keep(npp_oper) replace


	
	
	
	
	
	
	
	
	
	
	
	
	
	





///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//逐年trim5% + log
clear	
use "F:\dropbox\Dropbox\NPP_PM2.5\pm25_city.dta"

levelsof year, local(years)
foreach y of local years {
    winsor2 pm25_m_city if year == `y', cuts(0 95) trim replace
}


gen log_pm25_m_city = log(pm25_m_city)
sum log_pm25_m_city

global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
// global lst_control "lst_m lst_dif lst_daynight"


/// define time to treat
gen npp_year = year if npp_oper == 1
bys npp: egen first_oper = min(npp_year)
drop npp_year
gen ry = year - first_oper
gen never_oper = (first_oper == .)
gen lpm25_m_city = log(1+pm25_m_city)

replace ry = 5 if ry>=5 & ry!=. // bin the lead and
replace ry = -6 if ry<=-6

forvalues k = 6(-1)1{
	gen g_`k' = ry == -`k'
}
forvalues k = 0/5{
	gen g`k' = ry == `k'
}
replace g_1 = 0

reghdfe log_pm25_m_city pop_m_city ntl_m_city $lst_control g_* g0-g5, a(i.npp i.year $geo_control $dpi_control) vce(cluster npp)
coefplot, keep(g_* g0 g1 g2 g3 g4 g5) vertical omitted xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall))  ///
xtitle("") ytitle("Estimated Coefficients", size(medsmall) margin(small))  ///
xline(6, lp(dash)) yscale(range(-0.1 0.1)) yline(0, lp(dash)) subtitle("NPP construction on PM2.5 (city-level, control pop & NTL)") scheme(s1mono)


eventstudyinteract log_pm25_m_city g_* g0-g5, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year $geo_control $dpi_control) vce(cluster npp) covariates(pop_m_city ntl_m_city $lst_control)
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C

coefplot matrix(C[1]), se(C[2]) vertical  yline(0, lp(dash)) ylabel(-0.15 "-0.15" -0.1 "-0.1" -0.05 "-0.05" 0 "0" 0.05 "0.05" 0.1 "0.1" 0.15 "0.15", nogrid labsize(medsmall) angle(0)) ///
xline(6, lp(dash)) yscale(range(-0.15 0.15)) scheme(s1mono) ///
xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall)) ///
subtitle("NPP Construction on log(PM2.5) (city-level, all controls, Sun)") ytitle("Log(Estimated Coefficients)", size(medsmall) margin(small))

//Table10
*********
** DID estimator
*********
** unadjusted
* no controls
reghdfe log_pm25_m_city npp_oper, a(i.npp i.year) vce(cluster npp)
estadd local pop_ntl "N", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store unadjusted_nocontrol

* control pop and ntl
reghdfe log_pm25_m_city npp_oper pop_m_city ntl_m_city, a(i.npp i.year) vce(cluster npp)
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store unadjusted_control

* all controls
reghdfe log_pm25_m_city npp_oper pop_m_city ntl_m_city $lst_control, a(i.npp i.year $geo_control $dpi_control) vce(cluster npp)
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "Y", replace
estadd local lbc_yfe "Y", replace
estadd local mt "Y", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store unadjusted_control2


** sun adjusted
* no controls
eventstudyinteract log_pm25_m_city npp_oper, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year) vce(cluster npp)

* 提取系数和方差矩阵
matrix b = e(b_iw)
matrix V = e(V_iw)

* 使用 ereturn post 将结果存储为标准回归结果
ereturn post b V
estadd local pop_ntl "N", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store adjusted_nocontrol

* control pop and ntl
eventstudyinteract log_pm25_m_city npp_oper, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year) vce(cluster npp) covariates(pop_m_city ntl_m_city)

* 提取系数和方差矩阵
matrix b = e(b_iw)
matrix V = e(V_iw)

* 使用 ereturn post 将结果存储为标准回归结果
ereturn post b V
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store adjusted_control

* all controls
eventstudyinteract log_pm25_m_city npp_oper, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year $geo_control $dpi_control) vce(cluster npp) covariates(pop_m_city ntl_m_city $lst_control)

* 提取系数和方差矩阵
matrix b = e(b_iw)
matrix V = e(V_iw)

* 使用 ereturn post 将结果存储为标准回归结果
ereturn post b V
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "Y", replace
estadd local lbc_yfe "Y", replace
estadd local mt "Y", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store adjusted_control2


local s "using F:/dropbox/Dropbox/NPP_PM2.5/nuclearcity_pm25_reg_full.tex"
local test "unadjusted_nocontrol unadjusted_control unadjusted_control2 adjusted_nocontrol adjusted_control adjusted_control2"
local mg "Controls_unadjusted Controls_adjusted"
local mt "(1) (2) (3) (1) (2) (3)"

esttab `test' `s', b(%6.3f) se(%6.3f) nogap compress  ///
	mtitle(`mt') nonumbers mgroup(`mg', pattern(1 0 0 1 0 0) span  ///
                prefix(\multicolumn{@span}{c}{) suffix(})  ///
                erepeat(\cmidrule(lr){@span}))  ///
                booktabs page(dcolumn) alignment(c)  ///
	note(Note: Robust standard errors in parentheses are clustered at the city level.) coef(_cons "Constant")  ///
	stats(pop_ntl dpi_yfe lbc_yfe mt city_fe year_fe N r2_a, fmt(%3s %3s %3s %3s %3s %3s %12.0f %9.3f) label("Lagged population/nighttime lights" "Other energy DPI $\times$ Year FE" "(Latitude, Border, Coast) $\times$ Year FE" "Mean temperature" "City FE" "Year FE" "Observations" "Adjusted {R}²"))  ///
	star(* 0.1 ** 0.05 *** 0.01)  ///
    keep(npp_oper) replace

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//逐年trim5%
clear	
use "F:\dropbox\Dropbox\NPP_PM2.5\pm25_city.dta"

levelsof year, local(years)
foreach y of local years {
    winsor2 pm25_m_city if year == `y', cuts(0 95) trim replace
}


global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
// global lst_control "lst_m lst_dif lst_daynight"


/// define time to treat
gen npp_year = year if npp_oper == 1
bys npp: egen first_oper = min(npp_year)
drop npp_year
gen ry = year - first_oper
gen never_oper = (first_oper == .)
gen lpm25_m_city = log(1+pm25_m_city)

replace ry = 5 if ry>=5 & ry!=. // bin the lead and
replace ry = -6 if ry<=-6

forvalues k = 6(-1)1{
	gen g_`k' = ry == -`k'
}
forvalues k = 0/5{
	gen g`k' = ry == `k'
}
replace g_1 = 0

reghdfe pm25_m_city pop_m_city ntl_m_city $lst_control g_* g0-g5, a(i.npp i.year $geo_control $dpi_control) vce(cluster npp)
coefplot, keep(g_* g0 g1 g2 g3 g4 g5) vertical omitted xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall))  ///
xtitle("") ytitle("Estimated Coefficients", size(medsmall) margin(small))  ///
xline(6, lp(dash)) yscale(range(-0.1 0.1)) yline(0, lp(dash)) subtitle("NPP construction on PM2.5 (city-level, control pop & NTL)") scheme(s1mono)


eventstudyinteract pm25_m_city g_* g0-g5, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year $geo_control $dpi_control) vce(cluster npp) covariates(pop_m_city ntl_m_city $lst_control)
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C

coefplot matrix(C[1]), se(C[2]) vertical  yline(0, lp(dash)) ylabel(-0.15 "-0.15" -0.1 "-0.1" -0.05 "-0.05" 0 "0" 0.05 "0.05" 0.1 "0.1" 0.15 "0.15", nogrid labsize(medsmall) angle(0)) ///
xline(6, lp(dash)) yscale(range(-0.15 0.15)) scheme(s1mono) ///
xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall)) ///
subtitle("NPP Construction on log(PM2.5) (city-level, all controls, Sun)") ytitle("Log(Estimated Coefficients)", size(medsmall) margin(small))

//Table10
*********
** DID estimator
*********
** unadjusted
* no controls
reghdfe pm25_m_city npp_oper, a(i.npp i.year) vce(cluster npp)
estadd local pop_ntl "N", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store unadjusted_nocontrol

* control pop and ntl
reghdfe pm25_m_city npp_oper pop_m_city ntl_m_city, a(i.npp i.year) vce(cluster npp)
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store unadjusted_control

* all controls
reghdfe pm25_m_city npp_oper pop_m_city ntl_m_city $lst_control, a(i.npp i.year $geo_control $dpi_control) vce(cluster npp)
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "Y", replace
estadd local lbc_yfe "Y", replace
estadd local mt "Y", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store unadjusted_control2


** sun adjusted
* no controls
eventstudyinteract pm25_m_city npp_oper, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year) vce(cluster npp)

* 提取系数和方差矩阵
matrix b = e(b_iw)
matrix V = e(V_iw)

* 使用 ereturn post 将结果存储为标准回归结果
ereturn post b V
estadd local pop_ntl "N", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store adjusted_nocontrol

* control pop and ntl
eventstudyinteract pm25_m_city npp_oper, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year) vce(cluster npp) covariates(pop_m_city ntl_m_city)

* 提取系数和方差矩阵
matrix b = e(b_iw)
matrix V = e(V_iw)

* 使用 ereturn post 将结果存储为标准回归结果
ereturn post b V
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "N", replace
estadd local lbc_yfe "N", replace
estadd local mt "N", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store adjusted_control

* all controls
eventstudyinteract pm25_m_city npp_oper, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year $geo_control $dpi_control) vce(cluster npp) covariates(pop_m_city ntl_m_city $lst_control)

* 提取系数和方差矩阵
matrix b = e(b_iw)
matrix V = e(V_iw)

* 使用 ereturn post 将结果存储为标准回归结果
ereturn post b V
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "Y", replace
estadd local lbc_yfe "Y", replace
estadd local mt "Y", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store adjusted_control2


local s "using F:/dropbox/Dropbox/NPP_PM2.5/nuclearcity_pm25_reg_full.tex"
local test "unadjusted_nocontrol unadjusted_control unadjusted_control2 adjusted_nocontrol adjusted_control adjusted_control2"
local mg "Controls_unadjusted Controls_adjusted"
local mt "(1) (2) (3) (1) (2) (3)"

esttab `test' `s', b(%6.3f) se(%6.3f) nogap compress  ///
	mtitle(`mt') nonumbers mgroup(`mg', pattern(1 0 0 1 0 0) span  ///
                prefix(\multicolumn{@span}{c}{) suffix(})  ///
                erepeat(\cmidrule(lr){@span}))  ///
                booktabs page(dcolumn) alignment(c)  ///
	note(Note: Robust standard errors in parentheses are clustered at the city level.) coef(_cons "Constant")  ///
	stats(pop_ntl dpi_yfe lbc_yfe mt city_fe year_fe N r2_a, fmt(%3s %3s %3s %3s %3s %3s %12.0f %9.3f) label("Lagged population/nighttime lights" "Other energy DPI $\times$ Year FE" "(Latitude, Border, Coast) $\times$ Year FE" "Mean temperature" "City FE" "Year FE" "Observations" "Adjusted {R}²"))  ///
	star(* 0.1 ** 0.05 *** 0.01)  ///
    keep(npp_oper) replace


	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
clear	
use "F:\dropbox\Dropbox\NPP_PM2.5\pm25_city.dta"

levelsof year, local(years)
foreach y of local years {
    winsor2 pm25_m_city if year == `y', cuts(0 95) trim replace
}

global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
// global lst_control "lst_m lst_dif lst_daynight"


reghdfe pm25_m_city number_or pop_m_city ntl_m_city $lst_control, a(i.npp i.year $geo_control $dpi_control) vce(cluster npp)
estadd local pop_ntl "Y", replace
estadd local dpi_yfe "Y", replace
estadd local lbc_yfe "Y", replace
estadd local mt "Y", replace
estadd local city_fe "Y", replace
estadd local year_fe "Y", replace
est store unadjusted_control2



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Zhenyu_data
clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"

global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///AOD
//DID
//city_fe
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//npp_oper + city_fe
clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
reghdfe aod_modis_m_city npp_oper, a(city_n i.year) vce(cluster city_n)
estat summarize

reghdfe aod_modis_m_city npp_oper pop_m_city ntl_m_city, a(city_n i.year $geo_control) vce(cluster city_n)
estat summarize

drop if country == "China"
reghdfe aod_modis_m_city npp_oper pop_m_city ntl_m_city, a(city_n i.year $geo_control) vce(cluster city_n)
estat summarize

clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "Russia"
reghdfe aod_modis_m_city npp_oper pop_m_city ntl_m_city, a(city_n i.year $geo_control) vce(cluster city_n)
estat summarize

clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "United States"
reghdfe aod_modis_m_city npp_oper pop_m_city ntl_m_city, a(city_n i.year $geo_control) vce(cluster city_n)
estat summarize

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//n_oper + city_fe
clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
reghdfe aod_modis_m_city n_oper, a(city_n i.year) vce(cluster city_n)
estat summarize

reghdfe aod_modis_m_city n_oper pop_m_city ntl_m_city $lst_control, a(city_n i.year $geo_control $dpi_control) vce(cluster city_n)
estat summarize


drop if country == "China"
reghdfe aod_modis_m_city n_oper pop_m_city ntl_m_city $lst_control, a(city_n i.year $geo_control $dpi_control) vce(cluster city_n)
estat summarize


clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "Russia"
reghdfe aod_modis_m_city n_oper pop_m_city ntl_m_city $lst_control, a(city_n i.year $geo_control $dpi_control) vce(cluster city_n)
estat summarize


clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "United States"
reghdfe aod_modis_m_city n_oper pop_m_city ntl_m_city $lst_control, a(city_n i.year $geo_control $dpi_control) vce(cluster city_n)
estat summarize

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//npp_fe
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//npp_oper + npp_fe
clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"

egen npp = group(country province city)
sort npp

egen max_npp = max(n_oper), by(npp)
replace npp = . if max_npp == 0

reghdfe aod_modis_m_city npp_oper, a(i.npp i.year) vce(cluster npp)
estat summarize

reghdfe aod_modis_m_city npp_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize

drop if country == "China"
reghdfe aod_modis_m_city npp_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize

clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
egen npp = group(country province city)
sort npp
egen max_npp = max(n_oper), by(npp)
replace npp = . if max_npp == 0
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "Russia"
reghdfe aod_modis_m_city npp_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize

clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
egen npp = group(country province city)
sort npp
egen max_npp = max(n_oper), by(npp)
replace npp = . if max_npp == 0
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "United States"
reghdfe aod_modis_m_city npp_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//n_oper + npp_fe
clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
egen npp = group(country province city)
sort npp
egen max_npp = max(n_oper), by(npp)
replace npp = . if max_npp == 0

global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
reghdfe aod_modis_m_city n_oper, a(i.npp i.year) vce(cluster npp)
estat summarize

reghdfe aod_modis_m_city n_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize

drop if country == "China"
reghdfe aod_modis_m_city n_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize

clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
egen npp = group(country province city)
sort npp
egen max_npp = max(n_oper), by(npp)
replace npp = . if max_npp == 0
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "Russia"
reghdfe aod_modis_m_city n_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize

clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
egen npp = group(country province city)
sort npp
egen max_npp = max(n_oper), by(npp)
replace npp = . if max_npp == 0
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "United States"
reghdfe aod_modis_m_city n_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///pm2.5
//DID
//city_fe
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//npp_oper + city_fe
clear	
use "F:\dropbox\Dropbox\NPP_PM2.5\pm25_city.dta"

levelsof year, local(years)
foreach y of local years {
    winsor2 pm25_m_city if year == `y', cuts(0 95) trim replace
}

global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
reghdfe pm25_m_city npp_oper, a(i.npp i.year) vce(cluster npp)
estat summarize

reghdfe pm25_m_city npp_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize

drop if country == "China"
reghdfe pm25_m_city npp_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize


clear	
use "F:\dropbox\Dropbox\NPP_PM2.5\pm25_city.dta"
levelsof year, local(years)
foreach y of local years {
    winsor2 pm25_m_city if year == `y', cuts(0 95) trim replace
}
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "Russia"
reghdfe pm25_m_city npp_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize

clear	
use "F:\dropbox\Dropbox\NPP_PM2.5\pm25_city.dta"
levelsof year, local(years)
foreach y of local years {
    winsor2 pm25_m_city if year == `y', cuts(0 95) trim replace
}
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "United States"
reghdfe pm25_m_city npp_oper pop_m_city ntl_m_city, a(i.npp i.year $geo_control) vce(cluster npp)
estat summarize

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//n_oper + city_fe
clear	
use "F:\dropbox\Dropbox\NPP_PM2.5\pm25_city.dta"
levelsof year, local(years)
foreach y of local years {
    winsor2 pm25_m_city if year == `y', cuts(0 95) trim replace
}
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
reghdfe pm25_m_city n_oper, a(i.npp i.year) vce(cluster npp)
estat summarize

reghdfe pm25_m_city n_oper pop_m_city ntl_m_city $lst_control, a(i.npp i.year $geo_control $dpi_control) vce(cluster npp)
estat summarize


drop if country == "China"
reghdfe pm25_m_city n_oper pop_m_city ntl_m_city $lst_control, a(i.npp i.year $geo_control $dpi_control) vce(cluster npp)
estat summarize


clear	
use "F:\dropbox\Dropbox\NPP_PM2.5\pm25_city.dta"
levelsof year, local(years)
foreach y of local years {
    winsor2 pm25_m_city if year == `y', cuts(0 95) trim replace
}
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "Russia"
reghdfe pm25_m_city n_oper pop_m_city ntl_m_city $lst_control, a(i.npp i.year $geo_control $dpi_control) vce(cluster npp)
estat summarize


clear	
use "F:\dropbox\Dropbox\NPP_PM2.5\pm25_city.dta"
levelsof year, local(years)
foreach y of local years {
    winsor2 pm25_m_city if year == `y', cuts(0 95) trim replace
}
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"
drop if country == "United States"
reghdfe pm25_m_city n_oper pop_m_city ntl_m_city $lst_control, a(i.npp i.year $geo_control $dpi_control) vce(cluster npp)
estat summarize

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//aod
//Eventstudy
//npp_oper + npp_fe
clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"

egen npp = group(country province city)
sort npp
egen max_npp = max(n_oper), by(npp)
replace npp = . if max_npp == 0

gen npp_year = year if npp_oper == 1
bys npp: egen first_oper = min(npp_year)
drop npp_year
gen ry = year - first_oper
gen never_oper = (first_oper == .)

replace ry = 5 if ry>=5 & ry!=. // bin the lead and
replace ry = -6 if ry<=-6

forvalues k = 6(-1)1{
	gen g_`k' = ry == -`k'
}
forvalues k = 0/5{
	gen g`k' = ry == `k'
}
replace g_1 = 0

eventstudyinteract aod_modis_m_city g_* g0-g5, cohort(first_oper) control_cohort(never_oper) absorb(i.npp i.year $geo_control) vce(cluster npp) covariates(pop_m_city ntl_m_city)
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C
coefplot matrix(C[1]), se(C[2]) vertical  yline(0, lp(dash)) ylabel(-5 "-5" 0 "0" 5 "5" 10 "10", nogrid labsize(medsmall) angle(0)) ///
xline(6, lp(dash)) yscale(range(-5 10)) scheme(s1mono) ///
xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall)) ///
subtitle("NPP Construction on PM2.5 (city-level, all controls, Sun)") ytitle("Estimated Coefficients", size(medsmall) margin(small))
graph export "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\aod_nppfe_sun.png", replace

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//npp_oper + city_fe
clear
use "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\city_merged.dta"
global dpi_control "c.hydro_city#year c.csp_city#year c.pv_city#year c.convoil_city#year c.convgas_city#year c.coal_city#year c.wind_city#year"
global geo_control "c.lat#year border#year coast#year"
global lst_control "lst_m"

egen npp = group(country province city)
sort npp
egen max_npp = max(n_oper), by(npp)
replace npp = . if max_npp == 0

gen npp_year = year if npp_oper == 1
bys npp: egen first_oper = min(npp_year)
drop npp_year
gen ry = year - first_oper
gen never_oper = (first_oper == .)

replace ry = 5 if ry>=5 & ry!=. // bin the lead and
replace ry = -6 if ry<=-6

forvalues k = 6(-1)1 {
    gen g_`k' = ry == -`k'
}
forvalues k = 0/5 {
    gen g`k' = ry == `k'
}
replace g_1 = 0

eventstudyinteract aod_modis_m_city g_* g0-g5, cohort(first_oper) control_cohort(never_oper) absorb(i.city_n i.year $geo_control) vce(cluster city_n) covariates(pop_m_city ntl_m_city)
matrix C = e(b_iw)
mata st_matrix("A", sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C

coefplot matrix(C[1]), se(C[2]) vertical ///
    yline(0, lp(dash) lcolor(gs10)) yline(40, lp(dash) lcolor(gs14)) ///
    yline(-40, lp(dash) lcolor(gs14)) yline(-80, lp(dash) lcolor(gs14)) yline(-120, lp(dash) lcolor(gs14)) /// 
    ylabel(-120 "-120" -80 "-80" -40 "-40" 0 "0" 40 "40", nogrid labsize(medsmall) angle(0)) /// y轴刻度调整
    xline(6, lp(dash)) yscale(range(-120 40)) scheme(s1mono) ///
    xlabel(1 "≤ -6" 2 "-5" 3 "-4" 4 "-3" 5 "-2" 6 "-1" 7 "0" 8 "1" 9 "2" 10 "3" 11 "4" 12 "≥ 5", labsize(medsmall)) ///
    subtitle("NPP Construction on AOD", size(medium)) ///
    ytitle("Coefficients", size(medium) margin(small)) ///
    legend(label(1 "Year FE & City FE") rows(1) order(1) size(small)) /// 将图例的字体大小调小一号

graph export "F:\dropbox\Dropbox\Predoc_Project\核能\data_zhenyu\aod_cityfe_sun.png", replace
































































