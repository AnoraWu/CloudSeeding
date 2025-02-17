
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

df = pd.read_csv('eventstudy_weibo_city.csv')

# Identify unique events and assign an event ID 
df_list = []
for city, city_df in df.groupby('citycode'):
    city_df['event_id'] = (city_df['event'] == 1).cumsum()
    city_df.loc[df['event'] == 0, 'event_id'] = None   
    num = city_df['event_id'].max()

    if math.isnan(num):
        city_df['num'] = 0
        df_list.append(city_df)
    else:
        for i in range(0,int(num)):
            city_df_temp = city_df.copy()
            city_df_temp['num'] = i+1
            df_list.append(city_df_temp)

df_final = pd.concat(df_list)
df_final.to_stata('temp_event.dta')
*/


clear all
set maxvar 100000

cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"
use "temp_event.dta",clear

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

* drop redundent data
keep if missing(to_day) | inrange(to_day, -7, 7)

* generate event study variable
forvalues k = 7(-1)1{
	gen g_`k' = to_day == -`k'
}
forvalues k = 0/7{
	gen g`k' = to_day == `k'
}
replace g_1 = 0

save "eventstudy_data.dta", replace

* event study
eventstudyinteract n_cloudseeding g_* g0-g7 rainfall, cohort(event_date) control_cohort(never_oper) ///
 covariates(rainfall) absorb(citycode date) vce(cluster citycode)

