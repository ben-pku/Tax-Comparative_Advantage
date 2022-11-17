***********  NSE reg analysis  ***********
***********  edited 20220223 *****************

*********** create panel1 *********************
cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data"
use panel0,clear

gen vat_b = vat_sales - (vat_input_17/0.17 + vat_input_13/0.13 + vat_input_7/0.07 + vat_input_less_6/0.04)
gen vat_r = vat /vat_b    // mean = 13%, 峰值在17%左右达到，和陈钊文章得到结果一样
label variable vat_r "增值税税率"
winsor2 vat_r, cut(1 99) replace

gen ex_r = vat_ex_rebate/export_sales
label variable ex_r "出口退税税率 = 退税额/出口货物销售额"

gen busi_r = busi_tax/busi_base
winsor2 busi_r, cut(1 99) replace
label variable busi_r "营业税税率"

gen inctax_post_check = inctax_pre-inctax_reduction-inctax_credit 

generate cit_r2 = inctax_post_check/profit_total_check
winsor2 cit_r2, replace cut(1 95)
label variable cit_r2 "企业所得税税率（在1左右）"
generate cit_r1 = 100 * cit_r2
label variable cit_r1 "企业所得税税率（*100后）" 

egen idname = group(id)
xtset idname year
label variable idname "企业id数值版"
egen ind4_index = group(cic4)
label variable ind4_index "4位行业转换为数字的代码"

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

/*产生地区虚拟变量：东部=3；中部=1；西部=2 东北=0；
东部：北京11、天津12、河北13、上海31、江苏32、浙江33、福建35、山东37、广东44和海南46
中部：山西14、吉林22、黑龙江23、安徽34、江西36、河南41、湖北42、湖南43
西部：四川51、重庆50、贵州52、云南53、西藏54、陕西61、甘肃62、青海63、宁夏64、新疆65、广西45、内蒙古15
东北：吉林22、黑龙江23、辽宁21
*/
gen city=substr(id,1,4)
gen prov=substr(id,1,2)
replace city="1100" if prov=="11"
replace city="3100" if prov=="31"
replace city="1200" if prov=="12"
replace city="5000" if prov=="50"
destring prov city,replace force
generate district=3 if prov==11|prov==12|prov==13|prov==31|prov==32|prov==33|prov==35|prov==37|prov==44|prov==46
replace district=1 if prov==14|prov==34|prov==36|prov==41|prov==42|prov==43
replace district=2 if prov==15|prov==45|prov==50|prov==51|prov==52|prov==53|prov==54|prov==61|prov==62|prov==63|prov==64|prov==65
replace district = 0 if prov==21|prov==22|prov==23
replace prov=. if missing(district)
replace city=. if missing(district)
label variable district "东中西部，3-east,1-middle,2-west,0-northeast"
label variable prov "省份代码"
label variable city "城市代码（直辖市作为一个城市处理）"


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


*******************************************************************
******************* NSE  regression *******************************
*k的衡量：固定资产量 fixasset
*l的衡量：雇佣人数 employ_mean

bysort year cic4: egen s_fixasset = sum(fixasset)
bysort year cic4: egen s_asset0 = sum(asset0)
bysort year cic4: egen s_asset1 = sum(asset1)
bysort year cic4: egen s_wage = sum(wage)
bysort year cic4: egen s_wage_check = sum(wage_check)
replace employ_mean = (employ_begin+employ_end)/2 if year ==2010|year==2011
bysort year cic4: egen s_employ = sum(employ_mean)
label variable s_fixasset "固定资产行业总和"
label variable s_asset0 "年初资产行业总和"
label variable s_asset1 "年末资产行业总和"
label variable s_employ "职工数量行业总和"
label variable s_wage "支付给职工以及为职工支付的现金 行业总和"
label variable s_wage_check "全年计提的工资及奖金总额 行业总和" 

