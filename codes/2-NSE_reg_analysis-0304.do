***********  NSE reg analysis  ***************
***********  edited 20220304 *****************

***********  create panel1 *******************

cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data"
use panel0,clear

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
replace employ_mean = (employ_begin+employ_end)/2 if year ==2010|year==2011
bysort year cic4: egen s_employ = sum(employ_mean)
label variable s_fixasset "固定资产行业总和"
label variable s_employ "职工数量行业总和"
winsor2 s_fixasset, replace cuts (1 95)  //根据下面的一些数据分析 认为必须要舍去极端值
winsor2 s_employ, replace cuts (1 95)
/* check data 0223
tabstat s_fixasset employ_mean, by(year)
preserve
collapse s_fixasset employ_mean, by(cic4 year)
gen cic2=substr(cic4,2,2)
twoway(lpoly s_fix year)(lpoly employ_mean year, yaxis(2)), by(cic2, yrescale)  //给y每组单独设定坐标刻度
restore
tabstat s_fixasset, stat(p1 p5 p50 mean p95 p99) by(year)
tabstat s_employ, stat(p1 p5 p50 mean p95 p99) by(year)
*/
bysort city: egen c_fixasset_total = sum(fixasset)
bysort city: egen c_employ_total = sum(employ_mean)
label variable c_fixasset_total "当地固定资产总和"
label variable c_employ_total "当地劳动力总和"
* 这样城市的禀赋结构在这几年就假定不变了！

************
* congr1 without abs and with abs
gen congr1 = (s_fixasset / s_employ - c_fixasset/c_employ)/(c_fixasset/c_employ)
label variable congr1 "固定资产/劳动力 行业层面-congr1"
winsor2 congr1, replace cuts(1 95)
gen cong1=abs(  (s_fixasset / s_employ - c_fixasset/c_employ)/(c_fixasset/c_employ) )
label variable cong1 "绝对值 固定资产/劳动力 行业层面-cong1"
twoway (hist congr1, bin(100) xtitle("Congruence Index") ), graphregion(color(white))
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\congr1-dist.eps", as(eps) name("Graph") preview(off) replace

winsor2 cong1, replace cuts(1 95)
twoway (hist cong1, bin(100) xtitle("Absolute of Congruence Index") ), graphregion(color(white))
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\cong1-dist.eps", as(eps) name("Graph") preview(off)

* l_congr1 without abs and with abs
gen l_congr1 = (log(s_fixasset / s_employ) - log(c_fixasset/c_employ))/abs(log(c_fixasset/c_employ))
label variable l_congr1 "对数化 固定资产/劳动力 行业层面 l_congr1"
winsor2 l_congr1, replace cuts(1 99)
twoway (hist l_congr1, bin(100) xtitle("Congruence Index (log)") ), graphregion(color(white))

gen l_cong1=abs( (log(s_fixasset / s_employ) - log(c_fixasset/c_employ))/abs(log(c_fixasset/c_employ))  )
winsor2 l_cong1, replace cuts(1 99)
label variable l_cong1 "绝对值 对数化 固定资产/劳动力 行业层面 l_cong1"
twoway (hist l_cong1, bin(100) xtitle("Absolute Value of Congruence Index (log)") ), graphregion(color(white))

** 0223 regressions
** graphs
twoway(lpolyci cit_r1 congr1,xtitle("Congruence Index") ytitle("CIT Rate")) (lfit cit_r1 congr1), legend(label(2 "lpoly smooth")) graphregion(color(white)) // declning pattern: indicating asymmetry 
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\cit-congr1-0224.eps", as(eps) name("Graph") preview(off) replace
 
twoway(lpolyci cit_r1 l_congr1,xtitle("Congruence Index(log)") ytitle("CIT Rate")) (lfit cit_r1 congr1),legend(label(2 "lpoly smooth")) graphregion(color(white)) // declning pattern: indicating asymmetry 
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\cit-l_congr1-0225.eps", as(eps) name("Graph") preview(off) replace

gen negative=1 if congr1<0
replace negative=0 if congr1>0
label variable negative "资本劳动比低于当地endowment structure 的产业"
gen negative_congr1=negative*congr1 //不带绝对值的那个交叉项
gen negative_l_congr1 = negative*l_congr1
gen negative_cong1=negative*cong1  // 绝对值的那个交叉项

