**************************************
***** competitiveness verify --AghionAEJ 2015**
******edited 0220*********************

cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data"
use panel1,clear
keep idname year sales sales_major ind4_index 
save market0220.dta,replace

* use python data
cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data"
use panel1,clear
merge m:1 year ind4_index using "competitiveness0220.dta"
* HHI
foreach lb of varlist hhi1 hhi2 {
	reg cit_r1 `lb' i.firmtypexz  i.district  lcf hightech transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
}  // 全部显著为负

foreach lb of varlist hhi2 {
	reg cit_r1 `lb' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\5-competitiveness-0220\competitiveness-cit-0220.xls",replace
} 
/* cr 8 - 20
foreach lb of varlist market_share1_8 market_share2_8 market_share1_20 market_share2_20  {
	reg cit_r1 `lb' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
} // 全部显著为负*/

foreach lb of varlist market_share2_8 market_share2_20  {
	reg cit_r1 `lb' i.firmtypexz  i.district  lcf hightech transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\5-competitiveness-0220\competitiveness-cit-0220.xls",append
}
reg hhi2 i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
predict hhi20 if(ind~= 0  & profit_total_check >0 & cit_r1~=.), residual
label variable hhi20 "partial out 控制变量得到的 hhi2的 residual" 
twoway (lpolyci cit_r10 hhi20  if (ind~= 0 & profit_total_check >0) , xtitle("HHI") ytitle("Corporate Income Tax Rate")) (lfit cit_r10 hhi20  if (ind~= 0 & profit_total_check >0)),graphregion(color(white))
	graph export "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\5-competitiveness-0220\cit-hhi2-0220.eps",as(eps) name("Graph") preview(off)

