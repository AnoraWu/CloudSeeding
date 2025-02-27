cd "C:\Users\Anora\OneDrive\Desktop\data"
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
replace county = "" if county == "西部"
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

replace county = "鄂温克族自治旗" if county == "鄂温克旗"

replace county = "" if county == "延边州" & city == "延边朝鲜族自治州"

replace county = "九台区" if county == "龙嘉机场" & city == "长春市"
replace county = "木里藏族自治县" if county == "木里县" & city == "凉山彝族自治州"

replace county = "" if city == "宜宾市" & county == "三江新区"
replace county = "沾化区" if county == "沾化县" & city == "滨州市"
replace county = "邹平市" if county == "邹平县" & city == "滨州市"
replace county = "" if county == "度假区" & city == "聊城市"
replace county = "即墨区" if county == "即墨市" & city == "青岛市"
replace county = "雷州市" if county == "乌石镇" & city == "湛江市"

replace county = "金秀瑶族自治县" if county == "金秀县" & city == "来宾市"
replace county = "恭城瑶族自治县" if county == "恭城县" & city == "桂林市"
replace county = "荔浦市" if county == "荔浦县" & city == "桂林市"
replace county = "雷州市" if county == "乌石镇" & city == "湛江市"
replace county = "横州市" if county == "横县" & city == "南宁市"
replace county = "长洲区" if county == "倒水镇" & city == "梧州市"
replace county = "大化瑶族自治县" if county == "大化县" & city == "河池市"
replace county = "巴马瑶族自治县" if county == "巴马县" & city == "河池市"
replace county = "环江毛南族自治县" if county == "环江县" & city == "河池市"
replace county = "平果市" if county == "平果县" & city == "百色市"

replace county = "苍梧县" if county == "六堡区"
replace city = "梧州市" if county == "苍梧县"

replace county = "藤县" if county == "天平镇"
replace city = "梧州市" if county == "藤县"

replace county = "钦南区" if county == "黄屋屯镇"
replace county = "宿城区" if county == "双庄街道"
replace county = "宿城区" if county == "支口街道"
replace county = "宿豫区" if county == "晓店镇"

replace county = "沭阳县" if county == "沐阳县"
replace county = "湖滨区" if county == "湖滨新区"
replace county = "宿城区" if county == "蔡集镇"

replace city = "徐州市" if prov == "江苏省" & county == "铜山区"
replace county = "" if county == "骆马湖"

replace county = "上犹县" if county == "东山镇" & city == "上犹县"
replace city = "赣州市" if county == "上犹县"

replace county = "" if county == "上饶县"
replace county = "广丰区" if county == "广丰县"

replace county = "井冈山市" if county == "新城镇" & city == "井冈山市"
replace city = "吉安市" if county == "井冈山市"
replace county = "袁州区" if county == "彬江镇"& city == "宜春市"

replace county = "濂溪区" if county == "赛阳镇" & city == "庐山市"
replace city = "九江市" if county == "濂溪区" & prov == "江西省"

replace county = "瑞昌市" if county == "高丰镇" & city == "瑞昌市"
replace city = "九江市" if county == "瑞昌市" & prov == "江西省"

replace county = "龙南市" if county == "龙南县" & city == "赣州市"
replace county = "余江区" if county == "余江县"
replace county = "芷江侗族自治县" if county == "芷江县"
replace county = "靖州苗族侗族自治县" if county == "靖州县"
replace county = "湘乡市" if county == "湘乡"

replace county = "" if county == "山河水库"
replace county = "" if county == "彬州市"
replace county = "宁乡市" if county == "宁乡县"

replace county = "喀喇沁左翼蒙古族自治县" if county == "喀左县"
replace county = "本溪满族自治县" if county == "本溪县"
replace county = "桓仁满族自治县" if county == "桓仁县"
replace county = "大柴旦行政委员会" if county == "大柴旦行政区"
replace city = "海东市" if county == "本溪县"
replace county = "本溪满族自治县" if county == "本溪县"
replace county = "本溪满族自治县" if county == "本溪县"
replace county = "本溪满族自治县" if county == "本溪县"
replace county = "本溪满族自治县" if county == "本溪县"

replace county = "" if county == "万盛经开区"

replace county = "沾化区" if county == "沾化县"
replace county = "湟中区" if county == "湟中县"

* cannot identify the county
drop if county == "共和乡"

replace county = "同仁市" if county == "同仁县"
replace county = "河南蒙古族自治县" if county == "河南县"

replace county = "鄂伦春自治旗" if county == "松岭区"
replace city = "呼伦贝尔市" if county == "鄂伦春自治旗"

replace county = "漠河市" if county == "漠河县"
replace county = "杜尔伯特蒙古族自治县" if county == "一心乡"
replace county = "杜尔伯特蒙古族自治县" if county == "他拉哈镇"
replace county = "让胡路区" if county == "喇嘛甸镇"
replace county = "杜尔伯特蒙古族自治县" if county == "胡吉吐莫镇"
replace county = "杜尔伯特蒙古族自治县" if county == "连环湖镇"
replace county = "林甸县" if county == "花园乡" & city == "大庆市"
replace county = "嫩江市" if county == "嫩江县"

replace county = "万荣县" if city == "万荣县"
replace city = "运城市" if county == "万荣县"

replace city = "临夏回族自治州" if city == "临夏州"

replace county = "临夏市" if city == "临夏市"
replace city = "临夏回族自治州" if county == "临夏市"

replace county = "五常市" if city == "五常市"
replace city = "哈尔滨市" if county == "五常市"

