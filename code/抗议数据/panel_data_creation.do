clear all

cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"

************** build panel data skeleton **************

* use 2020年12月中华人民共和国县以上行政区划代码 from https://www.mca.gov.cn/mzsj/xzqh/2020/20201201.html
import excel "region.xlsx", sheet("Sheet1") cellrange(A1:B3220) firstrow
drop if adcode >=.

* create time variable *
gen initial=0
gen nperiods=5479 // from 2010-01-01 to 2024-12-31

expand nperiods
bys adcode: gen period=initial+_n-1
generate datevar = date("2010-01-01", "YMD") + period
format datevar %td

gen day=day(datevar)
gen month=month(datevar)
gen year=year(datevar)

keep adcode year month day datevar
save "region_time_cleaned.dta",replace

************ create the weibo protest data ************

import delimited "weibo_protest3.csv",clear

* clean the weibo protest data 
rename 省 province
rename 市 city
rename 区 county

/* For the counties that have been restructured, 
I used the adcode of the new county they were merged into. 
If a county was split into multiple parts, 
I used the adcode of the corresponding city. 
For a few uncertain districts and counties, 
I also used the adcode of the corresponding city. */

replace adcode = 130284 if province == "河北省" & county == "滦县"
replace adcode = 130400 if province == "河北省" & county == "邯郸县"
replace adcode = 130407 if province == "河北省" & county == "肥乡县"
replace adcode = 130408 if province == "河北省" & county == "永年县"
replace adcode = 130500 if province == "河北省" & county == "邢台县"
replace adcode = 130505 if province == "河北省" & county == "任县"
replace adcode = 130506 if province == "河北省" & county == "南和县"
replace adcode = 130881 if province == "河北省" & county == "平泉县"	
replace adcode = 130682 if province == "河北省" & county == "定州市"
replace adcode = 130181 if province == "河北省" & county == "辛集市"

replace adcode = 140200 if province == "山西省" & county == "矿区" & citycode == 1402
replace adcode = 140200 if province == "山西省" & county == "城区" & citycode == 1402
replace adcode = 140200 if province == "山西省" & county == "南郊区" & citycode == 1402
replace adcode = 140215 if province == "山西省" & county == "大同县"
replace adcode = 140403 if province == "山西省" & county == "城区" & citycode == 1404
replace adcode = 140403 if province == "山西省" & county == "郊区" & citycode == 1404
replace adcode = 140404 if province == "山西省" & county == "长治县"
replace adcode = 140405 if province == "山西省" & county == "屯留县"
replace adcode = 140406 if province == "山西省" & county == "潞城市"
replace adcode = 140681 if province == "山西省" & county == "怀仁县"
replace adcode = 140703 if province == "山西省" & county == "太谷县"

replace adcode = 500000 if city == "重庆市" & county == ""

replace adcode = 230726 if province == "黑龙江省" & county == "南岔区"
replace adcode = 230719 if province == "黑龙江省" & county == "友好区"
replace adcode = 230751 if province == "黑龙江省" & county == "西林区"
replace adcode = 230718 if province == "黑龙江省" & county == "翠峦区"
replace adcode = 230751 if province == "黑龙江省" & county == "金山屯区"
replace adcode = 230717 if province == "黑龙江省" & county == "伊春区"
replace adcode = 230718 if province == "黑龙江省" & county == "乌马河区"
replace adcode = 231183 if province == "黑龙江省" & county == "嫩江县"
replace adcode = 232701 if province == "黑龙江省" & county == "漠河县"

replace adcode = 320613 if province == "江苏省" & county == "崇川区"
replace adcode = 320613 if province == "江苏省" & county == "港闸区"
replace adcode = 320685 if province == "江苏省" & county == "海安县"
replace adcode = 320614 if province == "江苏省" & county == "海门市"

replace adcode = 330112 if province == "浙江省" & county == "临安市"
replace adcode = 330212 if province == "浙江省" & county == "江东区"
replace adcode = 330213 if province == "浙江省" & county == "奉化市"
replace adcode = 331083 if province == "浙江省" & county == "玉环县"

replace adcode = 340209 if province == "安徽省" & county == "弋江区"
replace adcode = 340210 if province == "安徽省" & county == "芜湖县"
replace adcode = 340212 if province == "安徽省" & county == "繁昌县"
replace adcode = 340281 if province == "安徽省" & county == "无为县"
replace adcode = 340882 if province == "安徽省" & county == "潜山县"
replace adcode = 341882 if province == "安徽省" & county == "广德县"

replace adcode = 350112 if province == "福建省" & county == "长乐市"

replace adcode = 360112 if province == "江西省" & county == "湾里区"
replace adcode = 360404 if province == "江西省" & county == "九江县"
replace adcode = 360603 if province == "江西省" & county == "余江县"
replace adcode = 360704 if province == "江西省" & county == "赣县"
replace adcode = 360783 if province == "江西省" & county == "龙南县"
replace adcode = 361003 if province == "江西省" & county == "东乡县"
replace adcode = 361100 if province == "江西省" & county == "上饶县"

