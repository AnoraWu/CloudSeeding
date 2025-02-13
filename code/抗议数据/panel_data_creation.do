clear all

cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"

***************** build panel data skeleton *****************

* use 2020年12月中华人民共和国县以上行政区划代码 from https://www.mca.gov.cn/mzsj/xzqh/2020/20201201.html
import excel "region.xlsx", sheet("Sheet1") cellrange(A1:B3220) firstrow
* drop empty rows
drop if adcode >=.

* create time variable *
gen initial=0
gen nperiods=5479 // from 2010-01-01 to 2024-12-31

expand nperiods
bys adcode: gen period=initial+_n-1
generate date = date("2010-01-01", "YMD") + period
format date %td

* create a skeleton with all adcodes (2020 version) and date from 2010-01-01 to 2024-12-31
keep adcode date

save "region_time_cleaned.dta",replace

**************** create the weibo protest data ****************

* datesets provided by Zhenyu
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

* for size indicator, we use two variables: size_original and size_max. size_original keeps the missing value. However, since there are a lot of missing value, we also created the size_max variable, which converts missing value to zero.
gen size_original = size_max
replace size_max = 0 if size_max >=. 
gen date = mdy(month,day,year)

* drop citycode here because we want to create citycode for all datasets afte merging
* directly from adcode
drop citycode 

* this is only a temporary file, as there are 64 remaining entries cannot be merged successfully
save "weibo_cleaned_1.dta",replace


use "region_time_cleaned.dta",clear
merge 1:m adcode date using "weibo_cleaned_1.dta"

* there are 64 entries requires manually cleaning
preserve
tempfile addition
keep if _merge == 2

* not protest relevant
drop if event_id == "371200_2014-10-15" 
* not protest relevant
drop if event_id == "371200_2015-10-12" 
* cannot make sure where happened
drop if event_id == "152201_2019-04-02" 

* except for 6 entries, the other entires happened in 莱芜
replace adcode = 370100 
replace adcode = 411729 if event_id == "371200_2014-07-27"
replace adcode = 340621 if event_id == "431127_2018-07-17"
replace adcode = 540600 if event_id == "542400_2016-08-12"
replace adcode = 530103 if event_id == "330100_2018-07-17"
replace adcode = 511900 if event_id == "622925_2012-03-25"
replace adcode = 411000 if event_id == "650201_2012-11-22"

drop _merge  
save `addition'
restore

* keep the original entiies that successfully merged, append the cleaned entries
keep if _merge == 3
drop _merge
append using `addition'

* generate an indicator of protests
gen one = 1 

save "cleaned_weibo_protests.dta", replace



* merge with skeleton
use "region_time_cleaned.dta",clear
merge 1:m adcode date using "cleaned_weibo_protests.dta"

keep adcode date size_max size_original province city county one

*要是有县里面某一天有一个missing，那这个县就是missing
replace size_original = -999999999 if (size_original==.)

* collapse to county level
collapse (sum) n_prt_weibo = one size_weibo = size_max size_original_weibo = size_original, by (adcode date)

* 如果有一个是missing的，那么加起来肯定是负数
replace size_original_weibo =. if (size_original_weibo<0)

save "region_time_weibo_collapsed.dta", replace



************ create the RFA protest data ************

* using python, first cropping columns we want to use to avoid import error
/*
import pandas as pd
df = pd.read_csv("/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据/RFA_protest3.csv",encoding='utf-8')
df = df[['adcode','location','size_level','year','month','day','citycode','省','市','区']]
df.to_csv("/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据/RFA_protest3_cropped.csv",index=False)
*/


* clean the RFA protest data 

import delimited "RFA_protest3_cropped.csv",clear

* clean the data
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

* same here, since we are missing a lot of size_level entries, we want to convert to missing entrie to zero. we also keep the original missing values in another variable.
gen size_original = size_level
replace size_level = 0 if size_level >=. 

* generate date variable for merging
gen date = mdy(month,day,year)

* generate an indicator variable for protests
gen one = 1 

* drop citycode variable because we want to create the citycode after all the merging
drop citycode
save "cleaned_rfa_protests.dta",replace