gen l_rd = log(rd)
label variable l_rd "对数化R&D"
gen industryKL=log(s_fixasset / s_employ)
sum industryKL, d

reg cit_r1 congr1 if (ind~= 0 & profit_total_check >0), vce(robust) 
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-congr1-0225", word replace
reg cit_r1 congr1 lcf hightech small transition minority export if (ind~= 0 & profit_total_check >0), vce(robust) 
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-congr1-0225", word append
reg cit_r1 congr1 lcf hightech small transition minority export i.firmtypexz1  i.district  i.year if (ind~= 0 & profit_total_check >0), vce(robust)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-congr1-0225", word append
areg cit_r1 congr1 lcf hightech small transition minority export i.firmtypexz1  i.district  i.year if (ind~= 0 & profit_total_check >0),absorb(ind) vce(robust)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-congr1-0225", word append
areg cit_r1 congr1 lcf hightech small transition minority export  i.firmtypexz1  i.district  i.year  rd if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)  // congr1
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-congr1-0225", word append


* l_congr1
reg cit_r1 l_congr1 if (ind~= 0 & profit_total_check >0), vce(robust) 
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-l_congr1-0225", word replace
reg cit_r1 l_congr1 lcf hightech small transition minority export if (ind~= 0 & profit_total_check >0), vce(robust) 
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-l_congr1-0225", word append
reg cit_r1 l_congr1 lcf hightech small transition minority export i.firmtypexz1  i.district  i.year if (ind~= 0 & profit_total_check >0), vce(robust)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-l_congr1-0225", word append
areg cit_r1 l_congr1 lcf hightech small transition minority export i.firmtypexz1  i.district  i.year if (ind~= 0 & profit_total_check >0),absorb(ind) vce(robust)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-l_congr1-0225", word append
areg cit_r1 l_congr1 lcf hightech small transition minority export  i.firmtypexz1  i.district  i.year  rd if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)  // congr1
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-l_congr1-0225", word append


* add negative lose CA

areg cit_r1 l_congr1 negative_l_congr1 negative i.firmtypexz1  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-negative-0225", word replace
areg cit_r1 congr1 negative_congr1 negative i.firmtypexz1  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)  // congr1 ne*congr1 ne  但ne==1时 斜率更平一些
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-negative-0225", word append
** inficating that local governments subsidies firms with higher capital intensity (relative to city's endowment)
** in contrast, they charge higher tax to labor intensive firms (that is losing CA)

* add negative lose CA  -- cong1 ctrl KL
areg cit_r1 cong1   lcf hightech small transition minority export i.firmtypexz1  i.district  i.year rd  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)  // cong1
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-negative_cong1-0225", word replace
areg cit_r1 cong1 negative_cong1 negative lcf hightech small transition minority export i.firmtypexz1  i.district   i.year  rd if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)  // cong1 ne*cong1 ne （说不清楚，但是第6个回归控制K/L之后就可以说清楚了 和前面的结果一样）
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-negative_cong1-0225", word append
areg cit_r1 industryKL lcf hightech small transition minority export i.firmtypexz1  i.district  i.year  rd  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)   
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-negative_cong1-0225", word append
areg cit_r1 cong1 industryKL  lcf hightech small transition minority export i.firmtypexz1  i.district i.year rd   if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)  
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-negative_cong1-0225", word append
*** including industry level KL ratio in the regression, coefficient on cong1 is negative （甚至负的程度更大了（比回归1））
areg cit_r1 cong1 negative_cong1 negative industryKL lcf hightech small transition minority export  i.firmtypexz1  i.district  i.year rd  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-negative_cong1-0225", word append
*** including industry level KL ratio, only firms whose negative=0 receive tax reduction（如果失去CA得到补贴的趋势是更平的，而且很高的税率）



/* 暂未加入 二次项回归 得到的开口向下 顶点在负轴
gen congr1s = congr1^2
gen l_congr1s = l_congr1^2

areg cit_r1 congr1s congr1    lcf hightech small transition minority export  i.firmtypexz1  i.district i.year  rd if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust) 
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-quadratic_congr1-0225",excel replace
areg cit_r1 l_congr1s l_congr1   lcf hightech small transition minority export  i.firmtypexz1  i.district i.year  rd if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\2-NSE_reg_analysis-quadratic_congr1-0225",excel append
*/

