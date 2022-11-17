**********************************
*****  异质性检验*****************
*****    edited 0301  ************
**********************************
cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data"
use panel1 ,clear
merge m:1 ind4_index year using panel_congruence1.dta
drop _merge

gen west = (district==2)
label variable west "西部地区虚拟变量"

* 分组回归 heterogeneous test******************
* benchmark regression test******************
* 1 - district
forvalues i = 0(1)3{
	areg cit_r1 congr1 lcf hightech small transition minority export rd  i.firmtypexz  i.year  if (ind~= 0 & profit_total_check >0 & district==`i'), absorb(ind) vce(robust)
	areg cit_r1 l_congr1 lcf hightech small transition minority export rd  i.firmtypexz  i.year  if (ind~= 0 & profit_total_check >0 & district==`i'), absorb(ind) vce(robust)
}  // 

forvalues i = 0(1)3{
	areg cit_r1 congr1 lcf hightech small transition minority export rd i.firmtypexz i.year  if (ind~= 0 & profit_total_check >0 & district==`i' ), absorb(ind) vce(robust)
	if `i'==0{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_district-congr1-0227.doc",  replace	
	}
	else{
		outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_district-congr1-0227.doc", append
	}
}
/*
gen congr1_check = (fixasset/employ_mean ) /(c_fixasset_total/c_employ_total) -1
areg cit_r1 congr1_check lcf hightech small transition minority export rd  i.firmtypexz1  i.year  if (ind~= 0 & profit_total_check >0 ), absorb(ind) vce(robust)
areg cit_r1 congr1 lcf hightech small transition minority export rd    i.year  if (ind~= 0 & profit_total_check >0 & firmtypexz==1), absorb(ind) vce(robust) */
use panel_tmp
areg cit_r1 congr1 lcf hightech small transition minority export rd   i.year  if (ind~= 0 & profit_total_check >0 & district==3 & firmtypexz1==0), absorb(ind) vce(robust)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\east-ownership-congr1-0301", word replace
areg cit_r1 congr1 lcf hightech small transition minority export rd   i.year  if (ind~= 0 & profit_total_check >0 & district==3 & firmtypexz1==1), absorb(ind) vce(robust)
outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\east-ownership-congr1-0301", word append

// 相关性：middle 》west》east》northeast  (解释：东部由于私有企业多，这种相关性弱；东北地区补贴较混乱，没有考虑到把补贴给到哪里)
forvalues i = 0(1)3{
	areg cit_r1 congr1 negative_congr1 negative lcf hightech small transition minority export rd  i.firmtypexz1  i.year  if (ind~= 0 & profit_total_check >0 & district==`i'), absorb(ind) vce(robust)
	if `i'==0{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_district-congr1-cit-0225", excel replace	
	}
	else{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_district-congr1-cit-0225",excel append
	}
}  
/****** reg 0227  
*east
	areg cit_r1 congr1 lcf hightech small transition minority export rd   i.year  if (ind~= 0 & profit_total_check >0 & district==3 & (firmtypexz==2 | firmtypexz==3)), absorb(ind) vce(robust)
	areg cit_r1 l_congr1 lcf hightech small transition minority export rd    i.year  if (ind~= 0 & profit_total_check >0 & district==3& (firmtypexz==2 | firmtypexz==3)), absorb(ind) vce(robust)
*middle
	areg cit_r1 congr1 lcf hightech small transition minority export rd   i.year  if (ind~= 0 & profit_total_check >0 & district==2 & firmtypexz==0), absorb(ind) vce(robust)
	areg cit_r1 l_congr1 lcf hightech small transition minority export rd    i.year  if (ind~= 0 & profit_total_check >0 & district==2 & firmtypexz==0), absorb(ind) vce(robust)
	areg cit_r1 congr1 lcf hightech small transition minority export rd   i.year  if (ind~= 0 & profit_total_check >0 & district==2 & firmtypexz==1), absorb(ind) vce(robust)
	areg cit_r1 l_congr1 lcf hightech small transition minority export rd    i.year  if (ind~= 0 & profit_total_check >0 & district==2 & firmtypexz==1), absorb(ind) vce(robust)	
*northeast
	areg cit_r1 congr1 lcf hightech small transition minority export rd   i.year  if (ind~= 0 & profit_total_check >0 & district==0 & firmtypexz==0), absorb(ind) vce(robust)
	areg cit_r1 l_congr1 lcf hightech small transition minority export rd    i.year  if (ind~= 0 & profit_total_check >0 & district==0 & firmtypexz==0), absorb(ind) vce(robust)
	areg cit_r1 congr1 lcf hightech small transition minority export rd   i.year  if (ind~= 0 & profit_total_check >0 & district==0 & firmtypexz==1), absorb(ind) vce(robust)
	areg cit_r1 l_congr1 lcf hightech small transition minority export rd    i.year  if (ind~= 0 & profit_total_check >0 & district==0 & firmtypexz==1), absorb(ind) vce(robust)	
//离谱极了
twoway(hist congr1 if(ind~= 0 & profit_total_check >0)), graphregion(color(white))
twoway(hist congr1 if(ind~= 0 & profit_total_check >0 & firmtypexz==1)), graphregion(color(white))
	areg cit_r1 congr1 lcf hightech small transition minority export rd   i.year  if (ind~= 0 & profit_total_check >0 & district==0 & firmtypexz==1 & congr1>0), absorb(ind) vce(robust)
	areg cit_r1 l_congr1 lcf hightech small transition minority export rd    i.year  if (ind~= 0 & profit_total_check >0 & district==0 & firmtypexz==1 & congr1>0), absorb(ind) vce(robust)  // 东北大国企竟然是越资本密集越得到更少补贴（我们的最想说的为国家战略服务的对象没了？）

	
	areg cit_r1 congr1 lcf hightech small transition minority export rd  i.district i.year  if (ind~= 0 & profit_total_check >0  & firmtypexz==0), absorb(ind) vce(robust)
	areg cit_r1 congr1 lcf hightech small transition minority export rd  i.district i.year  if (ind~= 0 & profit_total_check >0  & firmtypexz==1), absorb(ind) vce(robust)
	areg cit_r1 congr1 lcf hightech small transition minority export rd  i.district i.year  if (ind~= 0 & profit_total_check >0  & (firmtypexz==2 | firmtypexz==3)), absorb(ind) vce(robust) */
	

	
twoway (lpolyci cit_r1 congr1 if(ind~= 0 & profit_total_check >0  & district==0) ),legend(label(2 "lpoly smooth")) graphregion(color(white))
	
	
*****
gen soe = (firmtypexz == 1)

* 2 - ownership
forvalues i = 0(1)3{
	areg cit_r1 congr1 lcf hightech small transition minority export rd i.district  i.year  if (ind~= 0 & profit_total_check >0 & firmtypexz==`i'), absorb(ind) vce(robust)
	
}


forvalues i = 0(1)3{
	areg cit_r1 congr1 negative_congr1 negative lcf hightech small transition minority export rd  i.district  i.year  if (ind~= 0 & profit_total_check >0 & firmtypexz==`i'), absorb(ind) vce(robust)
	if `i'==0{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_ownership-congr1-cit-0225",excel replace
	}
	else{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_ownership-congr1-cit-0225",excel append
	}
}  //对民营企业补贴趋势较小 但是对于国有企业可能更多服务于赶超战略（policy burden） 对于港澳台外资--本身资本来自于城市外-与当地的禀赋结构关系更浅

* 3 - 产业是否更加更适应于当地的比较优势  --- 
forvalues i =0(1)1{
	areg cit_r1 l_congr1 lcf hightech small transition minority export rd  i.firmtypexz i.district  i.year  if (ind~= 0 & profit_total_check >0 & ddc1==`i'), absorb(ind) vce(robust)
}  // 

forvalues i =0(1)1{
	areg cit_r1 congr1 negative_congr1 negative lcf hightech small transition minority export rd  i.firmtypexz i.district  i.year  if (ind~= 0 & profit_total_check >0 & ddc1==`i'), absorb(ind) vce(robust)
}

* 4 规模大和规模小企业
gen above_scale = (sales_major > 5e+3)
label variable above_scale "规模以上企业 dummy"
replace above_scale =. if sales_major==.

forvalues i =0(1)1{
	areg cit_r1 congr1 lcf hightech small transition minority export rd  i.firmtypexz i.district  i.year  if (ind~= 0 & profit_total_check >0 & above_scale==`i'), absorb(ind) vce(robust)
	} // 大规模企业 补贴时每偏离一点当地CA，补贴力度更大一些
	
forvalues i =0(1)1{
	areg cit_r1 congr1 negative_congr1 negative lcf hightech small transition minority export rd  i.firmtypexz i.district  i.year  if (ind~= 0 & profit_total_check >0 & above_scale==`i'), absorb(ind) vce(robust)
}  // 不好interpret


* 5 制造业和非制造业 -- BCD234
areg cit_r1 congr1 lcf hightech small transition minority export rd  i.firmtypexz i.district  i.year if (ind~= 0 & profit_total_check >0 & (ind ==3 )),absorb(ind) vce(robust) //-0.025
areg cit_r1 congr1 lcf hightech small transition minority export rd  i.firmtypexz i.district  i.year if (ind~= 0 & profit_total_check >0 & (ind ~=3 )),absorb(ind) vce(robust) //-0.84 非制造业趋势更明显
forvalues i =1(1)10{
	areg cit_r1 congr1 lcf hightech small transition minority export rd  i.firmtypexz i.district  i.year if (ind~= 0 & profit_total_check >0 & (ind ==`i' )),absorb(ind) vce(robust)
}

***输出

forvalues i = 0(1)3{
	areg cit_r1 congr1 lcf hightech small transition minority export rd  i.firmtypexz  i.year  if (ind~= 0 & profit_total_check >0 & district==`i'), absorb(ind) vce(robust)
	if `i'==0{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\district-0227.doc",  replace	
	}
	else{
		outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\district-0227.doc",  append
	}
} 

forvalues i = 0(1)3{
	areg cit_r1 congr1 lcf hightech small transition minority export rd i.district  i.year  if (ind~= 0 & profit_total_check >0 & firmtypexz==`i'), absorb(ind) vce(robust)
	if `i'==0{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_ownership-congr1-0227.doc",  replace	
	}
	else{
		outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_ownership-congr1-0227.doc",  append
	}
}

forvalues i =0(1)1{
	areg cit_r1 l_congr1 lcf hightech small transition minority export rd  i.firmtypexz i.district  i.year  if (ind~= 0 & profit_total_check >0 & ddc1==`i'), absorb(ind) vce(robust)
	if `i'==0{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\ddc1-0227.doc",  replace	
	}
	else{
		outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\ddc1-0227.doc",  append
	}
}

forvalues i =0(1)1{
	areg cit_r1 congr1 lcf hightech small transition minority export rd  i.firmtypexz i.district  i.year  if (ind~= 0 & profit_total_check >0 & above_scale==`i'), absorb(ind) vce(robust)
	if `i'==0{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\scale-0227.doc",  replace	
	}
	else{
		outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\scale-0227.doc",  append
	}
	}

	areg cit_r1 congr1 lcf hightech small transition minority export rd  i.firmtypexz i.district  i.year if (ind~= 0 & profit_total_check >0 & (ind ==3 )),absorb(ind) vce(robust) //-0.025
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\manufacture-0227.doc",replace
areg cit_r1 congr1 lcf hightech small transition minority export rd  i.firmtypexz i.district  i.year if (ind~= 0 & profit_total_check >0 & (ind ~=3 )),absorb(ind) vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\manufacture-0227.doc",append