replace county = "仙桃市" if city == "仙桃市"
replace city = "" if county == "仙桃市"

replace county = "公主岭市" if city == "公主岭市"
replace city = "长春市" if county == "公主岭市"

replace county = "兴安县" if city == "兴安县"
replace city = "桂林市" if county == "兴安县"

replace county = "凤山县" if city == "凤山县"
replace city = "河池市" if county == "凤山县"

replace county = "北流市" if city == "北流市"
replace city = "玉林市" if county == "北流市"

replace county = "大新县" if city == "大新县"
replace city = "崇左市" if county == "大新县"

replace county = "天峨县" if city == "天峨县"
replace city = "河池市" if county == "天峨县"

replace county = "天门市" if city == "天门市"
replace city = "" if county == "天门市"

replace county = "宁乡市" if city == "宁乡市"
replace city = "长沙市" if county == "宁乡市"

replace county = "安丘市" if city == "安丘市"
replace city = "潍坊市" if county == "安丘市"

replace county = "安化县" if city == "安化县"
replace city = "益阳市" if county == "安化县"

replace county = "庐山市" if city == "庐山市"
replace city = "九江市" if county == "庐山市"

replace county = "延寿县" if city == "延寿县"
replace city = "哈尔滨市" if county == "延寿县"

replace county = "建始县" if city == "建始县"
replace city = "恩施土家族苗族自治州" if county == "建始县"

replace county = "慈利县" if city == "慈利县"
replace city = "张家界市" if county == "慈利县"

replace county = "扶余市" if city == "扶余市"
replace city = "松原市" if county == "扶余市"

drop if city == "新疆生产建设兵团"

replace county = "格尔木市" if city == "格尔木市"
replace city = "海西蒙古族藏族自治州" if county == "格尔木市"

replace county = "汉川市" if city == "汉川市"
replace city = "孝感市" if county == "汉川市"

replace county = "汪清县" if city == "汪清县"
replace city = "延边朝鲜族自治州" if county == "汪清县"

replace county = "沅陵县" if city == "沅陵县"
replace city = "怀化市" if county == "沅陵县"

replace county = "潜江市" if city == "潜江市"
replace city = "" if county == "潜江市"

replace county = "灵山县" if city == "灵山县"
replace city = "钦州市" if county == "灵山县"

replace county = "珲春市" if city == "珲春市"
replace city = "延边朝鲜族自治州" if county == "珲春市"

replace county = "瑞金市" if city == "瑞金市"
replace city = "赣州市" if county == "瑞金市"

replace city = "甘南藏族自治州" if city == "甘南州"

replace county = "磐石市" if city == "磐石市"
replace city = "吉林市" if county == "磐石市"

replace county = "肥城市" if city == "肥城市"
replace city = "泰安市" if county == "肥城市"

drop if city == "西南部"
drop if city == "长白山市"
drop if city == "黄河谷地"

replace county = "青州市" if city == "青州市"
replace city = "潍坊市" if county == "青州市"

replace county = "" if county == "郴州市"

replace city = "三门峡市" if county == "湖滨区"
drop if city == "聊城市" & county == "高新区"

duplicates drop prov city county op_date,force

* drop province level data, as those are not informative
drop if city == "" & county == "" & prov != "重庆市" & prov != "上海市" & prov != "天津市" & prov != "北京市"

tempfile qixiangjv
save `qixiangjv'


*** expand cities without counties ***
preserve 

* specify the cities that needs expansion in the file `cities'
keep if county == ""
keep city prov
duplicates drop
tempfile cities
save `cities'

* find the corresponding counties for those cities
use "skeleton_merged2024.dta" ,clear
keep county city prov
duplicates drop
merge m:1 city prov using `cities'

keep if _merge == 3
drop _merge

* now we have the cities with their counties, join with qixiangjv data
joinby prov city using `qixiangjv'

tempfile cities_cleaned
save `cities_cleaned'
restore

append using `cities_cleaned'


*** expand 直辖市 without counties ***
preserve 
keep if prov == "重庆市" | prov == "上海市" | prov == "天津市" | prov == "北京市"
keep if county == ""
keep prov

duplicates drop

tempfile zhixiashi
save `zhixiashi'

use "skeleton_merged2024.dta" ,clear
keep county city prov
duplicates drop
merge m:1 prov using `zhixiashi'

keep if _merge == 3
drop _merge

joinby prov using `qixiangjv'

tempfile zhixiashi_cleaned
save `zhixiashi_cleaned'
restore

append using `zhixiashi_cleaned'
drop if county == ""




*** for final testing ***
merge m:1 prov city county year month day using "skeleton_merged2024.dta"










// use "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/Cloud Seeding/data/tem/cloudseeding.dta", clear
// drop if published_time == ""
// gen published_time2 = word(published_time, 1)
// replace published_time2 = subinstr(published_time2, "年", "-", .) 
// replace published_time2 = subinstr(published_time2, "月", "-", .) 
// replace published_time2 = subinstr(published_time2, "日", "", .) 
//
// replace published_time2 = string(year)+ "-" + published_time2 if substr(published_time2,1,2) != "20"
// gen pub_date  = date(published_time2, "YMD")
// gen pub_year  = year(pub_date)
// gen pub_month = month(pub_date)
// gen pub_day   = day(pub_date)
//
// drop published_time2 published_time
//
// append using `qixiangjv'
//
// duplicates drop prov city county op_date,force
//
// save "cloudseeding_merged.dta",replace