replace adcode = 370115 if province == "山东省" & county == "济阳县"
replace adcode = 370114 if province == "山东省" & county == "章丘市"
replace adcode = 371681 if province == "山东省" & county == "邹平县"
replace adcode = 370215 if province == "山东省" & county == "即墨市"
replace adcode = 370600 if province == "山东省" & county == "长岛县"
replace adcode = 370614 if province == "山东省" & county == "蓬莱市"
replace adcode = 370116 if province == "山东省" & county == "莱城区"
replace adcode = 370117 if province == "山东省" & county == "钢城区"
replace adcode = 371503 if province == "山东省" & county == "茌平县"

replace adcode = 410202 if province == "河南省" & county == "金明区"
replace adcode = 410783 if province == "河南省" & county == "长垣县"
replace adcode = 411003 if province == "河南省" & county == "许昌县"
replace adcode = 411603 if province == "河南省" & county == "淮阳县"

replace adcode = 420882 if province == "湖北省" & county == "京山县"
replace adcode = 421088 if province == "湖北省" & county == "监利县"

replace adcode = 430182 if province == "湖南省" & county == "宁乡县"
replace adcode = 430200 if province == "湖南省" & county == "株洲县"
replace adcode = 430582 if province == "湖南省" & county == "邵东县"

replace adcode = 450381 if province == "广西壮族自治区" & county == "荔浦县"
replace adcode = 451003 if province == "广西壮族自治区" & county == "田阳县"
replace adcode = 451082 if province == "广西壮族自治区" & county == "平果县"
replace adcode = 451203 if province == "广西壮族自治区" & county == "宜州市"

replace adcode = 460300 if province == "海南省" & county == "西沙群岛"
replace adcode = 460300 if province == "海南省" & county == "南沙群岛"

replace adcode = 500155 if province == "重庆市" & county == "梁平县"
replace adcode = 500156 if province == "重庆市" & county == "武隆县"

replace adcode = 510117 if province == "四川省" & county == "郫县"
replace adcode = 510118 if province == "四川省" & county == "新津县"
replace adcode = 510604 if province == "四川省" & county == "罗江县"
replace adcode = 510981 if province == "四川省" & county == "射洪县"
replace adcode = 511083 if province == "四川省" & county == "隆昌县"
replace adcode = 511504 if province == "四川省" & county == "宜宾县"

replace adcode = 520204 if province == "贵州省" & county == "水城县"
replace adcode = 520281 if province == "贵州省" & county == "盘县"
replace adcode = 522302 if province == "贵州省" & county == "兴仁县"

replace adcode = 530304 if province == "云南省" & county == "马龙县"
replace adcode = 530115 if province == "云南省" & county == "晋宁县"
replace adcode = 530481 if province == "云南省" & county == "澄江县"
replace adcode = 530681 if province == "云南省" & county == "水富县"

replace adcode = 610118 if province == "陕西省" & county == "户县"
replace adcode = 610482 if province == "陕西省" & county == "彬县"
replace adcode = 610703 if province == "陕西省" & county == "南郑县"
replace adcode = 610681 if province == "陕西省" & county == "子长县"
replace adcode = 610881 if province == "陕西省" & county == "神木县"

replace adcode = 620881 if province == "甘肃省" & county == "华亭县"
replace adcode = 630106 if province == "青海省" & county == "湟中县"
replace adcode = 632301 if province == "青海省" & county == "同仁县"
replace adcode = 652902 if province == "新疆维吾尔自治区" & county == "库车县"
replace adcode = 220184 if province == "吉林省" & county == "公主岭市"

replace size_max = 0 if size_max >=. 
replace size_mean = 0 if size_mean >=. 
save "weibo_cleaned_1.dta",replace


use "region_time_cleaned.dta",clear
merge 1:m adcode year month day using weibo_cleaned_1.dta

* there are 64 entries requires manually cleaning
preserve
tempfile addition
keep if _merge == 2

* cannot make sure where did the protests happened
drop if event_id == "542400_2016-08-12" | event_id == "431127_2018-07-17"

replace adcode = 370100 
replace adcode = 530103 if event_id == "330100_2018-07-17"
replace adcode = 511900 if event_id == "622925_2012-03-25"
replace adcode = 411000 if event_id == "650201_2012-11-22"
drop _merge
save `addition'
restore

drop if _merge == 2
drop _merge

drop if posts == ""
append using `addition'
drop datevar
save "cleaned_weibo_protests.dta", replace



* merge with skeleton
use "region_time_cleaned.dta",clear
merge 1:m adcode year month day using cleaned_weibo_protests.dta

keep adcode datevar day month year size_max size_mean province city county posts
save "region_time_weibo.dta", replace

gen one = 1 if posts !=""

collapse (count) one (sum) sum_size_max_weibo = size_max (sum) sum_size_mean_weibo=size_mean, by (adcode year month day)

