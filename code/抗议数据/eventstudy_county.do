
* input dir
cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"

use "final_panel_newweibo.dta",clear

drop size*


********************************************************
***************** city level event study ***************
********************************************************

* collapse to city level

* replace rainfall as missing if all counties within a city has missing rainfall data
bysort citycode date: egen mnrainfall = mean(rainfall) 
replace rainfall = -999999999  if(mnrainfall == .) 

collapse (sum) n_cloudseeding n_prt_rfa n_prt_weibo rainfall, by (citycode date)

replace rainfall =. if rainfall < 0

label var n_cloudseeding "num of cloudseeding"
label var n_prt_weibo "number of protests from weibo"
label var n_prt_rfa   "number of protests from rfa"
label var rainfall "rainfall"

save "eventstudy_city.dta", replace

****************** use weibo as event ******************

/*
df = pd.read_stata("eventstudy_city.dta")
df = df.sort_values(by=['citycode', 'date']).reset_index()
df["day"] = df.groupby("citycode").cumcount()
df['event'] = 0

# Identify events (first protest and subsequent protests >= 3 months apart)
for city, city_df in df.groupby('citycode'):
    protest_dates = city_df.loc[city_df['n_prt_weibo'] > 0, 'day'].sort_values().tolist()
    last_event = None
    
    for protest_date in protest_dates:
        if last_event is None or (protest_date - last_event) >= 45:
            df.loc[(df['citycode'] == int(city)) & (df['day'] == protest_date),'event'] = 1
            last_event = protest_date

index_list = df.loc[df['event']==1,'index'].tolist()
df['to_day']=None
for index in index_list:
    for i in range(-22,24):
        if not (index+i<0) or (index+i>len(df)):
            df.loc[df['index']==index+i,'to_day'] = i

df.to_csv('eventstudy_weibo_city.csv')
*/


import delimited "eventstudy_weibo_city.csv", clear 

* regenerate date variable
gen date_stata = date(date, "YMD")
format date_stata %td
drop date
ren date_stata date

xtset citycode date


* generate event study variable
forvalues k = 12(-1)1{
	gen g_`k' = to_day == -`k'
}
forvalues k = 0/12{
	gen g`k' = to_day == `k'
}
replace g_1 = 0

gen protest_date = date if event == 1 
bysort citycode: egen cohort = min(protest_date)
egen indi = max(event), by(citycode)
gen never_oper=(indi==0)

* use the mean the previous three days to avoid reserve causality
forvalues i = 1(1)3{
	bys citycode (date): gen rain_`i' = L`i'.rainfall
}
drop rainfall
gen rainfall = (rain_1 + rain_2 + rain_3)/3
label var rainfall "rainfall"
drop rain_*



*eventstudyinteract
set seed 123456
bysort citycode: gen u = runiform()
bys citycode (date): gen uu = u[1]
keep if uu < .1 | never_oper == 1
drop u uu

** sun adjusted
eventstudyinteract n_cloudseeding g_* g0-g12 rainfall, cohort(cohort) control_cohort(never_oper) ///
 covariates(rainfall) absorb(i.citycode i.date) vce(cluster citycode)

matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C


coefplot matrix(C[1]), se(C[2]) keep(g_* g0 g1 g2 g3 g4 g5 g6 g7 g8 g9 g10 g11 g12) vertical omitted xlabel(1 "-12" 2 "-11" 3 "-10" 4 "-9" 5 "-8" 6 "-7" 7 "-6" 8 "-5" 9 "-4" 10 "-3" 11 "-2" 12 "-1" 13 "0" 14 "1" 15 "2" 16 "3" 17 "4" 19 "6" 21 "8" 23 "10" 25 "12", labsize(medsmall))  ///
xtitle("") ytitle("Estimated Coefficients", size(medsmall) margin(small)) ylabel(-0.01 "-0.01" 0 "0" 0.01 "0.01" , nogrid labsize(medsmall) angle(0)) ///
xline(7.5, lp(dash)) yscale(range(-0.02 0.02)) yline(0, lp(dash)) subtitle("weibo protests as events") scheme(s1mono)
graph export "2f.png", replace


