**********************************
*****  异质性检验*****************
*****    edited 0220  ************
**********************************
cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data"
use panel2,clear
gen west = (district==2)
label variable west "西部地区虚拟变量"

********* 2-code  benchmark regression **********
forvalues i =1(1)4{
	gen west_l_cong`i' = west * l_cong`i'  // one term
	gen west_l_congr`i's = west * l_congr`i's // quadratic term
	label variable west_l_cong`i' "交叉项 west * l_cong`i' "
	label variable west_l_congr`i's "交叉项 west * l_congr`i's"
	}

	/*reg results ： 1 ++(good) ; 2 -+(relative good); 3 +- (x) ; 4 ++(relative good)  
*/
foreach lb of varlist l_cong1 l_cong2 l_cong3 l_cong4{
	reg cit_r1 `lb' west_`lb' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
}
forvalues i = 1(1)4{
	if `i'==1{
	reg cit_r1 l_cong`i' west_l_cong`i' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test-west-l_cong.doc",replace
	}
	else{
	reg cit_r1 l_cong`i' west_l_cong`i' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test-west-l_cong.doc",append
	}
}

/* transition result: 1++ 2-+ 3++ 4++ good*/
forvalues i = 1(1)4{
	gen transition_l_cong`i' = transition * l_cong`i' //one term
	label variable transition_l_cong`i' "交叉项 transition * l_cong`i'"
	reg cit_r1 l_cong`i' transition_l_cong`i' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
}
forvalues i =1(1)4{
	if `i'==1{
	reg cit_r1 l_cong`i' transition_l_cong`i' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test-transition-l_cong.doc",replace
	}
	else{
	reg cit_r1 l_cong`i' transition_l_cong`i' i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test-transition-l_cong.doc",append
	}
}

/*minority city  result is bad ...*/ // 结果不好 都不能说明我们的想法
merge m:1 city using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\文件\citycode.dta"
drop _merge
drop cityname provincename
forvalues i = 1(1)4{
	gen minority_area_l_cong`i' = minority_area * l_cong`i' 
	gen minority_area_l_congr`i's = minority_area * l_congr`i's
	label variable minority_area_l_cong`i' "交叉项 minority_area_l_cong`i' "
	label variable minority_area_l_congr`i's "交叉项 minority_area_l_congr`i's"
	
	if `i'==1{
	reg cit_r1 l_cong`i' minority_area_l_cong`i' minority_area i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test-minority_area-l_cong.doc",replace
	}
	else{
	reg cit_r1 l_cong`i' minority_area_l_cong`i' minority_area i.firmtypexz  i.district  lcf hightech small transition minority export rd  i.year  if (ind~= 0 & profit_total_check >0),vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test-minority_area-l_cong.doc",append
	
	}
}  

*****quadratic reg test******************

****1 west test******************
* good reg results
forvalues i = 1(1)4{
	gen west_congr`i' = west * congr`i'
	label variable west_congr`i' "交叉项 west * congr`i' "
	gen west_congr`i's = west * congr`i's
	label variable west_congr`i's "交叉项 west * congr`i's"
	gen west_l_congr`i' = west * l_congr`i' 
	label variable west_l_congr`i' "交叉项 west * l_congr`i' "
	gen west_cong`i' = west * cong`i'
	label variable west_cong`i' "交叉项 west * cong`i' "
}

forvalues i = 1(1)4{

	
	if `i' ==1{
	reg cit_r1 congr`i's congr`i' west_congr`i's west_congr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_west_test-congr1234_quadratic_cit-0219.doc",replace
	}
	else{
	reg cit_r1 congr`i's congr`i' west_congr`i's west_congr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_west_test-congr1234_quadratic_cit-0219.doc",append
	
	}
}  //



forvalues i = 1(1)4{

	
	if `i'==1{
	reg cit_r1 l_congr`i's l_congr`i' west_l_congr`i's  west_l_congr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_west_test-l_congr1234_quadratic_cit-0219.doc",replace
	}
	else{
	reg cit_r1 l_congr`i's l_congr`i' west_l_congr`i's  west_l_congr`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_west_test-l_congr1234_quadratic_cit-0219.doc", append
	}

}  //

forvalues i = 1(1)4{

	
	if `i' ==1{
	reg cit_r1 congr`i's cong`i' west_congr`i's west_cong`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_west_test-cong1234_quadratic_cit-0219.doc",replace
	}
	else{
	reg cit_r1 congr`i's cong`i' west_congr`i's west_cong`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_west_test-cong1234_quadratic_cit-0219.doc",append	
	}
}  //