* 对每个企业进行 匹配度指标的构建
replace aw = wage_check/employ_mean
winsor2 aw , replace cut(1 99)
twoway (hist aw if (aw>0 & aw<200) ,bin(100) by(year, yrescale)), graphregion(color(white))

gen con1 = (fixasset/employ_mean - c_fixasset/c_employ)/(c_fixasset/c_employ)
winsor2 con1, replace cut(1 99)
areg cit_r1 con1  lcf hightech small transition minority export  i.firmtypexz1  i.district  i.year rd  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust)
// -0.199
gen neg = (con1<0)
gen acon1 = abs( (fixasset/employ_mean - c_fixasset/c_employ)/(c_fixasset/c_employ) )
winsor2 acon1, replace cut(1 95)
gen neg_acon1 = neg*acon1

areg cit_r1 acon1  lcf hightech small transition minority export  i.firmtypexz1  i.district  i.year rd logL if (ind~= 0 & profit_total_check >0), absorb(ind) cluster(cic4) robust 

areg cit_r1 acon1 neg_acon1 neg lcf hightech small transition minority export  i.firmtypexz1  i.district  i.year rd  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust) 
 // acon1 -  neg*acon1+(不显著) 不好说了
areg cit_r1 acon1 neg_acon1 neg industryKL lcf hightech small transition minority export  i.firmtypexz1  i.district  i.year rd  if (ind~= 0 & profit_total_check >0), absorb(ind) vce(robust) 
 
 
twoway (lpolyci cit_r1 acon1 if(ind~= 0 & profit_total_check >0  ),legend(label(2 "lpply smooth"))) (lfit cit_r1 acon1 if(ind~= 0 & profit_total_check >0  )) , graphregion(color(white)) //图质量不行
 graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0218\cit_r-acon1.eps", as(eps) name("Graph") preview(off)

save panel1,replace
****0305 edited
doedit "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\codes\2-NSE_reg_analysis-0304.do" 
do "C:\Users\BENJAM~1\AppData\Local\Temp\STD5c7c_000000.tmp"
use panel1
do "C:\Users\BENJAM~1\AppData\Local\Temp\STD5c7c_000000.tmp"
do "C:\Users\BENJAM~1\AppData\Local\Temp\STD5c7c_000000.tmp"
areg cit_r1 acon1 neg_acon1 neg industryKL lcf hightech small transition minority export  i.firmtypexz1  i.district  i.year rd  if (ind~= 0 & profit_total_check >0), absorb(ind) cluster(cic4) vce(robust) 
areg cit_r1 acon1 neg_acon1 neg industryKL lcf hightech small transition minority export  i.firmtypexz1  i.district  i.year rd  if (ind~= 0 & profit_total_check >0), absorb(ind) cluster(cic4) robust
gen logL=log(employ_mean)
areg cit_r1 acon1 neg_acon1 neg industryKL lcf hightech small transition minority export logL i.firmtypexz1  i.district  i.year rd  if (ind~= 0 & profit_total_check >0), absorb(ind) cluster(cic4) robust
areg cit_r1 cong1 neg_cong1 neg industryKL lcf hightech small transition minority export logL i.firmtypexz1  i.district  i.year rd  if (ind~= 0 & profit_total_check >0), absorb(ind) cluster(cic4) robust
areg cit_r1 cong1 negative_cong1 neg industryKL lcf hightech small transition minority export logL i.firmtypexz1  i.district  i.year rd  if (ind~= 0 & profit_total_check >0), absorb(ind) cluster(cic4) robust
areg cit_r1 cong1 negative_cong1 neg industryKL lcf hightech small transition minority export logL i.firmtypexz1  i.district  i.year rd  if (ind~= 0 & profit_total_check >0), absorb(ind)  robust
do "C:\Users\BENJAM~1\AppData\Local\Temp\STD5c7c_000000.tmp"
reghdfe cit_r1 acon1  lcf hightech small transition minority export   rd logL if (ind~= 0 & profit_total_check >0), absorb(ind year district firmtypexz1) cluster(cic4) robust
reghdfe cit_r1 acon1  lcf hightech small transition minority export   rd logL if (ind~= 0 & profit_total_check >0), absorb(ind year district firmtypexz1) cluster(cic4)
doedit "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\codes\4-NSE_heterogeneous_test-0301.do"