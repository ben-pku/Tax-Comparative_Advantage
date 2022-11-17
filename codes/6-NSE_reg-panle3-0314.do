********** NSE regression 2.0
********** generate panel3  *****************
********** edited 0314 ************************
cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data"
use panel0,clear
egen idname = group(id)
xtset idname year
label variable idname "企业id数值版"
egen ind4_index = group(cic4)
label variable ind4_index "4位行业转换为数字的代码"

*税率计算
gen inctax_post_check = inctax_pre-inctax_reduction-inctax_credit 
generate cit_r2 = inctax_post_check/profit_total_check
winsor2 cit_r2, replace cut(1 95)
label variable cit_r2 "企业所得税税率（在1左右）"
generate cit_r1 = 100 * cit_r2
label variable cit_r1 "企业所得税税率（*100后）" 

*industry  //leave out those with ind==0
gen cic0 = substr(cic4,1,1)
gen cic2 = substr(cic4,1,3)
gen ind = 0
replace ind = 1 if cic0=="A"
replace ind = 2 if cic0=="B"
replace ind = 3 if cic0=="C"
replace ind = 4 if cic0=="D"
replace ind = 5 if cic0=="H"
replace ind = 6 if cic0=="E"
replace ind = 7 if cic0=="J"
replace ind = 8 if cic0=="K"
replace ind = 9 if (cic2=="F51"| cic2=="F52"|cic2=="F53"|cic2=="F54"|cic2=="F55"|cic2=="F56"|cic2=="F57"|cic2=="F59"|cic2=="G60"|  )
replace ind = 10 if (cic0=="I"|cic0=="L"|cic0=="M"|cic0=="N"|cic0=="O"|cic0=="P"|cic0=="Q"|cic0=="R"|cic2=="F58"|cic2=="G61"|cic2=="G62")
replace region=substr(id,1,6) if region==""|region=="."
gen city=substr(region,1,4)
gen prov=substr(region,1,2)
replace city="1100" if prov=="11"
replace city="3100" if prov=="31"
replace city="1200" if prov=="12"
replace city="5000" if prov=="50"
destring prov city,replace force
replace city=city+1 if (city==1300|city==1400|city== 1500|city== 2100|city== 2200|city== 2300|city== 3200|city== 3300|city== 3400|city== 3500|city== 3600|city== 3700|city== 4100|city== 4200|city== 4300|city== 4400|city== 4500|city== 4600|city== 5100|city== 5200|city== 5300|city== 5400|city== 6100|city== 6200|city== 6300|city== 6400 )
generate district=3 if prov==11|prov==12|prov==13|prov==31|prov==32|prov==33|prov==35|prov==37|prov==44|prov==46
replace district=1 if prov==14|prov==34|prov==36|prov==41|prov==42|prov==43
replace district=2 if prov==15|prov==45|prov==50|prov==51|prov==52|prov==53|prov==54|prov==61|prov==62|prov==63|prov==64|prov==65
replace district = 0 if prov==21|prov==22|prov==23 //东北
replace prov=. if missing(district)
replace city=. if missing(district)
label variable district "东中西部，3-east,1-middle,2-west,0-northeast"
label variable prov "省份代码"
label variable city "城市代码（直辖市作为一个城市处理）"
replace region = "440782" in 2302460
replace city = 4407 in 2302460
replace prov = 44 in 2302460
replace city = 4407 in 2302968
replace prov = 44 in 2302968
replace district = 3 in 2302968
replace city = 4407 in 2303072
replace prov = 44 in 2303072
replace district = 3 in 2303072
replace city = 6101 in 2723577
replace prov = 61 in 2723577
replace district = 2 in 2723577
replace city = 6501 in 2910691
replace prov = 65 in 2910691
replace district = 2 in 2910691
replace city = 6501 in 2910905
replace prov = 65 in 2910905
replace district = 2 in 2910905
replace city = 6501 in 2912800
replace prov = 65 in 2912800
replace district = 2 in 2912800
replace city = 6521 in 2917690
replace prov = 65 in 2917690
replace district = 2 in 2917690
replace prov = 65 in 2926046
replace district = 2 in 2926046
replace city = 6528 in 2926046