forvalues i = 1(1)4{
	
	if `i'==1{
	reg cit_r1 l_congr`i's l_cong`i' west_l_congr`i's west_l_cong`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_west_test-l_cong1234_quadratic_cit-0219.doc",replace
	}
	else{
	reg cit_r1 l_congr`i's l_cong`i' west_l_congr`i's west_l_cong`i' i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_west_test-l_cong1234_quadratic_cit-0219.doc",append
	}

}  // 我觉得以上的交乘项回归没有得到很好的效果

* 分组回归 heterogeneous test******************
* benchmark regression test******************
* 1 - district
forvalues i = 0(1)3{
	reg cit_r1 l_cong1 i.firmtypexz lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & district ==`i'), vce(robust)
	if `i'==0{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_district-l_cong1-cit-0219.doc",replace	
	}
	else{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_district-l_cong1-cit-0219.doc",append
	}
} // middle 》east》west》northeast  (解释：东北国企比例最高，达7.9%)

gen soe = (firmtypexz == 1)

* 2 - ownership
forvalues i = 0(1)3{
	reg cit_r1 l_cong1 i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & firmtypexz==`i'), vce(robust)
	if `i'==0{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_ownership-l_cong1-cit-0219.doc",replace
	}
	else{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_ownership-l_cong1-cit-0219.doc",append
	}
}  //对民营企业依照比较优势给予补贴 但是对于国有企业可能更多服务于赶超战略（policy burden） 对于港澳台外资--本身资本来自于城市外-与当地的禀赋结构关系更浅


* 3 - 产业是否更加更适应于当地的比较优势  --- 结果很好，成功靠近了当地禀赋结构决定的CA的产业的企业对象有的特征--越符合比较优势收到的税负越低
forvalues i =0(1)1{
	reg cit_r1 l_cong1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & ddcr1 ==`i'), vce(robust)
	if `i'==0{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_ddcr1_ddlcr1-l_cong1-cit-0219.doc",replace
	}
	else{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_ddcr1_ddlcr1-l_cong1-cit-0219.doc",append
	}
	
	reg cit_r1 l_cong1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & ddlcr1 ==`i'), vce(robust)
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_ddcr1_ddlcr1-l_cong1-cit-0219.doc",append
}

* 4 规模大和规模小企业
gen above_scale = (sales_major > 5e+3)
label variable above_scale "规模以上企业 dummy"
replace above_scale =. if sales_major==.

forvalues i =0(1)1{
	reg cit_r1 l_cong1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & above_scale==`i'), vce(robust) 
		if `i'==0{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_ddcr1_above_scale-l_cong1-cit-0219.doc",replace
	}
	else{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_ddcr1_above_scale-l_cong1-cit-0219.doc",append
	}

}  // 很符合我的预期： 小规模企业更依照比较优势进行补贴  小规模--1.79  大--0.76

* quadratic regression test******************
* 1 district
forvalues i = 0(1)3{
	reg cit_r1 congr1s congr1 i.firmtypexz lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & district ==`i'), vce(robust)
	reg cit_r1 l_congr1s l_congr1 i.firmtypexz lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & district ==`i'), vce(robust)
	/*if `i'==1{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_district-l_cong1-cit-0219.doc",replace	
	}
	else{
	outreg2 using "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data-analysis\results\4-NSE_heterogeneous_test-0219\heter_test_district-l_cong1-cit-0219.doc",append
	}*/
} //用第一个指标；东北不合适 中部 西部 东部 都较为合适 

* 2 ownership
forvalues i = 0(1)3{
	reg cit_r1 congr1s congr1 i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & firmtypexz==`i'), vce(robust)
	reg cit_r1 l_congr1s l_congr1 i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & firmtypexz==`i'), vce(robust)
} // 用l_congr1 （第二个指标） 来说； 民企的税负符合CA，国企次之，港台、外资就不太符合当地CA


* 3 产业是否更加更适应于当地的比较优势 
forvalues i = 0(1)1{
	reg cit_r1 congr1s congr1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & ddcr1 ==`i'), vce(robust)
	reg cit_r1 l_congr1s l_congr1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & ddcr1 ==`i'), vce(robust)
}  // 用第一个指标可以说 发展更好的产业是按照CA的补贴政策
forvalues i = 0(1)1{
	reg cit_r1 congr1s congr1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & ddlcr1 ==`i'), vce(robust)
	reg cit_r1 l_congr1s l_congr1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & ddlcr1 ==`i'), vce(robust)
} // 这组回归ddlcr1和ddcr1 其实是一样的结果，所以选一个输出就行了

* 4 规模大和规模小企业
forvalues i = 0(1)1{
	reg cit_r1 congr1s congr1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & above_scale ==`i'), vce(robust)
	reg cit_r1 l_congr1s l_congr1 i.firmtypexz i.district lcf hightech transition minority export i.year if (ind~= 0  & profit_total_check >0 & above_scale ==`i'), vce(robust)
}  //用第二个指标 l_congr1 ; 小规模企业得到的符合CA补贴更加显著 