* check data 0223
tabstat s_fixasset employ_mean, by(year)
preserve
collapse s_fixasset employ_mean, by(cic4 year)
gen cic2=substr(cic4,2,2)
twoway(lpoly s_fix year)(lpoly employ_mean year, yaxis(2)), by(cic2, yrescale)  //给y每组单独设定坐标刻度

restore
tabstat s_fixasset, stat(p1 p5 p50 mean p95 p99) by(year)
tabstat s_employ, stat(p1 p5 p50 mean p95 p99) by(year)

************
winsor2 s_fixasset, replace cuts (1 95)
winsor2 s_employ, replace cuts (1 95)

bysort year city: egen c_fixasset = sum(fixasset)
bysort year city: egen c_asset0 = sum(asset0)
bysort year city: egen c_employ = sum(employ_mean)
bysort year city: egen c_wage = sum(wage)
bysort year city: egen c_wage_check = sum(wage_check)
label variable c_fixasset "当地固定资产总和"
label variable c_asset0 "当地年初资产总和"
label variable c_employ "当地劳动力总和"
label variable c_wage "当地wage工资现金总和"
label variable c_wage_check "当地wage_check工资及奖金总和"

* check data 20220223
tabstat c_fixasset, stat(p1 p5 p50 mean p95 p99) by(year)
tabstat c_employ, stat(p1 p5 p50 mean p95 p99) by(year)
bysort city: egen c_fixasset_total = sum(fixasset)
bysort city: egen c_employ_total = sum(employ_mean)
drop c_fixasset c_employ
*********************************************0224 check 11:46 a.m.
* cong with abs
gen cong1 = abs(s_fixasset / s_employ - c_fixasset/c_employ)/(c_fixasset/c_employ)
gen cong2 = abs(s_asset0 / s_employ - c_asset0/c_employ)/(c_asset0/c_employ)
gen cong3 = abs(s_fixasset / s_wage - c_fixasset/c_wage)/(c_fixasset/c_wage)
gen cong4 = abs(s_fixasset / s_wage_check - c_fixasset/c_wage_check)/(c_fixasset/c_wage_check)
label variable cong1 "绝对值 固定资产/劳动力 行业层面-cong1"
label variable cong2 "绝对值 年初资产/劳动力 行业层面-cong2"
label variable cong3 "绝对值 固定资产/工资现金 行业层面-cong3"
label variable cong4 "绝对值 固定资产/工资及奖金 行业层面-cong4"
* congr without abs
gen congr1 = (s_fixasset / s_employ - c_fixasset/c_employ)/(c_fixasset/c_employ)
gen congr2 = (s_asset0 / s_employ - c_asset0/c_employ)/(c_asset0/c_employ)
gen congr3 = (s_fixasset / s_wage - c_fixasset/c_wage)/(c_fixasset/c_wage)
gen congr4 = (s_fixasset / s_wage_check - c_fixasset/c_wage_check)/(c_fixasset/c_wage_check)
label variable congr1 "固定资产/劳动力 行业层面-congr1"
label variable congr2 "年初资产/劳动力 行业层面-congr2"
label variable congr3 "固定资产/工资现金 行业层面-congr3"
label variable congr4 "固定资产/工资及奖金 行业层面-congr4"

** check data 0223
winsor2 congr1, replace cuts(1 95)
replace cong1=abs(congr1)
hist congr1, bin(100)

