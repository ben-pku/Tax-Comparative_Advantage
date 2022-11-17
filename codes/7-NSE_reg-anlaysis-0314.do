cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data"

use panel3,clear
drop if _merge==2
gen inctax_post_check = inctax_pre-inctax_reduction-inctax_credit 
generate cit_r2 = inctax_post_check/profit_total_check
winsor2 cit_r2, replace cut(1 95)
label variable cit_r2 "企业所得税税率（在1左右）"
generate cit_r1 = 100 * cit_r2
label variable cit_r1 "企业所得税税率（*100后）"

label variable district "东中西部，3-east,1-middle,2-west,0-northeast"
label variable prov "省份代码"
label variable city "城市代码（直辖市作为一个城市处理）"

replace employ_mean = (employ_begin+employ_end)/2 if year ==2010|year==2011
bysort city: egen c_fixasset_total = sum(fixasset)
label variable c_fixasset_total "当地固定资产总和"
bysort city:egen c_employ = sum(employ_mean)
bysort year cic4: egen s_fixasset = sum(fixasset)
bysort year cic4: egen s_employ = sum(employ_mean)
label variable s_fixasset "固定资产行业总和"
label variable s_employ "职工数量行业总和"
gen industryKL=log(s_fixasset / s_employ)
gen cong = (s_fixasset/s_employ - c_fixasset/c_employ)/( c_fixasset/c_employ)
gen acong = abs(s_fixasset/s_employ - c_fixasset/c_employ)/( c_fixasset/c_employ)
label variable cong "行业层面匹配度"
label variable acong "绝对值 行业层面匹配度"
winsor2 cong, cut(1 95) replace
winsor2 acong,cut(1 95) replace
gen neg = (cong<0)
gen neg_acong = neg*acong
gen logL = log(employ_mean)

save panel3,replace
* acong
reghdfe cit_r1 acong neg_acong neg industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind district firmtypexz1) cluster(cic4)  // not robust
* acon
gen con = (fixasset/employ_mean - c_fixasset/c_employ)/(c_fixasset/c_employ)
gen acon = abs(fixasset/employ_mean - c_fixasset/c_employ)/(c_fixasset/c_employ)
winsor2 con, cut(1 95) replace
winsor2 acon,cut(1 95) replace
gen ne = (con<0)
gen ne_acon = ne*acon

* previous reg
twoway (lpolyci cit_r1 con if(ind~= 0 & profit_total_check >0),xtitle("Congruence Index") ytitle("CIT Rate")) (lfit cit_r1 con if(ind~= 0 & profit_total_check >0)), legend(label(2 "lpoly smooth")) graphregion(color(white))
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\ 7-NSE_reg-analysis\cit-con.eps", as(eps) name("Graph") preview(off) replace
//1
reghdfe cit_r1 acon if(ind~= 0 & profit_total_check >0),noabsorb
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\prereg", word replace
//2
reghdfe cit_r1 acon i.district i.firmtypexz1 rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\prereg", word append
//3
reghdfe cit_r1 acon i.district i.firmtypexz1  lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind) 
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\prereg", word append
//4
reghdfe cit_r1 acon i.district i.firmtypexz1  lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind) cluster(cic4) 
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\prereg", word append

* main reg
//1
reghdfe cit_r1 acon lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind district firmtypexz1) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\mainreg", word replace
//2
reghdfe cit_r1 industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind district firmtypexz1) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\mainreg", word append
//3
reghdfe cit_r1 acon industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind district firmtypexz1) cluster(cic4)  // 这里加入了acon之后 industryKL甚至也没有变得不显著
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\mainreg", word append
//4
reghdfe cit_r1 acon ne_acon ne lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind district firmtypexz1) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\mainreg", word append
//5
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind district firmtypexz1) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\mainreg", word append

* distribution of con 
twoway (hist con if(ind~=0),bin(100) xtitle("Congruence Index")),graphregion(color(white))
* con - cit
twoway (lfitci  cit_r1 con if(ind~= 0 & con<0),xtitle("Congruence Index") ytitle("CIT Rate") ) (lfitci  cit_r1 con if(ind~= 0  & con>0)),graphregion(color(white)) legend(label(2 "labor intensive") label(3 "capital intensive"))

* robustness test
gen lcon = (log(fixasset/employ_mean)  - log(c_fixasset/c_employ))/abs(log(c_fixasset/c_employ))
gen lacon = abs( (log(fixasset/employ_mean)  - log(c_fixasset/c_employ))/log(c_fixasset/c_employ)  )
gen lne = (lcon<0)
gen lne_lacon = lne*lacon

//1
reghdfe cit_r1 lacon lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind district firmtypexz1) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\rob_reg", word replace

//2
reghdfe cit_r1 lacon industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind district firmtypexz1) cluster(cic4)     // 这里加入了acon之后 industryKL甚至也没有变得不显著
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\rob_reg", word append
//3
reghdfe cit_r1 lacon lne_lacon lne lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind district firmtypexz1) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\rob_reg", word append
//5
reghdfe cit_r1 lacon lne_lacon lne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0),absorb(year ind district firmtypexz1) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\rob_reg", word append


* heterogeneous analysis
*1 ownership
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & firmtypexz1==0),absorb(year ind district ) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\ownership", word replace
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & firmtypexz1==1),absorb(year ind district ) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\ownership", word append
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & firmtypexz1==2),absorb(year ind district ) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\ownership", word append


* district
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & district==0),absorb(year ind firmtypexz1) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\district", word replace
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & district==1),absorb(year ind firmtypexz1) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\district", word append
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & district==2),absorb(year ind firmtypexz1) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\district", word append
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & district==3),absorb(year ind firmtypexz1) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\district", word append

* above-scale 
gen above_scale = (sales_major > 5e+3)
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & above_scale==1),absorb(year ind firmtypexz1 district) cluster(cic4)
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & above_scale==0),absorb(year ind firmtypexz1 district) cluster(cic4)
tab above

* 重工业系数更加不显著 我不好解释
gen kl = fixasset/employ_mean
gsort -kl
sum kl,d
gen k_int = (kl>24.6)
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & k_int==1),absorb(year ind firmtypexz1 district) cluster(cic4)
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & k_int==0),absorb(year ind firmtypexz1 district) cluster(cic4)
tab ind k_int
reghdfe cit_r1 acon ne_acon ne kl lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 ),absorb(year ind firmtypexz1 district) cluster(cic4)

hist kl if(ind~=0 & profit_total_check>0& kl>0 & kl<100),bin(100)


* 就业规模
gen labor = (employ_mean>100)
reghdfe cit_r1 acon ne_acon ne kl lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & employ_mean<100 ),absorb(year ind firmtypexz1 district) cluster(cic4)
reghdfe cit_r1 acon ne_acon ne kl lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & employ_mean>=100 ),absorb(year ind firmtypexz1 district) cluster(cic4)

* manufacture
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & (ind==2|ind==3|ind==4) ),absorb(year ind firmtypexz1 district ) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\manufacture", word replace
reghdfe cit_r1 acon ne_acon ne industryKL lcf hightech small transition minority export rd asset0 logL if(ind~= 0 & profit_total_check >0 & (ind~=2&ind~=3&ind~=4) ),absorb(year ind firmtypexz1 district ) cluster(cic4)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\7-NSE_reg-analysis\manufacture", word append