cd "/Users/anorawu/Documents/GitHub/CloudSeeding/data/气象局数据/人工处理"
use "final_data_allv.dta",replace

tempfile final_data_allv
save `final_data_allv'

import delimited "final_result.csv", clear 
drop v1 date village town
ren province prov
ren district county
ren year operation_year
ren month operation_month
ren day operation_day

append using `final_data_allv'

keep operation_year operation_month operation_day prov city county
duplicates drop


save "merged_气象局_微博.dta",replace

append using "test1.dta"

gen operation_date_2 = mdy(operation_month,operation_day,operation_year)
replace operation_date=operation_date_2 if operation_date==.

replace Year = operation_year if Year ==.
replace Mon = operation_month if Mon ==.
replace Day = operation_day if Day ==.
drop operation_date_2

save "merged_气象局_微博_天气.dta",replace
