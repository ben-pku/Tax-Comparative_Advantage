************************NSE_reg_analysis with lag **********
*************edited 0219 ***********************************

cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data"
use panel1,clear
// 以下是我winsor 之后得到的滞后项结果 可能还要再来一把
* lag CA
collapse (mean) cong1 cong2 cong3 cong4 congr1 congr2 congr3 congr4 l_cong1 l_cong2 l_cong3 l_cong4 l_congr1 l_congr2 l_congr3 l_congr4 l_congr1s l_congr2s l_congr3s l_congr4s ,by(ind4_index year)
xtset ind4_index year
gen L_cong1 = L.cong1
gen L_cong2 = L.cong2
gen L_cong3 = L.cong3
gen L_cong4 = L.cong4

gen L_congr1 = L.congr1
gen L_congr2 = L.congr2
gen L_congr3 = L.congr3
gen L_congr4 = L.congr4

gen L_l_cong1 = L.l_cong1
gen L_l_cong2 = L.l_cong2
gen L_l_cong3 = L.l_cong3
gen L_l_cong4 = L.l_cong4

gen L_l_congr1 = L.l_congr1
gen L_l_congr2 = L.l_congr2
gen L_l_congr3 = L.l_congr3
gen L_l_congr4 = L.l_congr4

gen L_l_congr1s = L.l_congr1s
gen L_l_congr2s = L.l_congr2s
gen L_l_congr3s = L.l_congr3s
gen L_l_congr4s = L.l_congr4s

label variable L_cong1 "lag of cong1"
label variable L_cong2 "lag of cong2"
label variable L_cong3 "lag of cong3"
label variable L_cong4 "lag of cong4"
label variable L_congr1 "lag of congr1"
label variable L_congr2 "lag of congr2"
label variable L_congr3 "lag of congr3"
label variable L_congr4 "lag of congr4"
label variable L_l_cong1 "lag of l_cong1"
label variable L_l_cong2 "lag of l_cong2"
label variable L_l_cong3 "lag of l_cong3"
label variable L_l_cong4 "lag of l_cong4"
label variable L_l_congr1 "lag of l_congr1"
label variable L_l_congr2 "lag of l_congr2"
label variable L_l_congr3 "lag of l_congr3"
label variable L_l_congr4 "lag of l_congr4"
label variable L_l_congr1s "lag of l_congr1s"
label variable L_l_congr2s "lag of l_congr2s"
label variable L_l_congr3s "lag of l_congr3s"
label variable L_l_congr4s "lag of l_congr4s"

gen d_cong1 = cong1 -L_cong1
gen d_cong2 = cong2 -L_cong2
gen d_cong3 = cong3 -L_cong3
gen d_cong4 = cong4 -L_cong4

gen d_congr1 = congr1 -L_congr1
gen d_congr2 = congr2 -L_congr2
gen d_congr3 = congr3 -L_congr3
gen d_congr4 = congr4 -L_congr4

gen d_l_cong1 = l_cong1 -L_l_cong1
gen d_l_cong2 = l_cong2 -L_l_cong2
gen d_l_cong3 = l_cong3 -L_l_cong3
gen d_l_cong4 = l_cong4 -L_l_cong4

gen d_l_congr1 = l_congr1 -L_l_congr1
gen d_l_congr2 = l_congr2 -L_l_congr2
gen d_l_congr3 = l_congr3 -L_l_congr3
gen d_l_congr4 = l_congr4 -L_l_congr4

* dummy of diff 
gen ddc1 = (d_cong1>0)
gen ddc2 = (d_cong2>0)
gen ddc3 = (d_cong3>0)
gen ddc4 = (d_cong4>0)
gen ddlc1 = (d_l_cong1>0)
gen ddlc2 = (d_l_cong2>0)
gen ddlc3 = (d_l_cong3>0)
gen ddlc4 = (d_l_cong4>0)
gen ddcr1 = (d_congr1>0)
gen ddcr2 = (d_congr2>0)
gen ddcr3 = (d_congr3>0)
gen ddcr4 = (d_congr4>0)
gen ddlcr1 = (d_l_congr1>0)
gen ddlcr2 = (d_l_congr2>0)
gen ddlcr3 = (d_l_congr3>0)
gen ddlcr4 = (d_l_congr4>0)


save panel_congruence,replace

*merge with lag cong
use panel1 ,clear
merge m:1 ind4_index year using panel_congruence.dta
drop _merge

* reg with lag cong

