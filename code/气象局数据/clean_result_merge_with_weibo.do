cd "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/气象局数据/人工处理"
import delimited "result_text_issuetime_cleaned.csv", clear 

drop v1 index

gen op_date = date(time, "YMD")
format %td op_date
gen year    = year(op_date)
gen month   = month(op_date)
gen day     = day(op_date)

gen pub_date  = date(issue_time, "YMD")
format %td pub_date
gen pub_year  = year(pub_date)
gen pub_month = month(pub_date)
gen pub_day   = day(pub_date)

drop time issue_time

ren 气象局公告内容 weibo_text

gen prov = word(location, 1)
gen city = word(location, 2)
gen county = word(location, 3)

replace county = city 	if prov == "重庆市" | prov ==" 天津市"
replace city = "" 		if prov == "重庆市" | prov == "天津市"

replace city = "果洛藏族自治州" if city == "果洛州"
replace city = "德宏傣族景颇族自治州" if city == "德宏"
replace city = "德宏傣族景颇族自治州" if city == "德宏州"
replace city = "德宏傣族景颇族自治州" if city == "德宏市"
replace city = "怒江傈僳族自治州" if city == "怒江州"
replace city = "怒江傈僳族自治州" if city == "怒江市"
replace city = "大理白族自治州" if city == "大理州"
replace city = "大理白族自治州" if city == "大理市"
replace city = "保山市" if city == "保山"
replace city = "文山壮族苗族自治州" if city == "文山州"
replace city = "文山壮族苗族自治州" if city == "文山市"
replace city = "楚雄彝族自治州" if city == "楚雄市"
replace city = "楚雄彝族自治州" if city == "楚雄州"
replace city = "红河哈尼族彝族自治州" if city == "红河州"
replace city = "红河哈尼族彝族自治州" if city == "红河市"
replace city = "西双版纳傣族自治州" if city == "版纳市"
replace city = "西双版纳傣族自治州" if city == "西双版纳州"
replace city = "西双版纳傣族自治州" if city == "西双版纳市"
replace city = "迪庆藏族自治州" if city == "迪庆市"
replace city = "迪庆藏族自治州" if city == "迪庆州"
replace city = "四平市" if city == "四平"
replace city = "松原市" if city == "松原"
replace city = "辽源市" if city == "辽源"
replace city = "白城市" if city == "白城"
replace city = "延边朝鲜族自治州" if city == "延边州"
replace city = "" if city == "滇中及以东、滇西北东部"
replace city = "甘孜藏族自治州"      if city == "甘孜州"
replace city = "阿坝藏族羌族自治州"   if city == "阿坝州"
replace city = "湘西土家族苗族自治州" if city == "湘西州"
replace city = "湘西土家族苗族自治州" if city == "湘西自治州"
replace city = "安康市" if city == "安康"
replace city = "宝鸡市" if city == "宝鸡"
replace city = "凉山彝族自治州" if city == "凉山州"
replace city = "甘孜藏族自治州"      if city == "甘孜州"
replace city = "阿坝藏族羌族自治州"   if city == "阿坝州"
replace city = "湘西土家族苗族自治州" if city == "湘西州"
replace city = "湘西土家族苗族自治州" if city == "湘西自治州"
replace city = "安康市" if city == "安康"
replace city = "宝鸡市" if city == "宝鸡"
replace city = "海北藏族自治州" if city == "海北"
replace city = "海北藏族自治州" if city == "海北州"
replace city = "海南藏族自治州" if city == "海南"
replace city = "海南藏族自治州" if city == "海南州"
replace city = "海西蒙古族藏族自治州" if city == "海西州"

replace county = "" 		   	   if county == "内江附近区域"
replace county = "" 			   if county == "红原机场以南区域"

replace county = "连南瑶族自治县" 	   if county == "连南"
replace county = "连山壮族瑶族自治县" if county == "连山"
replace county = "连州市" 		   if county == "连州"
replace county = "阳山县" 		   if county == "阳山"
replace county = "镇沅彝族哈尼族拉祜族自治县" if county == "里崴乡"

drop if city == "长白山保护开发区"

replace county = "罗城仫佬族自治县" if county == "罗城县"
replace county = "都安瑶族自治县" if county == "都安县"
replace county = "隆林各族自治县" if county == "隆林县"
replace county = "富川瑶族自治县" if county == "富川县"

replace city = "" if city == "东部"
replace city = "" if city == "中西部"
replace city = "" if city == "中西部旱区"
replace city = "" if city == "中部"
replace city = "" if city == "北部"
replace city = "" if city == "西部"
replace city = "" if city == "东北部地区"
replace city = "" if city == "东部地区"

replace county = "" 		   	   if county == "内江附近区域"
replace county = "" 			   if county == "红原机场以南区域"

replace county = "禄劝彝族苗族自治县" if county == "禄劝县"
replace county = "" if county == "云龙水库"
replace county = "三江侗族自治县" if county == "三江县"
replace county = "盐都区" if county == "盐都区（七星现代农场）"
replace county = "阜新蒙古族自治县" if county == "阜新镇"
replace county = "岫岩满族自治县" if county == "岫岩县"
replace county = "乌兰县"  if county == "乌兰柯柯镇"
replace county = "乌兰县"  if county == "茶卡镇"
replace city = "海西蒙古族藏族自治州" if county == "乌兰县"

replace county = "" if county == "东辛农场"
replace county = "" if county == "三清山风景区"
replace county = "" if county == "仙女湖区"
replace county = "" if county == "大部"
replace county = "" if county == "北部"
replace county = "" if county == "南部"
replace county = "" if county == "东部"
replace county = "" if county == "玛可河林场"
replace county = "" if county == "云龙水库"

