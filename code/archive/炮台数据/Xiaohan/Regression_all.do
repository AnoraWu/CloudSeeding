use "E:\MERGE\MERGEall1201.dta",clear

******生成前7天平均值

rangestat (sum) pre_station (count) pre_station, interval(operation_date -7 -1) by(prov city county)
gen preci_7mean = pre_station_sum / pre_station_count if pre_station_count > 0

drop pre_station_sum pre_station_count
rangestat (sum) pre_station (count) pre_station, interval(operation_date -3 -1) by(prov city county)
gen preci_3mean = pre_station_sum / pre_station_count if pre_station_count > 0

rangestat (sum) thickness (count) thickness, interval(operation_date -7 -1) by(prov city county)
gen thickness_7mean = thickness_sum / thickness_count if thickness_count > 0

rangestat (sum) velocity (count) velocity, interval(operation_date -7 -1) by(prov city county)
gen velocity_7mean = velocity_sum / velocity_count if velocity_count > 0

rangestat (sum) tem (count) tem, interval(operation_date -7 -1) by(prov city county)
gen tem_avg_7mean = tem_sum / tem_count if tem_count > 0

rangestat (sum) evp (count) evp, interval(operation_date -7 -1) by(prov city county)
gen evp_7mean = evp_sum / evp_count if evp_count > 0

rangestat (sum) win_2mi (count) win_2mi, interval(operation_date -7 -1) by(prov city county)
gen win_2mi_7mean = win_2mi_sum / win_2mi_count if win_2mi_count > 0

rangestat (sum) air_fraction_mean (count) air_fraction_mean, interval(operation_date -7 -1) by(prov city county)
gen air_7mean = air_fraction_mean / air_fraction_mean if air_fraction_mean > 0

rangestat (sum) fraction (count) fraction, interval(operation_date -7 -1) by(prov city county)
gen fraction_7mean = fraction / fraction if fraction > 0


encode county, gen(county1)
encode city, gen(city1)


************Regression: cloud seeding event

***d_指的是今天和昨天 该变量的差值
*下面的回归我之前还做过气象变量和降水交互的版本

reghdfe imply thickness d_thickness fraction d_fraction velocity d_velocity air_fraction_mean d_air avg_preci_7d, absorb(county1 operation_date) vce(cluster city1)

reghdfe imply thickness d_thickness fraction d_fraction velocity d_velocity air_fraction_mean d_air avg_preci_7d, absorb(county1 day_of_year) vce(cluster city1)




************规定区县类别
bysort location: egen total_imply = total(imply)
tab total_imply

gen county_imply1 = 1 if total_imply >=1  // 约80%的数据
replace county_imply1=0 if county_imply1==.

gen county_imply2 = 1 if total_imply >=3  // 约60%的数据
replace county_imply2=0 if county_imply2==.

gen county_imply3 = 1 if total_imply >=5 // 约45%的数据
replace county_imply3=0 if county_imply3==.

gen county_imply4 = 1 if total_imply >=10 // 约25%的数据
replace county_imply4=0 if county_imply4==.






************rainfall
*******气象站降水
*气象变量和区县类别交互
reghdfe pre_station thickness c.thickness#1.county_imply1 velocity c.velocity#1.county_imply1 air_fraction_mean c.air_fraction_mean#1.county_imply1 fraction c.fraction#1.county_imply1, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station1-1.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(precipitation) addtext(county FE, YES, date FE, YES)


reghdfe pre_station thickness c.thickness#1.county_imply2 velocity c.velocity#1.county_imply2 air_fraction_mean c.air_fraction_mean#1.county_imply2 fraction c.fraction#1.county_imply2, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station1-2.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(precipitation) addtext(county FE, YES, date FE, YES)


reghdfe pre_station thickness c.thickness#1.county_imply3 velocity c.velocity#1.county_imply3 air_fraction_mean c.air_fraction_mean#1.county_imply3 fraction c.fraction#1.county_imply3, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station1-3.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(precipitation) addtext(county FE, YES, date FE, YES)


reghdfe pre_station thickness c.thickness#1.county_imply4 velocity c.velocity#1.county_imply4 air_fraction_mean c.air_fraction_mean#1.county_imply4 fraction c.fraction#1.county_imply4, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station1-4.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(precipitation) addtext(county FE, YES, date FE, YES)

*加上所有可能的来自气象站的变量
reghdfe pre_station thickness c.thickness#1.county_imply1 velocity 1.county_imply1#c.velocity fraction 1.county_imply1#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station1-5.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)


reghdfe pre_station thickness c.thickness#1.county_imply2 velocity 1.county_imply2#c.velocity fraction 1.county_imply2#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station1-6.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(precipitation) addtext(county FE, YES, date FE, YES)


reghdfe pre_station thickness c.thickness#1.county_imply3 velocity 1.county_imply3#c.velocity fraction 1.county_imply3#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station1-7.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(precipitation) addtext(county FE, YES, date FE, YES)

reghdfe pre_station thickness c.thickness#1.county_imply4 velocity 1.county_imply4#c.velocity fraction 1.county_imply4#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station1-8.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(precipitation) addtext(county FE, YES, date FE, YES)


*单纯的气象变量
reghdfe pre_station thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station2-1.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(precipitation) addtext(county FE, YES, date FE, YES)