* l_cong with abs
gen l_cong1 = abs( (log(s_fixasset / s_employ) - log(c_fixasset/c_employ))/log(c_fixasset/c_employ) )
gen l_cong2 = abs( (log(s_asset0 / s_employ) - log(c_asset0/c_employ))  /log(c_asset0/c_employ) )
gen l_cong3 = abs( (log(s_fixasset / s_wage) - log(c_fixasset/c_wage))/log(c_fixasset/c_wage) )
gen l_cong4 = abs( (log(s_fixasset / s_wage_check) - log(c_fixasset/c_wage_check))/log(c_fixasset/c_wage_check) )
label variable l_cong1 "绝对值 对数化 固定资产/劳动力 行业层面 l_cong1"
label variable l_cong2 "绝对值 对数化 年初资产/劳动力 行业层面 l_cong2"
label variable l_cong3 "绝对值 对数化 固定资产/工资现金 行业层面 l_cong3"
label variable l_cong4 "绝对值 对数化 固定资产/工资及奖金 行业层面 l_cong4"
* l_congr without abs
gen l_congr1 = (log(s_fixasset / s_employ) - log(c_fixasset/c_employ))/abs(log(c_fixasset/c_employ))
gen l_congr2 = (log(s_asset0 / s_employ) - log(c_asset0/c_employ))  /abs(log(c_asset0/c_employ)  )
gen l_congr3 = (log(s_fixasset / s_wage) - log(c_fixasset/c_wage))/ abs(log(c_fixasset/c_wage))
gen l_congr4 = (log(s_fixasset / s_wage_check) - log(c_fixasset/c_wage_check))/ abs(log(c_fixasset/c_wage_check))
label variable l_congr1 "对数化 固定资产/劳动力 行业层面 l_congr1"
label variable l_congr2 "对数化 年初资产/劳动力 行业层面 l_congr2"
label variable l_congr3 "对数化 固定资产/工资现金 行业层面 l_congr3"
label variable l_congr4 "对数化 固定资产/工资及奖金 行业层面 l_congr4"

* check data 0223
sum l_cong1, d
sum l_congr1, d
winsor2 l_congr1, replace cuts(1 99)
replace l_cong1=abs(l_congr1)
hist l_congr1, bin(100)


** 0223 regressions
twoway(lpolyci cit_r1 congr1) // declning pattern: indicating asymmetry 
gen negative=1 if congr1<0
replace negative=0 if congr1>0
gen negative_congr1=negative*congr1
areg cit_r1 cong1 i.firmtypexz1  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)
outreg2 using "2-NSE_reg_analysis-0223asymmetry", excel append
areg cit_r1 congr1 negative_congr1 negative i.firmtypexz1  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)
outreg2 using "2-NSE_reg_analysis-0223asymmetry", excel append
gen negative_cong1=negative*cong1
areg cit_r1 cong1 negative_cong1 negative i.firmtypexz1  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)
outreg2 using "2-NSE_reg_analysis-0223asymmetry", excel append
**inficating that local governments subsidies firms with higher capital intensity (relative to city's endowment)
**in contrast, they charge higher tax to labor intensive firms (that is losing CA)
gen industryKL=log(s_fixasset / s_employ)
sum industryKL, d
areg cit_r1 industryKL i.firmtypexz1  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)
outreg2 using "2-NSE_reg_analysis-0223asymmetry", excel append
areg cit_r1 cong1 industryKL i.firmtypexz1  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)
outreg2 using "2-NSE_reg_analysis-0223asymmetry", excel append
*** including industry level KL ratio in the regression, coefficient on cong1 is negative 
areg cit_r1 cong1 negative_cong1 negative industryKL i.firmtypexz1  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)
outreg2 using "2-NSE_reg_analysis-0223asymmetry", excel append
*** including industry level KL ratio, only firms whose negative=0 receive tax reduction


*-----------------------------------------------------------------------
/* winsor2
foreach lb of varlist cong1 cong2 cong3 cong4 congr1 congr2 congr3 congr4 l_cong1 l_cong2 l_cong3 l_cong4 l_congr1 l_congr2 l_congr3 l_congr4{
	winsor2 `lb' ,  replace cut(1 99)
}*/
gen l_congr1s = l_congr1*l_congr1
gen l_congr2s = l_congr2*l_congr2
gen l_congr3s = l_congr3*l_congr3
gen l_congr4s = l_congr4*l_congr4
label variable l_congr1s "平方项对数化 固定资产/劳动力 行业层面 l_congr1s"
label variable l_congr2s "平方项对数化 年初资产/劳动力 行业层面 l_congr2s"
label variable l_congr3s "平方项对数化 固定资产/工资现金 行业层面 l_congr3s"
label variable l_congr4s "平方项对数化 固定资产/工资及奖金 行业层面 l_congr4s"