use "region_time_cleaned.dta",clear
merge 1:m adcode date using "cleaned_rfa_protests.dta"

* if there is one size entry missing for each adcode and each date, we will count it as missing. 
replace size_original = -999999999 if (size_original==.)

collapse (sum) n_prt_rfa=one size_rfa=size_level size_original_rfa=size_original, by (adcode date)
replace size_original_rfa =. if (size_original_rfa<0)

save "region_time_rfa_collapsed.dta",replace

merge 1:1 adcode date using "region_time_weibo_collapsed.dta"

drop _merge

label var n_prt_weibo "number of protests from weibo"
label var n_prt_rfa   "number of protests from rfa"

save "protest_panel.dta", replace

******* merge cloudseeding data *******

* use python to generate the adcode variable
/* 
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import cpca
import os
os.chdir("/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据")

df = pd.read_stata("cloudseeding.dta")
df["district"] = df['prov'] + df['city'] + df['county']
df_adcode = cpca.transform(df["district"])
df['adcode'] = df_adcode['adcode']
df.to_csv("cloudseeding_adcode.csv")
*/
import delimited "cloudseeding_adcode.csv", clear 

* clean the adcode 
replace adcode = 140213 if prov == "山西省" & county == "平城区"
replace adcode = 140406 if prov == "山西省" & county == "潞城区"
replace adcode = 320613 if prov == "江苏省" & county == "崇川区"
replace adcode = 320614 if prov == "江苏省" & county == "海门区"
replace adcode = 330112 if prov == "浙江省" & county == "临安区"
replace adcode = 330213 if prov == "浙江省" & county == "奉化区"
replace adcode = 340209 if prov == "安徽省" & county == "弋江区"

replace adcode = 350112 if prov == "福建省" & county == "长乐区"、
replace adcode = 350625 if prov == "福建省" & county == "长泰区"
replace adcode = 360704 if prov == "江西省" & county == "赣县区"
replace adcode = 370614 if prov == "山东省" & county == "蓬莱区"
replace adcode = 370114 if prov == "山东省" & county == "章丘区"
replace adcode = 370215 if prov == "山东省" & county == "即墨区"
replace adcode = 451203 if prov == "广西壮族自治区" & county == "宜州区"

replace adcode = 530115 if prov == "云南省" & county == "晋宁区"
replace adcode = 530681 if prov == "云南省" & county == "水富市"
replace adcode = 530304 if prov == "云南省" & county == "马龙区"

replace adcode = 220184 if prov == "吉林省" & county == "公主岭市"

replace adcode = 511083 if prov == "四川省" & county == "隆昌市"
replace adcode = 513425 if prov == "四川省" & county == "会理市"
replace adcode = 511504 if prov == "四川省" & county == "叙州区"
replace adcode = 510604 if prov == "四川省" & county == "罗江区"
replace adcode = 510118 if prov == "四川省" & county == "新津区"
replace adcode = 510117 if prov == "四川省" & county == "郫都区"
replace adcode = 510981 if prov == "四川省" & county == "射洪市"

replace adcode = 340882 if prov == "安徽省" & county == "潜山市"
replace adcode = 341882 if prov == "安徽省" & county == "广德市"
replace adcode = 340281 if prov == "安徽省" & county == "无为市"
replace adcode = 340210 if prov == "安徽省" & county == "湾沚区"
replace adcode = 340212 if prov == "安徽省" & county == "繁昌区"

replace adcode = 370115 if prov == "山东省" & county == "济阳区"
replace adcode = 370116 if prov == "山东省" & county == "莱芜区"
replace adcode = 370117 if prov == "山东省" & county == "钢城区"
replace adcode = 371681 if prov == "山东省" & county == "邹平市"
replace adcode = 371503 if prov == "山东省" & county == "茌平区"

replace adcode = 140703 if prov == "山西省" & county == "太谷区"
replace adcode = 140681 if prov == "山西省" & county == "怀仁市"
replace adcode = 140404 if prov == "山西省" & county == "上党区"
replace adcode = 140405 if prov == "山西省" & county == "屯留区"
replace adcode = 140403 if prov == "山西省" & county == "潞州区"