reg cit_r1 L_cong1 cong1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust) // - -
reg cit_r1 L_cong2 cong2 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust) // - +
reg cit_r1 L_cong3 cong3 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust)  //- - 
reg cit_r1 L_cong4 cong4 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust) //- -

reg cit_r1 L_congr1 congr1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust) //- -
reg cit_r1 L_congr2 congr2 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust) //- +
reg cit_r1 L_congr3 congr3 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust)  //- -
reg cit_r1 L_congr4 congr4 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust)  //- -

*取对数滞后项  到124行 重来
reg cit_r1 L_l_cong1 l_cong1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust) // ++  goood
reg cit_r1 L_l_cong2 l_cong2 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust) // --
reg cit_r1 L_l_cong3 l_cong3 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust)  // +- 
reg cit_r1 L_l_cong4 l_cong4 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust) // ++  goood

reg cit_r1 L_l_congr1 l_congr1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust) //- -
reg cit_r1 L_l_congr2 l_congr2 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust) //- +
reg cit_r1 L_l_congr3 l_congr3 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust)  //- -
reg cit_r1 L_l_congr4 l_congr4 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 ), vce(robust)  //- -



/*0215 reg 
reg cit_r1 L_l_cong1 i.firmtypexz  i.district  lcf hightech small transition minority export rd asset0  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
outreg2 using "lag_CA.doc",replace
//good
reg cit_r1 L_l_cong2 i.firmtypexz  i.district  lcf hightech small transition minority export rd asset0  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
outreg2 using "lag_CA.doc",append
//负的 符号
reg cit_r1 l_cong1 L_l_cong1 i.firmtypexz  i.district  lcf hightech small transition minority export rd asset0  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
outreg2 using "lag_CA.doc",append
//都是正的
reg cit_r1 l_cong2 L_l_cong2 i.firmtypexz  i.district  lcf hightech small transition minority export rd asset0  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
outreg2 using "lag_CA.doc",append
//都是负的
ivregress 2sls cit_r1 i.firmtypexz  i.district  lcf hightech small transition minority export rd asset0  i.year (L_l_cong1 = L_l_cong2)  if (ind~= 0 & profit_total_check >0),vce(robust)
outreg2 using "lag_CA.doc",append
//负的非常大
*/

foreach ln of varlist d_cong1 d_cong2 d_cong3 d_cong4{
	reg cit_r1 `ln' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0 ), vce(robust) 
} //除了2 都是负的 x  -+--

foreach ln of varlist d_l_cong1 d_l_cong2 d_l_cong3 d_l_cong4{
	reg cit_r1 `ln' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0), vce(robust) 
}  //除了2 都是负的 x  -+--


**** 对未来更有比较优势的产业有更大的扶持，同时这些产业也得到了更好的成长 （reverse causality） 这是一个相关性，没有因果

* ddc   +(insignificant) +(significant) +(significant) -
forvalues i = 1(1)4 {
	if `i'==1{
	reg cit_r1 ddc`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0), vce(robust) 
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\3-NSE_reg_analysis_with_lag-0219\ddc-cit-0219.doc",replace
	}
	else{
	reg cit_r1 ddc`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0), vce(robust) 
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\3-NSE_reg_analysis_with_lag-0219\ddc-cit-0219.doc",append
	}
}  
/* ddlc // - +(significant) - - 
foreach ln of varlist ddlc1 ddlc2 ddlc3 ddlc4 {
	reg cit_r1 `ln' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0), vce(robust) 
} */ 

* ddcr // + + + + (all significant)  !!!!very gooooooood
forvalues i = 1(1)4  {
	if `i'==1{
	reg cit_r1 ddcr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0), vce(robust) 
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\3-NSE_reg_analysis_with_lag-0219\ddcr-cit-0219.doc",replace
	}
	else{
	reg cit_r1 ddcr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0), vce(robust) 
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\3-NSE_reg_analysis_with_lag-0219\ddcr-cit-0219.doc",append
	}
} 

* ddlcr // + + + + (all significant)  !!!!very gooooooood
forvalues i = 1(1)4  {
	if `i'==1{
	reg cit_r1 ddlcr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0), vce(robust) 
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\3-NSE_reg_analysis_with_lag-0219\ddlcr-cit-0219.doc",replace
	}
	else{
	reg cit_r1 ddlcr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0), vce(robust) 
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\3-NSE_reg_analysis_with_lag-0219\ddlcr-cit-0219.doc",append
	}
} 

*plot the relationship