* cong1234 with abs 作为核心解释变量进行回归
foreach lb of varlist cong1 cong2 cong3 cong4 {
	reg cit_r1 `lb' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
}
//cong 前的系数都是负的 -- 和我们的想法不一样

* congr1234 without abs 
foreach lb of varlist congr1 congr2 congr3 congr4 {
	reg cit_r1 `lb' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
}//congr 前的系数都是负的 -- 和我们的想法不一样

* log l_cong1234 with abs
foreach lb of varlist l_cong1 l_cong2 l_cong3 l_cong4{
	reg cit_r1 `lb' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
}  // 只有 l_cong2 不是正的系数 good  所以我们进行以下的结果输出
******************************* benchmark reg  **********************************
*********************************************************************************
// reg cit_r10 l_cong1  if (ind~= 0  & profit_total_check >0),vce(robust)
forvalues i = 1(1)4{

	if `i'==2 {
		continue
	}
	reg cit_r1 l_cong`i' if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\l_cong`i'-0218.tex",replace
	reg cit_r1 l_cong`i' i.firmtypexz  if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\l_cong`i'-0218.tex",append
	reg cit_r1 l_cong`i' i.firmtypexz lcf hightech transition minority export if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\l_cong`i'-0218.tex",append
	reg cit_r1 l_cong`i' i.firmtypexz lcf hightech transition minority export rd if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\l_cong`i'-0218.tex",append
	reg cit_r1 l_cong`i' i.firmtypexz  i.district  lcf hightech transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\l_cong`i'-0218.tex",append
	reg cit_r1 l_cong`i' i.firmtypexz  i.district  lcf hightech transition minority export rd asset0 i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\l_cong`i'-0218.tex",append

}


* log l_congr1234 without abs
foreach lb of varlist l_congr1 l_congr2 l_congr3 l_congr4 {
	reg cit_r1 `lb' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
} //前面的系数都是负的 -- 和我们想法不一样


/* 0215 回归没有信息 
reg cit_r1 l_cong1 i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
outreg2 using "current_CA.doc",replace
reg cit_r1 l_cong2 i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
outreg2 using "current_CA.doc",append
* current CA is worthless
ivregress 2sls cit_r1 i.firmtypexz  i.district  lcf hightech small transition minority export rd asset0  i.year (l_cong1 = l_cong2)  if (ind~= 0 & profit_total_check >0),vce(robust)
outreg2 using "current_CA.doc",append
 0215 回归没有信息 */
 
gen congr1s = congr1^2
gen congr2s = congr2^2
gen congr3s = congr3^2
gen congr4s = congr4^2
label variable congr1s "平方项 固定资产/劳动力 行业层面 congr1s"
label variable congr2s "平方项 年初资产/劳动力 行业层面 congr2s"
label variable congr3s "平方项 固定资产/工资现金 行业层面 congr3s"
label variable congr4s "平方项 固定资产/工资及奖金 行业层面 congr4s"



reg cit_r1  i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)  
predict cit_r10 if(ind~= 0  & profit_total_check >0 & cit_r1~=.),residual
label variable cit_r10 "parial out 控制变量得到的 cit_r1's residual"



******************************
** square congruence index ****
reg cit_r1 L_l_congr1s L_l_congr1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust)

*quadratic regression
/*
reg cit_r1 l_congr1s l_congr1 if (ind~= 0  & profit_total_check >0), vce(robust) 
outreg2 using "l_congr1_quadratic.doc",replace
reg cit_r1 l_congr1s l_congr1 i.firmtypexz if (ind~= 0  & profit_total_check >0), vce(robust) 
outreg2 using "l_congr1_quadratic.doc",append
reg cit_r1 l_congr1s l_congr1 i.firmtypexz lcf hightech transition minority export if (ind~= 0  & profit_total_check >0), vce(robust) 
outreg2 using "l_congr1_quadratic.doc",append
reg cit_r1 l_congr1s l_congr1 i.firmtypexz lcf hightech transition minority export rd if (ind~= 0  & profit_total_check >0), vce(robust) 
outreg2 using "l_congr1_quadratic.doc",append
reg cit_r1 l_congr1s l_congr1 i.firmtypexz i.district lcf hightech transition minority export rd i.year if (ind~= 0  & profit_total_check >0), vce(robust) 
outreg2 using "l_congr1_quadratic.doc",append
reg cit_r1 l_congr1s l_congr1 i.firmtypexz i.district lcf hightech transition minority export rd asset0 i.year if (ind~= 0  & profit_total_check >0), vce(robust) 
outreg2 using "l_congr1_quadratic.doc",append 
//结果很好解释，对最可能存在潜在CA部门有所补贴*/

* good reg results
forvalues i = 1(1)4{

	if `i' ==1{
	reg cit_r1 congr`i's congr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\congr1234_quadratic_cit-0218.tex",replace
	}
	else{
	reg cit_r1 congr`i's congr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\congr1234_quadratic_cit-0218.tex",append
	
	}
}  //good

