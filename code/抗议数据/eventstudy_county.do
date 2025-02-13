
* input dir
cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"

use "final_panel_newweibo.dta",clear

drop size*


********************************************************
***************** county level event study *************
********************************************************

label var n_cloudseeding "num of cloudseeding"
label var n_prt_weibo "number of protests from weibo"
label var n_prt_rfa   "number of protests from rfa"
label var size_rfa "size of rfa protests"
label var size_weibo "size of weibo protests"
label var size_original_weibo "size of weibo protests (original)"
label var size_original_rfa "size of rfa protests (original)"
label var rainfall "rainfall"

****************** use weibo as event ******************

/*
df = pd.read_stata("final_panel_newweibo.dta")
df = df.sort_values(by=['adcode', 'date']).reset_index()
df["day"] = df.groupby("adcode").cumcount()
df['event'] = 0

# Identify events (first protest and subsequent protests >= 3 months apart)
for ad, ad_df in df.groupby('adcode'):
    protest_dates = ad_df.loc[ad_df['n_prt_weibo'] > 0, 'day'].sort_values().tolist()
    last_event = None
    
    for protest_date in protest_dates:
        if last_event is None or (protest_date - last_event) >= 45:
            df.loc[(df['adcode'] == int(ad)) & (df['day'] == protest_date),'event'] = 1
            last_event = protest_date

index_list = df.loc[df['event']==1,'index'].tolist()
df['to_day']=None
for index in index_list:
    for i in range(-22,24):
        if not (index+i<0) or (index+i>len(df)):
            df.loc[df['index']==index+i,'to_day'] = i

df.to_csv('eventstudy_county_weibo.csv')
*/

