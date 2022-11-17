******structure of tax in China *********
****** review ****************************
*** edited 0228
cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data"
use panel0,clear
****vat
* 10 + 14 + 17 +18
/*foreach ln of varlist vat_sales vat_input_17 vat_input_13 vat_input_7 vat_input_less_6 vat {
	replace `ln'=0 if `ln'==.
} */

gen vat_b = vat_sales - (vat_input_17/0.17 + vat_input_13/0.13 + vat_input_7/0.07 + vat_input_less_6/0.04)

gen vat_r = vat /vat_b    // mean = 13%, 峰值在17%左右达到，和陈钊文章得到结果一样
winsor2 vat_r, cut(1 99) replace
twoway (kdensity vat_r if vat_r>0 & vat_r<0.21), by(year)
twoway (kdensity vat_r if vat_r>0 & vat_r<0.21 & year ==2008) (kdensity vat_r if vat_r>0 & vat_r<0.21 & year ==2011),legend(label(1 "2008") label(2 "2011")) graphregion(color(white))

*出口退税
/*foreach ln of varlist vat_ex_rebate export_sales {
	replace `ln'=0 if `ln'==.
}*/
gen ex_r = vat_ex_rebate/export_sales

*消费税 

*营业税
/*foreach ln of varlist busi_base busi_tax{
	replace `ln'=0 if `ln'==.
}*/
*94/87
gen busi_r = busi_tax/busi_base
winsor2 busi_r, cut(1 99) replace
twoway (kdensity busi_r if busi_r>0 & busi_r<0.58),by(year) graphregion(color(white))

twoway (kdensity busi_r if busi_r>0 & busi_r<0.58 & year==2008) (kdensity busi_r if busi_r>0 & busi_r<0.21 & year ==2011),legend(label(1 "2008") label(2 "2011")) graphregion(color(white))

*房产税


* CIT
/*foreach ln of varlist inctax_pre inctax_reduction inctax_credit{
	replace `ln'=0 if `ln'==.
}*/

gen inctax_post_check = inctax_pre-inctax_reduction-inctax_credit 
tab year if inctax_post_check ~=. &inctax_post_check~=0

generate cit_r2 = inctax_post_check/profit_total_check
winsor2 cit_r2, replace cut(1 95)
twoway (kdensity cit_r2 if cit_r2>=0 & cit_r2<0.28 & year==2008 & profit_total_check>0,n(800)) (kdensity cit_r2 if cit_r2>=0 & cit_r2<0.28 & year ==2011 & profit_total_check>0,n(800)),legend(label(1 "2008") label(2 "2011")) graphregion(color(white))
/***
foreach ln of varlist profit_ope_check inctax_post1{
	replace `ln'=0 if `ln'==.
}
gen cit_r = inctax_post1/profit_ope_check
winsor2 cit_r, replace cut(1 95)
twoway (kdensity cit_r if cit_r>0 & cit_r<0.28,n(200)),by(year) graphregion(color(white))

twoway (kdensity cit_r if cit_r>0 & cit_r<0.28 & year==2008) (kdensity cit_r if cit_r>0 & cit_r<0.28 & year ==2011),legend(label(1 "2008") label(2 "2011")) graphregion(color(white))
graph save "Graph" "C:\Users\Benjamin Hwang\Documents\本科生科研\data\tax\data-analysis\results\cit_r08and11.gph"
graph export  "C:\Users\Benjamin Hwang\Documents\本科生科研\data\tax\data-analysis\results\cit_r08and11.png", as(png) name("Graph") */


****** regression ******
cd "C:\Users\Benjamin Hwang\Documents\本科生科研\data\tax\data"

egen varname = group(id)
xtset varname year

*industry  //leave out those with ind==0!!!!
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
 
gen hightech = 0
replace hightech =1 if (hightech_reduction~=. & hightech_reduction>0)

gen small = 0
replace small =1 if (small_reduction~=. & small_reduction>0)

gen transition = 0
replace transition = 1 if(transition_period_reduction ~=. & transition_period_reduction > 0)

gen minority = 0
replace minority = 1 if (minority_reduction ~=. & minority_reduction > 0)

gen export =0
replace export = 1 if (export_sales ~=. & export_sales > 0) 

*table 9 main regression
generate cit_r1 = 100 * cit_r2
gen firmtypexz1 = 0
replace firmtypexz1 = 1 if firmtypexz==1
replace firmtypexz1 = 2 if firmtypexz==2|firmtypexz==3
label variable firmtypexz1 "ownership, 0=民营，1=SOE，2=FOC港澳台"

//gen lasset = log(asset0)

reg  cit_r1  i.ind i.firmtypexz1 i.district lcf hightech small transition minority export asset0 rd i.year if (ind~= 0 & profit_total_check >0 ) ,vce(robust)

outreg2 using reg2.doc,replace

save panel1,replace