replace adcode = 450127 if prov == "广西壮族自治区" & county == "横州市"
replace adcode = 450381 if prov == "广西壮族自治区" & county == "荔浦市"
replace adcode = 451082 if prov == "广西壮族自治区" & county == "平果市"
replace adcode = 451003 if prov == "广西壮族自治区" & county == "田阳区"

replace adcode = 652902 if prov == "新疆维吾尔自治区" & county == "库车市"

replace adcode = 320685 if prov == "江苏省" & county == "海安市"

replace adcode = 361104 if prov == "江西省" & county == "广信区"
replace adcode = 360404 if prov == "江西省" & county == "柴桑区"
replace adcode = 360113 if prov == "江西省" & county == "红谷滩区"
replace adcode = 361003 if prov == "江西省" & county == "东乡区"
replace adcode = 360783 if prov == "江西省" & county == "龙南市"
replace adcode = 360603 if prov == "江西省" & county == "余江区"

replace adcode = 130284 if prov == "河北省" & county == "滦州市"
replace adcode = 130881 if prov == "河北省" & county == "平泉市"
replace adcode = 130181 if prov == "河北省" & county == "辛集市"
replace adcode = 130505 if prov == "河北省" & county == "任泽区"
replace adcode = 130503 if prov == "河北省" & county == "信都区"
replace adcode = 130506 if prov == "河北省" & county == "南和区"
replace adcode = 130502 if prov == "河北省" & county == "襄都区"
replace adcode = 130408 if prov == "河北省" & county == "永年区"
replace adcode = 130407 if prov == "河北省" & county == "肥乡区"

replace adcode = 411603 if prov == "河南省" & county == "淮阳区"
replace adcode = 410783 if prov == "河南省" & county == "长垣市"
replace adcode = 411003 if prov == "河南省" & county == "建安区"

replace adcode = 331083 if prov == "浙江省" & county == "玉环市"
replace adcode = 330110 if prov == "浙江省" & county == "临平区"

replace adcode = 421088 if prov == "湖北省" & county == "监利市"
replace adcode = 420882 if prov == "湖北省" & county == "京山市"

replace adcode = 430182 if prov == "湖南省" & county == "宁乡市"
replace adcode = 430212 if prov == "湖南省" & county == "渌口区"
replace adcode = 431121 if prov == "湖南省" & county == "祁阳市"
replace adcode = 430582 if prov == "湖南省" & county == "邵东市"

replace adcode = 620881 if prov == "甘肃省" & county == "华亭市"

replace adcode = 520204 if prov == "贵州省" & county == "水城区"
replace adcode = 520522 if prov == "贵州省" & county == "黔西市"
replace adcode = 522302 if prov == "贵州省" & county == "兴仁市"

replace adcode = 500155 if prov == "重庆市" & county == "梁平区"
replace adcode = 500156 if prov == "重庆市" & county == "武隆区"

replace adcode = 610482 if prov == "陕西省" & county == "彬州市"
replace adcode = 610928 if prov == "陕西省" & county == "旬阳市"
replace adcode = 610322 if prov == "陕西省" & county == "凤翔区"
replace adcode = 610681 if prov == "陕西省" & county == "子长市"
replace adcode = 610881 if prov == "陕西省" & county == "神木市"
replace adcode = 610703 if prov == "陕西省" & county == "南郑区"
replace adcode = 610118 if prov == "陕西省" & county == "鄠邑区"

replace adcode = 632800 if prov == "青海省" & county == "海西蒙古族藏族自治州直辖"
replace adcode = 632803 if prov == "青海省" & county == "茫崖市"
replace adcode = 630106 if prov == "青海省" & county == "湟中区"
replace adcode = 632301 if prov == "青海省" & county == "同仁市"

replace adcode = 230724 if prov == "黑龙江省" & county == "丰林县"
drop if prov == "黑龙江省" & county == "加格达奇区"
replace adcode = 232701 if prov == "黑龙江省" & county == "漠河市"
replace adcode = 231183 if prov == "黑龙江省" & county == "嫩江市"

rename op_date date
keep adcode date

* generate an indicator of cloudseeding
gen cloudseeding = 1

save "cleaned_cloudseeding.dta",replace