reghdfe pre_station thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean if county_imply1==1, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station2-2.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(precipitation) addtext(county FE, YES, date FE, YES)


reghdfe pre_station thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean if county_imply1==0, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station2-3.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(precipitation) addtext(county FE, YES, date FE, YES)


reghdfe pre_station thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean preci_3mean, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\station2-4.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(precipitation) addtext(county FE, YES, date FE, YES)



*******MARS预测降水
*气象变量和区县类别交互
reghdfe pre_mars thickness c.thickness#1.county_imply1 velocity c.velocity#1.county_imply1 air_fraction_mean c.air_fraction_mean#1.county_imply1 fraction c.fraction#1.county_imply1, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars1-1.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)


reghdfe pre_mars thickness c.thickness#1.county_imply2 velocity c.velocity#1.county_imply2 air_fraction_mean c.air_fraction_mean#1.county_imply2 fraction c.fraction#1.county_imply2, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars1-2.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)


reghdfe pre_mars thickness c.thickness#1.county_imply3 velocity c.velocity#1.county_imply3 air_fraction_mean c.air_fraction_mean#1.county_imply3 fraction c.fraction#1.county_imply3, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars1-3.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)


reghdfe pre_mars thickness c.thickness#1.county_imply4 velocity c.velocity#1.county_imply4 air_fraction_mean c.air_fraction_mean#1.county_imply4 fraction c.fraction#1.county_imply4, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars1-4.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)

*加上所有可能的来自气象站的变量
reghdfe pre_mars thickness c.thickness#1.county_imply1 velocity 1.county_imply1#c.velocity fraction 1.county_imply1#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars1-5.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)


reghdfe pre_mars thickness c.thickness#1.county_imply2 velocity 1.county_imply2#c.velocity fraction 1.county_imply2#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars1-6.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)


reghdfe pre_mars thickness c.thickness#1.county_imply3 velocity 1.county_imply3#c.velocity fraction 1.county_imply3#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars1-7.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)

reghdfe pre_mars thickness c.thickness#1.county_imply4 velocity 1.county_imply4#c.velocity fraction 1.county_imply4#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars1-8.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)


*单纯的气象变量
reghdfe pre_mars thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars2-1.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)


reghdfe pre_mars thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean if county_imply1==1, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars2-2.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)


reghdfe pre_mars thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean if county_imply1==0, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars2-3.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)


reghdfe pre_mars thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean preci_3mean, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\mars2-4.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(mars) addtext(county FE, YES, date FE, YES)



*******国内预测降水
*气象变量和区县类别交互
reghdfe pre_ch thickness c.thickness#1.county_imply1 velocity c.velocity#1.county_imply1 air_fraction_mean c.air_fraction_mean#1.county_imply1 fraction c.fraction#1.county_imply1, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch1-1.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)


reghdfe pre_ch thickness c.thickness#1.county_imply2 velocity c.velocity#1.county_imply2 air_fraction_mean c.air_fraction_mean#1.county_imply2 fraction c.fraction#1.county_imply2, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch1-2.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)


reghdfe pre_ch thickness c.thickness#1.county_imply3 velocity c.velocity#1.county_imply3 air_fraction_mean c.air_fraction_mean#1.county_imply3 fraction c.fraction#1.county_imply3, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch1-3.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)


reghdfe pre_ch thickness c.thickness#1.county_imply4 velocity c.velocity#1.county_imply4 air_fraction_mean c.air_fraction_mean#1.county_imply4 fraction c.fraction#1.county_imply4, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch1-4.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)

*加上所有可能的来自气象站的变量
reghdfe pre_ch thickness c.thickness#1.county_imply1 velocity 1.county_imply1#c.velocity fraction 1.county_imply1#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch1-5.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)


reghdfe pre_ch thickness c.thickness#1.county_imply2 velocity 1.county_imply2#c.velocity fraction 1.county_imply2#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch1-6.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)


reghdfe pre_ch thickness c.thickness#1.county_imply3 velocity 1.county_imply3#c.velocity fraction 1.county_imply3#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch1-7.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)

reghdfe pre_ch thickness c.thickness#1.county_imply4 velocity 1.county_imply4#c.velocity fraction 1.county_imply4#c.fraction air_fraction_mean preci_7mean evp tem win_2mi pressure humidity tem_0cm win_2mi_7mean tem_avg_7mean win_max evp_7mean velocity_7mean thickness_7mean c.velocity#c.pressure c.velocity#c.win_max thickness_pre1 velocity_pre1 air_pre1 fraction_pre1 preci_pre1, absorb(operation_date location1) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch1-8.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)


*单纯的气象变量
reghdfe pre_ch thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch2-1.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)


reghdfe pre_ch thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean if county_imply1==1, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch2-2.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)


reghdfe pre_ch thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean if county_imply1==0, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch2-3.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)


reghdfe pre_ch thickness d_thickness velocity d_velocity air_fraction_mean d_air fraction d_fraction preci_7mean preci_3mean, absorb(location1 operation_date) vce(cluster city1)

outreg2 using "E:\MERGE\20241204\ch2-4.doc", replace tstat e(F) r2 adjr2 bdec(4) tdec(2) ctitle(china_forecast) addtext(county FE, YES, date FE, YES)