forvalues i = 1(1)4{
	if `i'==1{
	reg cit_r1 l_congr`i's l_congr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\l_congr1234_quadratic_cit-0218.tex",replace
	}
	else{
	reg cit_r1 l_congr`i's l_congr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\l_congr1234_quadratic_cit-0218.tex",append
	}

}  //good

forvalues i = 1(1)4{

	if `i' ==1{
	reg cit_r1 congr`i's cong`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\cong1234_quadratic_cit-0218.tex",replace
	}
	else{
	reg cit_r1 congr`i's cong`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\cong1234_quadratic_cit-0218.tex",append
	
	}
}  //good



/*
forvalues i = 1(1)4{
	if `i'==1{
	reg cit_r1 l_congr`i's l_cong`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\l_cong1234_quadratic_cit-0218.xls",replace
	}
	else{
	reg cit_r1 l_congr`i's l_cong`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\l_cong1234_quadratic_cit-0218.xls",append
	}

}  // 不太对 二次项为负 一次项为正？？？？*/

* good plots
foreach ln of varlist l_congr1 l_congr2 l_congr3 l_congr4 congr1 congr2 congr3 congr4 {
	reg `ln' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	predict `ln'0 if(ind~= 0  & profit_total_check >0 & cit_r1~=.),residual
	label variable `ln'0 "partial out 控制变量得到的 `ln' 's residual"
} 
foreach ln of varlist l_cong1 l_cong2 l_cong3 l_cong4 cong1 cong2 cong3 cong4 {
	reg `ln' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	predict `ln'0 if(ind~= 0  & profit_total_check >0 & cit_r1~=.),residual
	label variable `ln'0 "partial out 控制变量得到的 `ln' 's residual"
} 
/* 0216 作图 看不出来什么信息
twoway (scatter cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0 & year==2008 & l_cong1<0.8 ),msize(vtiny) xtitle("Congruence Index") ytitle("Corporate Income Tax Rate")) (lfit cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0 & year==2008 & l_cong1<0.8 )),graphregion(color(white))
graph export "C:\Users\Benjamin Hwang\Documents\本科生科研\data\tax\data-analysis\results\cit_r1--congruence2008.png", as(png) name("Graph")
twoway (scatter cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0 & year==2009 & l_cong1<0.8 ),msize(vtiny) xtitle("Congruence Index") ytitle("Corporate Income Tax Rate")) (lfit cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0 & year==2009 & l_cong1<0.8 )) ,graphregion(color(white))
graph export "C:\Users\Benjamin Hwang\Documents\本科生科研\data\tax\data-analysis\results\cit_r1--congruence2009.png", as(png) name("Graph")
twoway (scatter cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0 & year==2010 & l_cong1<0.8 ),msize(vtiny) xtitle("Congruence Index") ytitle("Corporate Income Tax Rate")) (lfit cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0 & year==2010 & l_cong1<0.8 )) ,graphregion(color(white))
graph export "C:\Users\Benjamin Hwang\Documents\本科生科研\data\tax\data-analysis\results\cit_r1--congruence2010.png", as(png) name("Graph")
twoway (scatter cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0 & year==2011 & l_cong1<0.8 ),msize(vtiny) xtitle("Congruence Index") ytitle("Corporate Income Tax Rate")) (lfit cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0 & year==2011 & l_cong1<0.8 )) ,graphregion(color(white))
graph export "C:\Users\Benjamin Hwang\Documents\本科生科研\data\tax\data-analysis\results\cit_r1--congruence2011.png", as(png) name("Graph")
*/
/*0218 作图*/
foreach ln of varlist l_congr10 l_congr20 l_congr30 l_congr40 congr10 congr20 congr30 congr40 l_cong10 l_cong20 l_cong30 l_cong40 cong10 cong20 cong30 cong40 {
	twoway (lpolyci cit_r10 `ln' if (ind~= 0  & profit_total_check >0 ), xtitle("Congruence Index") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 `ln' if (ind~= 0  & profit_total_check >0 )),graphregion(color(white)) legend(label(1 "cit rate") label(2 "fitted value"))
	graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\cit-`ln'.eps", as(eps) name("Graph") preview(off) 

}


/*做出来的比较好的图片*/
reg l_cong1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
predict l_cong10 if(ind~= 0  & profit_total_check >0 & cit_r1~=.),residual

forvalues i = 2008(1)2011{
	twoway (lpolyci cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0  & year==`i' & l_cong1<0.8   ),msize(vtiny) xtitle("Congruence Index") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0 & year==`i'  & l_cong1<0.8  )),graphregion(color(white)) legend(label(2 "CIT rate") label(4 "Fitted value"))
	graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\cit-l_cong1-`i'-0218.eps",as(eps) name("Graph") preview(off)
} 

/*对其他指标画图的尝试--结果都不是很合适
twoway (lpolyci cit_r10 l_congr10 if (ind~= 0  & profit_total_check >0  & year==2009 & l_cong1<0.8   ),msize(vtiny) xtitle("Congruence Index") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 l_congr10 if (ind~= 0  & profit_total_check >0 & year==2009  & l_cong1<0.8  )),graphregion(color(white))  //图不好

twoway (qfitci cit_r10 congr10 if (ind~= 0  & profit_total_check >0  & year==2009 & l_cong1<0.8   ),msize(vtiny) xtitle("Congruence Index") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 congr10 if (ind~= 0  & profit_total_check >0 & year==2009  & l_cong1<0.8  )),graphregion(color(white)) // 图不好看

twoway (qfitci cit_r10 cong10 if (ind~= 0  & profit_total_check >0  & year==2009 & l_cong1<0.8   ),msize(vtiny) xtitle("Congruence Index") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 cong10 if (ind~= 0  & profit_total_check >0 & year==2009  & l_cong1<0.8  )),graphregion(color(white))
*/

twoway (qfitci cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0  & year==2008 & l_cong1<0.8   ),msize(vtiny) xtitle("Congruence Index") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0 & year==2008  & l_cong1<0.8  )),graphregion(color(white))  //不行 二次项都反了

twoway (fpfitci cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0  & year==2008 & l_cong1<0.8   ),msize(vtiny) xtitle("Congruence Index") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 l_cong10 if (ind~= 0  & profit_total_check >0 & year==2008  & l_cong1<0.8  )),graphregion(color(white)) // 好像更不行了


/* test for the 2 stage regression -- result is right*/ 
reg congr1s  i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
predict congr1s0 if(ind~= 0  & profit_total_check >0 & cit_r1~=.),residual
label variable congr1s0 "partial out 控制变量得到的 congr1s 's residual"
reg cit_r10 congr1s0 congr10 ,noconstant

save panel1,replace