use "region_time_cleaned.dta", clear
merge 1:m adcode date using "cleaned_cloudseeding.dta"

collapse (sum) n_cloudseeding = cloudseeding, by(adcode date)

merge 1:1 adcode date using "protest_panel.dta"
drop _merge
label var n_cloudseeding "number of cloudseeding"

save "protest_cloudseeding_panel.dta", replace

******* merge with rainfall data *******

/*
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import cpca
import os
os.chdir("/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据")

df = pd.read_stata("Meteorological.dta")
df["district"] = df['prov'] + df['city'] + df['county']
df_adcode = cpca.transform(df["district"])
df['adcode'] = df_adcode['adcode']
df.to_csv("meteorological_adcode.csv")
*/
import delimited "meteorological_adcode.csv", clear 
keep prov city county year month day pre_station adcode

rename prov province

replace adcode = 440309 if province == "广东省" & county == "龙华区"
replace adcode = 440310 if province == "广东省" & county == "坪山区"
replace adcode = 440311 if province == "广东省" & county == "光明区"

replace adcode = 510117 if province == "四川省" & county == "郫都区"
replace adcode = 510118 if province == "四川省" & county == "新津区"
replace adcode = 511083 if province == "四川省" & county == "隆昌市"
replace adcode = 513425 if province == "四川省" & county == "会理市"
replace adcode = 511504 if province == "四川省" & county == "叙州区"
replace adcode = 510604 if province == "四川省" & county == "罗江区"
replace adcode = 510981 if province == "四川省" & county == "射洪市"

replace adcode = 340281 if province == "安徽省" & county == "无为市"
replace adcode = 340210 if province == "安徽省" & county == "湾沚区"
replace adcode = 340212 if province == "安徽省" & county == "繁昌区"
replace adcode = 340209 if province == "安徽省" & county == "弋江区"
replace adcode = 340882 if province == "安徽省" & county == "潜山市"
replace adcode = 341882 if province == "安徽省" & county == "广德市"

replace adcode = 370115 if province == "山东省" & county == "济阳区"
replace adcode = 370116 if province == "山东省" & county == "莱芜区"
replace adcode = 370117 if province == "山东省" & county == "钢城区"
replace adcode = 370614 if province == "山东省" & county == "蓬莱区"
replace adcode = 370114 if province == "山东省" & county == "章丘区"
replace adcode = 370215 if province == "山东省" & county == "即墨区"
replace adcode = 371503 if province == "山东省" & county == "茌平区"
replace adcode = 371681 if province == "山东省" & county == "邹平市"

replace adcode = 140214 if province == "山西省" & county == "云冈区"
replace adcode = 140215 if province == "山西省" & county == "云州区"
replace adcode = 140404 if province == "山西省" & county == "上党区"
replace adcode = 140405 if province == "山西省" & county == "屯留区"
replace adcode = 140403 if province == "山西省" & county == "潞州区"
replace adcode = 140406 if province == "山西省" & county == "潞城区"
replace adcode = 140213 if province == "山西省" & county == "平城区"
replace adcode = 140703 if province == "山西省" & county == "太谷区"
replace adcode = 140681 if province == "山西省" & county == "怀仁市"

replace adcode = 451082 if province == "广西壮族自治区" & county == "平果市"
replace adcode = 451003 if province == "广西壮族自治区" & county == "田阳区"
replace adcode = 450127 if province == "广西壮族自治区" & county == "横州市"
replace adcode = 450381 if province == "广西壮族自治区" & county == "荔浦市"

replace adcode = 320613 if province == "江苏省" & county == "崇川区"
replace adcode = 320614 if province == "江苏省" & county == "海门区"
replace adcode = 320685 if province == "江苏省" & county == "海安市"

replace adcode = 659005 if province == "新疆维吾尔自治区" & county == "北屯市"
replace adcode = 659007 if province == "新疆维吾尔自治区" & county == "双河市"
replace adcode = 659008 if province == "新疆维吾尔自治区" & county == "可克达拉市"
replace adcode = 650000 if province == "新疆维吾尔自治区" & county == "新星市"
replace adcode = 659009 if province == "新疆维吾尔自治区" & county == "昆玉市"
replace adcode = 659010 if province == "新疆维吾尔自治区" & county == "胡杨河市"