*隶属情况:3=中央；2=省；1=地区；0=县及以下
tostring sub_to, replace
gen control=0 if sub_to=="50"|sub_to=="61"|sub_to=="62"|sub_to=="63"
replace control=1 if  sub_to=="40"|sub_to=="30"
replace control=2 if  sub_to=="20"
replace control=3 if  sub_to=="10"
label variable control "隶属情况:3=中央；2=省；1=地区；0=县及以下"
gen hylbml=substr(cic4,1,1)
label variable hylbml "行业类别门类"

//所有制虚拟变量(0=民营（集体、私有）；1=国有，2=港澳台，3=外资）
tostring type, replace
gen firmtype=1 if type=="110"|type=="151"
replace firmtype=3 if substr(type,1,1)=="3"
replace firmtype=2 if substr(type,1,1)=="2"
replace firmtype=0 if substr(type,1,2)=="17"
label variable firmtype "依据登记注册类型（严格标准），0=私营，1=国有，2=港澳台，3=外资"

//所有制虚拟变量(0=民营（集体、私有）；1=国有，2=港澳台，3=外资）
tostring type, replace
tostring central_id, replace
gen firmtypexz=1 if type=="110"|type=="141"|type=="143"|type=="151"
replace firmtypexz=3 if substr(type,1,1)=="3"
replace firmtypexz=2 if substr(type,1,1)=="2"
gen gfgs=(type=="160"|type=="161"|type=="162"|type=="163")
replace firmtypexz=1 if central_id>="100000"&!missing(central_id)&gfgs==1
replace firmtypexz=1 if substr(id,1,4)=="中国"
replace firmtypexz=0 if !missing(type)&missing(firmtypexz)
label variable firmtypexz "依据登记注册类型（修正标准），0=民营（集体、私营等），1=国有，2=港澳台，3=外资"
drop gfgs

*indicator
gen lcf = (loss_carry~=0 & loss_carry~=.)
label variable lcf "loss carry-forward ip dummy" 
gen hightech = 0
replace hightech =1 if (hightech_reduction~=. & hightech_reduction>0)
label variable hightech "高新技术 ip dummy"
gen small = 0
replace small =1 if (small_reduction~=. & small_reduction>0)
label variable small "小微企业 ip dummy"
gen transition = 0
replace transition = 1 if(transition_period_reduction ~=. & transition_period_reduction > 0)
label variable transition "过渡期产业政策 ip dummy"
gen minority = 0
replace minority = 1 if (minority_reduction ~=. & minority_reduction > 0)
label variable minority "少数民族企业 ip dummy" 
gen export =0
replace export = 1 if (export_sales ~=. & export_sales > 0) 
label variable export "出口企业 dummy"

gen firmtypexz1 = 0
replace firmtypexz1 = 1 if firmtypexz==1
replace firmtypexz1 = 2 if firmtypexz==2|firmtypexz==3
label variable firmtypexz1 "ownership, 0=民营，1=SOE，2=FOC港澳台"

save panel3,replace

***** calculate some NSE index ************
use panel3,clear
keep if _merge==3
drop _merge

* city level
* 只关注BCD三大产业，city's fixasset 年与年之间没有跳跃
bysort city: egen c_fixasset_total = sum(fixasset)
label variable c_fixasset_total "当地固定资产总和"
replace employ_mean = (employ_begin+employ_end)/2 if year ==2010|year==2011
*gen acon = abs(fixasset/employ_mean - c_fixasset/(1000*popcz) )/(c_fixasset/(1000*popcz))
gen con = (fixasset/employ_mean - c_fixasset/(1000*popcz) )/(c_fixasset/(1000*popcz))
label variable con "企业层面匹配度"
label variable acon "绝对值 企业层面匹配度"
winsor2 acon, cut(0.5 99.5) replace
winsor2 con, cut(0.5 99.5) replace
bysort year cic4: egen s_fixasset = sum(fixasset)
bysort year cic4: egen s_employ = sum(employ_mean)
label variable s_fixasset "固定资产行业总和"
label variable s_employ "职工数量行业总和"
gen industryKL=log(s_fixasset / s_employ)
gen cong = (s_fixasset / s_employ - c_fixasset/(1000*popcz))/(c_fixasset/(1000*popcz))
gen acong = abs(s_fixasset / s_employ - c_fixasset/(1000*popcz))/(c_fixasset/(1000*popcz))
label variable cong "行业层面匹配度"
label variable acong "绝对值 行业层面匹配度"
winsor2 cong, cut(1 95) replace
winsor2 acong,cut(1 95) replace