// preserve
//
// import delimited "eventstudy_county_weibo.csv", clear 
//
// * regenerate date variable
// gen date_stata = date(date, "YMD")
// format date_stata %td
// drop date
// ren date_stata date_stata
//
// * set the bins
// replace to_day = 7 if to_day>=7 & to_day!=. 
// replace to_day = -7 if to_day<=-7
//
// * generate event study variable
// forvalues k = 7(-1)1{
// 	gen g_`k' = to_day == -`k'
// }
// forvalues k = 0/7{
// 	gen g`k' = to_day == `k'
// }
// replace g_1 = 0
//
// gen cohort = date if event == 1
// egen indi = max(event), by(adcode)
// gen never_oper=(indi==0)
//
// *reghdfe
// reghdfe n_cloudseeding g_* g0-g7 rainfall, a(i.adcode i.date) vce(cluster adcode)
// coefplot, keep(g_* g0 g1 g2 g3 g4 g5 g6 g7) vertical omitted xlabel(1 "≤ -7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "≥ 7", labsize(medsmall))  ///
// xtitle("") ytitle("Estimated Coefficients", size(medsmall) margin(small)) ylabel(-0.1 "-0.1" 0 "0" 0.1 "0.1" , nogrid labsize(medsmall) angle(0)) ///
// xline(6, lp(dash)) yscale(range(-0.3 0.3)) yline(0, lp(dash)) subtitle("weibo protests as events") scheme(s1mono)
// graph export "5e.png", replace
//
// *ppmlhdfe
// ppmlhdfe n_cloudseeding g_* g0-g7 rainfall, a(i.adcode i.date) vce(cluster adcode)
// coefplot, keep(g_* g0 g1 g2 g3 g4 g5 g6 g7) vertical omitted xlabel(1 "≤ -7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "≥ 7", labsize(medsmall))  ///
// xtitle("") ytitle("Estimated Coefficients", size(medsmall) margin(small)) ylabel(-0.1 "-0.1" 0 "0" 0.1 "0.1" , nogrid labsize(medsmall) angle(0)) ///
// xline(6, lp(dash)) yscale(range(-0.3 0.3)) yline(0, lp(dash)) subtitle("weibo protests as events") scheme(s1mono)
// graph export "5d.png", replace
//
// *eventstudyinteract
// gen randnum = runiform()
// bysort adcode (randnum): replace randnum = randnum[_N]  
// egen rank = rank(randnum), unique
// sum rank
// keep if rank <= r(max) / 3
// drop randnum rank
//
// eventstudyinteract n_cloudseeding g_* g0-g7 rainfall, cohort(cohort) control_cohort(never_oper) ///
//  covariates(rainfall) absorb(i.adcode i.date) vce(cluster adcode)
// 
// matrix C = e(b_iw)
// mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
// matrix C = C \ A'
// matrix list C
// coefplot matrix(C[1]), se(C[2]) 
// graph export "5f.png", replace
//
// restore
//
//
//
// ****************** use rfa as event ******************
//
// /*
// df = pd.read_stata("final_panel_newweibo.dta")
// df = df.sort_values(by=['adcode', 'date']).reset_index()
// df["day"] = df.groupby("adcode").cumcount()
// df['event'] = 0
//
// # Identify events (first protest and subsequent protests >= 3 months apart)
// for ad, ad_df in df.groupby('adcode'):
//     protest_dates = ad_df.loc[ad_df['n_prt_rfa'] > 0, 'day'].sort_values().tolist()
//     last_event = None
//    
//     for protest_date in protest_dates:
//         if last_event is None or (protest_date - last_event) >= 45:
//             df.loc[(df['adcode'] == int(ad)) & (df['day'] == protest_date),'event'] = 1
//             last_event = protest_date
//
// index_list = df.loc[df['event']==1,'index'].tolist()
// df['to_day']=None
// for index in index_list:
//     for i in range(-22,24):
//         if not (index+i<0) or (index+i>len(df)):
//             df.loc[df['index']==index+i,'to_day'] = i
//
// df.to_csv('eventstudy_county_rfa.csv')
// */
//
// preserve
//
// import delimited "eventstudy_county_rfa.csv", clear 
//
// * regenerate date variable
// gen date_stata = date(date, "YMD")
// format date_stata %td
// drop date
// ren date_stata date_stata
//
// * set the bins
// replace to_day = 7 if to_day>=7 & to_day!=. 
// replace to_day = -7 if to_day<=-7
//
// * generate event study variable
// forvalues k = 7(-1)1{
// 	gen g_`k' = to_day == -`k'
// }
// forvalues k = 0/7{
// 	gen g`k' = to_day == `k'
// }
// replace g_1 = 0
//
// gen cohort = date if event == 1
// egen indi = max(event), by(citycode)
// gen never_oper=(indi==0)
//
// *reghdfe
// reghdfe n_cloudseeding g_* g0-g7 rainfall, a(i.adcode i.date) vce(cluster adcode)
// coefplot, keep(g_* g0 g1 g2 g3 g4 g5 g6 g7) vertical omitted xlabel(1 "≤ -7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "≥ 7", labsize(medsmall))  ///
// xtitle("") ytitle("Estimated Coefficients", size(medsmall) margin(small)) ylabel(-0.1 "-0.1" 0 "0" 0.1 "0.1" , nogrid labsize(medsmall) angle(0)) ///
// xline(6, lp(dash)) yscale(range(-0.3 0.3)) yline(0, lp(dash)) subtitle("weibo protests as events") scheme(s1mono)
// graph export "5h.png", replace
//
// *ppmlhdfe
// ppmlhdfe n_cloudseeding g_* g0-g7 rainfall, a(i.adcode i.date) vce(cluster adcode)
// coefplot, keep(g_* g0 g1 g2 g3 g4 g5 g6 g7) vertical omitted xlabel(1 "≤ -7" 2 "-6" 3 "-5" 4 "-4" 5 "-3" 6 "-2" 7 "-1" 8 "0" 9 "1" 10 "2" 11 "3" 12 "4" 13 "5" 14 "6" 15 "≥ 7", labsize(medsmall))  ///
// xtitle("") ytitle("Estimated Coefficients", size(medsmall) margin(small)) ylabel(-0.1 "-0.1" 0 "0" 0.1 "0.1" , nogrid labsize(medsmall) angle(0)) ///
// xline(6, lp(dash)) yscale(range(-0.3 0.3)) yline(0, lp(dash)) subtitle("weibo protests as events") scheme(s1mono)
// graph export "5g.png", replace
//
// *eventstudyinteract
// gen randnum = runiform()
// bysort adcode (randnum): replace randnum = randnum[_N]  
// egen rank = rank(randnum), unique
// sum rank
// keep if rank <= r(max) / 3
// drop randnum rank
//
// eventstudyinteract n_cloudseeding g_* g0-g7 rainfall, cohort(cohort) control_cohort(never_oper) ///
//  covariates(rainfall) absorb(i.adcode i.date) vce(cluster adcode)
// 
// matrix C = e(b_iw)
// mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
// matrix C = C \ A'
// matrix list C
// coefplot matrix(C[1]), se(C[2]) 
// graph export "5i.png", replace
// restore
//
//
//
//