replace adcode = 130505 if province == "河北省" & county == "任泽区"
replace adcode = 130503 if province == "河北省" & county == "信都区"
replace adcode = 130506 if province == "河北省" & county == "南和区"
replace adcode = 130502 if province == "河北省" & county == "襄都区"
replace adcode = 130408 if province == "河北省" & county == "永年区"
replace adcode = 130407 if province == "河北省" & county == "肥乡区"
replace adcode = 130181 if province == "河北省" & county == "辛集市"
replace adcode = 130284 if province == "河北省" & county == "滦州市"
replace adcode = 130881 if province == "河北省" & county == "平泉市"
replace adcode = 130682 if province == "河北省" & county == "定州市"

replace adcode = 330110 if province == "浙江省" & county == "临平区"
replace adcode = 330100 if province == "浙江省" & county == "钱塘区"
replace adcode = 330112 if province == "浙江省" & county == "临安区"
replace adcode = 330213 if province == "浙江省" & county == "奉化区"
replace adcode = 330383 if province == "浙江省" & county == "龙港市"
replace adcode = 331083 if province == "浙江省" & county == "玉环市"

replace adcode = 460300 if province == "海南省" & county == "南沙区"
replace adcode = 460300 if province == "海南省" & county == "西沙区"

replace adcode = 520204 if province == "贵州省" & county == "水城区"
replace adcode = 520281 if province == "贵州省" & county == "盘州市"
replace adcode = 520522 if province == "贵州省" & county == "黔西市"
replace adcode = 522302 if province == "贵州省" & county == "兴仁市"

replace adcode = 500155 if province == "重庆市" & county == "梁平区"
replace adcode = 500156 if province == "重庆市" & county == "武隆区"

replace adcode = 632800 if province == "青海省" & county == "海西蒙古族藏族自治州直辖"
replace adcode = 632803 if province == "青海省" & county == "茫崖市"
replace adcode = 630106 if province == "青海省" & county == "湟中区"
replace adcode = 632301 if province == "青海省" & county == "同仁市"

replace adcode = 230724 if province == "黑龙江省" & county == "丰林县"
replace adcode = 230718 if province == "黑龙江省" & county == "乌翠区"
replace adcode = 230717 if province == "黑龙江省" & county == "伊美区"
replace adcode = 230726 if province == "黑龙江省" & county == "南岔县"
replace adcode = 230725 if province == "黑龙江省" & county == "大箐山县"
replace adcode = 230723 if province == "黑龙江省" & county == "汤旺县"
replace adcode = 230751 if province == "黑龙江省" & county == "金林区"
drop if province == "黑龙江省" & county == "加格达奇区"
replace adcode = 232701 if province == "黑龙江省" & county == "漠河市"
replace adcode = 230719 if province == "黑龙江省" & county == "友好区"
replace adcode = 231183 if province == "黑龙江省" & county == "嫩江市"

replace adcode = 350112 if province == "福建省" & county == "长乐区"
replace adcode = 350625 if province == "福建省" & county == "长泰区"

replace adcode = 451203 if province == "广西壮族自治区" & county == "宜州区"

replace adcode = 540621 if province == "西藏自治区" & county == "嘉黎县"
replace adcode = 540622 if province == "西藏自治区" & county == "比如县"
replace adcode = 540623 if province == "西藏自治区" & county == "聂荣县"
replace adcode = 540624 if province == "西藏自治区" & county == "安多县"
replace adcode = 540625 if province == "西藏自治区" & county == "申扎县"
replace adcode = 540626 if province == "西藏自治区" & county == "索县"
replace adcode = 540627 if province == "西藏自治区" & county == "班戈县"
replace adcode = 540628 if province == "西藏自治区" & county == "巴青县"
replace adcode = 540629 if province == "西藏自治区" & county == "尼玛县"
replace adcode = 540630 if province == "西藏自治区" & county == "双湖县"
replace adcode = 540602 if province == "西藏自治区" & county == "色尼区"
replace adcode = 540104 if province == "西藏自治区" & county == "达孜区"
replace adcode = 540422 if province == "西藏自治区" & county == "米林市"
replace adcode = 540530 if province == "西藏自治区" & county == "错那市"