replace city = "" if city == "柴达木盆地"
replace city = "海东市" if city == "海东"
replace county = "互助土族自治县" if county == "互助县"
replace county = "化隆回族自治县" if county == "化隆县"
replace county = "民和回族土族自治县" if county == "民和县"
replace county = "门源回族自治县" if county == "门源县"

replace county = "大柴旦行政区" if county == "大柴旦"
replace county = "大柴旦行政区" if county == "大柴旦行委"
replace county = "大柴旦行政区" if county == "大柴旦镇"
replace county = "德令哈市" if county == "德令哈"
replace county = "大通回族土族自治县" if county == "大通县"

replace county = "蓟州区" if county == "下营镇"
replace county = "宝坻区" if county == "史各庄"
replace county = "蓟州区" if county == "孙各庄"
replace county = "蓟州区" if county == "孙各庄乡"
replace county = "蓟州区" if county == "梁庄子乡"
replace county = "蓟州区" if county == "梁庄子镇"
replace county = "蓟州区" if county == "白涧乡"
replace county = "蓟州区" if county == "穿芳峪乡"
replace county = "蓟州区" if county == "西龙虎峪乡"

replace city = "" if city == "湟水谷地"

replace county = "湟源县" if city == "湟源县"
replace city = "西宁市" if county == "湟源县"

replace city = "玉树藏族自治州" if city == "玉树州"
replace city = "玉树藏族自治州" if city == "玉树市"

replace county = "祁连县" if city == "祁连县"
replace city = "海北藏族自治州" if county == "祁连县"
replace city = "" if city == "祁连山"
replace city = "" if city == "祁连山地区"
replace city = "" if city == "青海湖"

replace county = "阜新蒙古族自治县" if county == "于寺镇"
replace county = "阜新蒙古族自治县" if county == "平安地镇"
replace county = "彰武县" if county == "章古台镇"

replace county = "信丰县" if city == "信丰县"
replace city = "赣州市" if county == "信丰县"

replace county = "兰坪白族普米族自治县" if county == "兰坪县"
replace county = "前郭尔罗斯蒙古族自治县" if county == "前郭县"

replace city = "黄南藏族自治州" if city == "黄南州"
replace county = "" if county == "祁连山南麓地区"
replace county = "" if county == "新青林业局"
replace county = "" if county == "长白山保护开发区"

replace county = "万盛经济技术开发区" if county == "万盛经开区"
replace county = "徐闻县" if county == "海安镇" & city == "湛江市"
replace county = "竹溪县" if city == "竹溪县"
replace city = "十堰市" if county == "竹溪县"


replace county = "" if county == "螺狮山"
replace county = "荆州区" if county == "弥市" & city == "荆州市"
replace county = "荆州区" if county == "王场" & city == "荆州市"
replace county = "荆州区" if county == "纪南" & city == "荆州市"
replace county = "袁州区" if county == "南庙乡"
replace county = "龙南市" if county == "汶龙镇"
replace city = "赣州市" if county == "龙南市"

replace city = "西宁市" if city == "西宁"
replace county = "杜尔伯特蒙古族自治县" if county == "杜尔伯特县"
replace city = "普洱市" if county == "镇沅彝族哈尼族拉祜族自治县"
replace county = "莫力达瓦达斡尔族自治旗" if county == "莫力达瓦旗"

replace county = "梅河口市" if city == "梅河口市"
replace city = "通化市" if city == "梅河口市"

replace county = "天峨县" if county == "向阳乡"
replace county = "" if county == "九洞乡"
replace county = "" if county == "摩天岭顶"

duplicates drop prov city county op_date,force
replace county = "placeholder" if county == ""

tempfile qixiangjv
save `qixiangjv'

use "skeleton_merged2024.dta" ,clear
replace county = "placeholder" if county == ""
merge m:1 prov city county year month day using `qixiangjv'


*** merge those without counties ***
preserve 
tempfile merge1

keep if _merge == 2
drop _merge
keep if county==""

save `merge1'
restore 

drop _merge
drop if county!=""
merge m:1 prov city year month day using `merge1'





replace county = "荔浦市" if county == "荔浦县"


replace county = "荔浦市" if county == "荔浦县"
replace county = "沭阳县" if county == "沐阳县"


replace city = "九江市" if county == "赛阳镇"
replace county = "濂溪区" if county == "赛阳镇"
replace county = "庐山市" if city == "庐山市"

replace county = "井冈山市" if county == "新城镇"
replace city = "吉安市" if county == "井冈山市"

replace county = "沾化区" if county == "沾化县"
replace county = "邹平市" if county == "邹平县"
replace county = "湟中区" if county == "湟中县"

drop location

tempfile qixiangjv
save `qixiangjv'

use "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/Cloud Seeding/data/tem/cloudseeding.dta", clear
drop if published_time == ""
gen published_time2 = word(published_time, 1)
replace published_time2 = subinstr(published_time2, "年", "-", .) 
replace published_time2 = subinstr(published_time2, "月", "-", .) 
replace published_time2 = subinstr(published_time2, "日", "", .) 

replace published_time2 = string(year)+ "-" + published_time2 if substr(published_time2,1,2) != "20"
gen pub_date  = date(published_time2, "YMD")
gen pub_year  = year(pub_date)
gen pub_month = month(pub_date)
gen pub_day   = day(pub_date)

drop published_time2 published_time

append using `qixiangjv'

duplicates drop prov city county op_date,force

save "cloudseeding_merged.dta",replace



