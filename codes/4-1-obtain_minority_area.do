cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\文件"
use citycode.dta,clear

gen minority_area =0
label variable minority_area "民族区域自治地区虚拟变量 1=是"
replace minority_area =1 if(strmatch(cityname,"*自治*")|strmatch(provincename,"*自治*"))

save citycode.dta,replace