replace adcode = 220184 if province == "吉林省" & county == "公主岭市"

replace adcode = 360704 if province == "江西省" & county == "赣县区"
replace adcode = 360404 if province == "江西省" & county == "柴桑区"
replace adcode = 360603 if province == "江西省" & county == "余江区"
replace adcode = 360783 if province == "江西省" & county == "龙南市"
replace adcode = 361003 if province == "江西省" & county == "东乡区"
replace adcode = 361104 if province == "江西省" & county == "广信区"
replace adcode = 360113 if province == "江西省" & county == "红谷滩区"

replace adcode = 411603 if province == "河南省" & county == "淮阳区"
replace adcode = 410783 if province == "河南省" & county == "长垣市"
replace adcode = 411003 if province == "河南省" & county == "建安区"

replace adcode = 421088 if province == "湖北省" & county == "监利市"
replace adcode = 420882 if province == "湖北省" & county == "京山市"

replace adcode = 430182 if province == "湖南省" & county == "宁乡市"
replace adcode = 430212 if province == "湖南省" & county == "渌口区"
replace adcode = 431121 if province == "湖南省" & county == "祁阳市"
replace adcode = 430582 if province == "湖南省" & county == "邵东市"

replace adcode = 530115 if province == "云南省" & county == "晋宁区"
replace adcode = 530681 if province == "云南省" & county == "水富市"
replace adcode = 530304 if province == "云南省" & county == "马龙区"
replace adcode = 530481 if province == "云南省" & county == "澄江市"
replace adcode = 532331 if province == "云南省" & county == "禄丰市"

replace adcode = 610482 if province == "陕西省" & county == "彬州市"
replace adcode = 610928 if province == "陕西省" & county == "旬阳市"
replace adcode = 610322 if province == "陕西省" & county == "凤翔区"
replace adcode = 610681 if province == "陕西省" & county == "子长市"
replace adcode = 610881 if province == "陕西省" & county == "神木市"
replace adcode = 610703 if province == "陕西省" & county == "南郑区"
replace adcode = 610118 if province == "陕西省" & county == "鄠邑区"

replace adcode = 620881 if province == "甘肃省" & county == "华亭市"

replace adcode = 652902 if province == "新疆维吾尔自治区" & county == "库车市"
replace adcode = 654223 if province == "新疆维吾尔自治区" & county == "沙湾市"

gen date = mdy(month,day,year)
keep date pre_station adcode
save "cleaned_rainfall.dta",replace

use "region_time_cleaned.dta", clear
merge 1:m adcode date using "cleaned_rainfall.dta"
drop _merge

* before collapse: so that missing values are still missing
replace pre_station = -999999999 if pre_station ==.
collapse (sum) rainfall=pre_station, by(adcode date)
replace rainfall=. if rainfall < 0

merge 1:1 adcode date using "protest_cloudseeding_panel.dta"
drop _merge
label var rainfall "rainfall"

save "protest_cloudseeding_rainfal_panel.dta", replace


******* final clean *******

* drop data at the province level (excluding chongqing, beijing,shanghai, tianjin)
* drop xianggang taiwan aomen
drop if substr(string(adcode), -4, 4) == "0000" & adcode != 120000 & adcode != 110000 & adcode != 500000 & adcode != 310000

gen city = 0

* include 直辖市s which doesn't have county information
replace city = 1 if substr(string(adcode), -2, 2) == "00"

gen citycode = substr(string(adcode), 1, 4)
destring citycode, replace
* for 北京 上海 重庆 天津，their counties first four digits does not align with the 直辖市s
replace citycode = 1100 if (substr(string(citycode), 1, 2) == "11")
replace citycode = 1200 if (substr(string(citycode), 1, 2) == "12")
replace citycode = 3100 if (substr(string(citycode), 1, 2) == "31")
replace citycode = 5000 if (substr(string(citycode), 1, 2) == "50")

*generate week variable
bysort adcode date: gen week = floor((date - date("2010-01-01", "YMD")) / 7) + 1

save "final_panel.dta",replace