foreach ln of varlist ddc1 ddc2 ddc3 ddc4{
	reg `ln' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0), vce(robust) 
	predict `ln'0 if (ind~= 0 & profit_total_check >0),residual
	label variable `ln'0 "parial out 控制变量得到的 `ln' 's residual"
}
twoway (scatter cit_r10 ddc10 if (ind~= 0  & profit_total_check >0 ),msize(vtiny) xtitle("Change of Competitive Advantage") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 ddc10 if (ind~= 0  & profit_total_check >0  )),graphregion(color(white))  // 图不好看，看不出来

* 
foreach ln of varlist ddcr1 ddcr2 ddcr3 ddcr4{
	reg `ln' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0), vce(robust) 
	predict `ln'0 if (ind~= 0 & profit_total_check >0),residual
	label variable `ln'0 "parial out 控制变量得到的 `ln' 's residual"
}
twoway (lpolyci cit_r10 ddcr10 if (ind~= 0  & profit_total_check >0 ),msize(vtiny) xtitle("Change of Competitive Advantage") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 ddcr10 if (ind~= 0  & profit_total_check >0  )),graphregion(color(white)) //  
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0217\cit_r10 ddcr10-0219.eps", as(eps) name("Graph") preview(off)

twoway (lpolyci cit_r10 ddcr20 if (ind~= 0  & profit_total_check >0 ),msize(vtiny) xtitle("Change of Competitive Advantage") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 ddcr20 if (ind~= 0  & profit_total_check >0  )),graphregion(color(white)) //有点意思 两个下凹的地方 
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0217\cit_r10 ddcr20-0219.eps", as(eps) name("Graph") preview(off)

twoway (lpolyci cit_r10 ddcr30 if (ind~= 0  & profit_total_check >0 ),msize(vtiny) xtitle("Change of Competitive Advantage") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 ddcr30 if (ind~= 0  & profit_total_check >0  )),graphregion(color(white)) 
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0217\cit_r10 ddcr30-0219.eps", as(eps) name("Graph") preview(off)

twoway (lpolyci cit_r10 ddcr40 if (ind~= 0  & profit_total_check >0 ),msize(vtiny) xtitle("Change of Competitive Advantage") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 ddcr40 if (ind~= 0  & profit_total_check >0  )),graphregion(color(white)) legend(label(2 "CIT rate"))
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\3-NSE_reg_analysis_with_lag-0219\cit_r10 ddcr40-0219.eps", as(eps) name("Graph") preview(off) // 这个的斜率为正很明显 可以放进去说

*

foreach ln of varlist ddlcr1 ddlcr2 ddlcr3 ddlcr4{
	reg `ln' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0 & profit_total_check >0), vce(robust) 
	predict `ln'0 if (ind~= 0 & profit_total_check >0),residual
	label variable `ln'0 "parial out 控制变量得到的 `ln' 's residual"
}
twoway (lpolyci cit_r10 ddlcr10 if (ind~= 0  & profit_total_check >0 ),msize(vtiny) xtitle("Change of Competitive Advantage") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 ddlcr10 if (ind~= 0  & profit_total_check >0  )),graphregion(color(white)) //  
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0217\cit_r10 ddlcr10-0219.eps", as(eps) name("Graph") preview(off)

twoway (lpolyci cit_r10 ddlcr20 if (ind~= 0  & profit_total_check >0 ),msize(vtiny) xtitle("Change of Competitive Advantage") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 ddlcr20 if (ind~= 0  & profit_total_check >0  )),graphregion(color(white)) //  
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0217\cit_r10 ddlcr20-0219.eps", as(eps) name("Graph") preview(off) //有点意思 两个下凹的地方 

twoway (lpolyci cit_r10 ddlcr30 if (ind~= 0  & profit_total_check >0 ),msize(vtiny) xtitle("Change of Competitive Advantage") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 ddlcr30 if (ind~= 0  & profit_total_check >0  )),graphregion(color(white)) //  
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\2-NSE_reg_analysis-0217\cit_r10 ddlcr30-0219.eps", as(eps) name("Graph") preview(off)

twoway (lpolyci cit_r10 ddlcr40 if (ind~= 0  & profit_total_check >0 ),msize(vtiny) xtitle("Change of Competitive Advantage") ytitle("Corporate Income Tax Rate")) (lfitci cit_r10 ddlcr40 if (ind~= 0  & profit_total_check >0  )),graphregion(color(white)) legend(label(2 "CIT rate")) //  
graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\3-NSE_reg_analysis_with_lag-0219\cit_r10 ddlcr40-0219.eps", as(eps) name("Graph") preview(off) //这个的斜率很明显 可以放进去说

save panel2,replace