* drop data at the province level (excluding taiwan, xianggang, aomen, chongqing, beijing,shanghai, tianjin)
drop if substr(string(adcode, "%12.0f"), -4, 4) == "0000" & adcode != 710000  & adcode != 810000  & adcode != 820000 & adcode != 120000 & adcode != 110000 & adcode != 500000 & adcode != 310000

rename one n_prt_weibo


save "region_time_weibo_collapsed.dta", replace



************ create the RFA protest data ************

* using python, first cropping columns we want to use
/*
import pandas as pd
df = pd.read_csv("/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据/RFA_protest3.csv",encoding='utf-8')
df = df[['adcode','location','size_level','year','month','day','citycode','省','市','区']]
df.to_csv("/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据/RFA_protest3_cropped.csv",index=False)
*/


* clean the RFA protest data 

import delimited "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据/RFA_protest3_cropped.csv",clear

rename 省 province
rename 市 city
rename 区 county

replace adcode = 130881 if province == "河北省" & county == "平泉县"	
replace adcode = 130682 if province == "河北省" & county == "定州市"
replace adcode = 320685 if province == "江苏省" & county == "海安县"
replace adcode = 350112 if province == "福建省" & county == "长乐市"
replace adcode = 361003 if province == "江西省" & county == "东乡县"
replace adcode = 370115 if province == "山东省" & county == "济阳县"
replace adcode = 411003 if province == "河南省" & county == "许昌县"
replace adcode = 430182 if province == "湖南省" & county == "宁乡县"
replace adcode = 500000 if province == "重庆市" & city == "县" & county == ""
replace adcode = 430182 if province == "湖南省" & county == "宁乡县"
replace adcode = 510117 if province == "四川省" & county == "郫县"
replace adcode = 520281 if province == "贵州省" & county == "盘县"
replace adcode = 530115 if province == "云南省" & county == "晋宁县"
replace adcode = 610118 if province == "陕西省" & county == "户县"
replace adcode = 610681 if province == "陕西省" & county == "子长县"
replace adcode = 610881 if province == "陕西省" & county == "神木县"
replace adcode = 540600 if province == "西藏自治区" & city == "那曲地区" & county == ""
replace adcode = 540622 if province == "西藏自治区" & county == "比如县"
replace adcode = 632301 if province == "青海省" & county == "同仁县"
replace adcode = 652902 if province == "新疆维吾尔自治区" & county == "库车县"

merge m:1 adcode year month day using region_time_cleaned.dta

drop if substr(string(adcode, "%12.0f"), -4, 4) == "0000" & adcode != 710000  & adcode != 810000  & adcode != 820000 & adcode != 120000 & adcode != 110000 & adcode != 500000 & adcode != 310000

gen one = 1 if _merge == 3
collapse (count) one (sum) sum_size_level_rfa = size_level, by (adcode year month day)
gen city = 0  // Initialize city variable to 0
replace city = 1 if substr(string(adcode, "%12.0f"), -2, 2) == "00"
rename one n_prt_rfa

merge 1:1 adcode year month day using region_time_weibo_collapsed.dta

drop _merge
label var n_prt_weibo "number of protests from weibo"
label var n_prt_rfa   "number of protests from rfa"
save "panel.dta", replace

**** merge cloudseeding data ****

import delimited "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据/cloudseeding_adcode.csv", clear 

replace adcode = 140213 if prov == "山西省" & county == "平城区"
replace adcode = 140406 if prov == "山西省" & county == "潞城区"
replace adcode = 320613 if prov == "江苏省" & county == "崇川区"
replace adcode = 320614 if prov == "江苏省" & county == "海门区"
replace adcode = 330112 if prov == "浙江省" & county == "临安区"
replace adcode = 330213 if prov == "浙江省" & county == "奉化区"
replace adcode = 340209 if prov == "安徽省" & county == "弋江区"

replace adcode = 350112 if prov == "福建省" & county == "长乐区"
replace adcode = 360704 if prov == "江西省" & county == "赣县区"
replace adcode = 370614 if prov == "山东省" & county == "蓬莱区"
replace adcode = 370114 if prov == "山东省" & county == "章丘区"
replace adcode = 370215 if prov == "山东省" & county == "即墨区"
replace adcode = 451203 if prov == "广西壮族自治区" & county == "宜州区"


keep adcode year month day 
gen cloudseeding = 1
merge m:1 adcode year month day using region_time_cleaned.dta

drop if substr(string(adcode, "%12.0f"), -4, 4) == "0000" & adcode != 710000  & adcode != 810000  & adcode != 820000 & adcode != 120000 & adcode != 110000 & adcode != 500000 & adcode != 310000

collapse (count) n_cloudseeding = cloudseeding, by(adcode year month day)

merge 1:1 adcode year month day using panel.dta
drop _merge
label var n_cloudseeding "number of cloudseeding"

save "final_panel.dta",replace














