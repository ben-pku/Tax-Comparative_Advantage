***************//2022.2.5 encoding//希望是最后一次整理数据
**********************************************************	
	clear //在转码之前需要将STATA内存中的数据清空
	cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data" 
	unicode encoding set gb18030  //将文本编码设置为中文
	unicode analyze b0xxb_2011.dta
	unicode translate b0xxb_2011.dta, invalid
	//unicode retranslate taxdata_2009.dta, transutf8 replace
	
	
	clear //在转码之前需要将STATA内存中的数据清空
	cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data" 
	unicode encoding set gb18030  //将文本编码设置为中文
	unicode analyze b0xxb_2010.dta
	unicode translate b0xxb_2010.dta, invalid
	//unicode retranslate taxdata_2009.dta, transutf8 replace
	
	clear //在转码之前需要将STATA内存中的数据清空
	cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data" 
	unicode encoding set gb18030  //将文本编码设置为中文
	unicode analyze b0xxb_2009.dta
	unicode translate b0xxb_2009.dta, invalid
	//unicode retranslate taxdata_2009.dta, transutf8 replace
	
	clear //在转码之前需要将STATA内存中的数据清空
	cd "C:\Users\Benjamin Hwang\Documents\undergraduate_research-2021-Zhengwen_Liu\data\tax\data" 
	unicode encoding set gb18030  //将文本编码设置为中文
	unicode analyze b0xxb_2008.dta
	unicode translate b0xxb_2008.dta, invalid
	//unicode retranslate taxdata_2009.dta, transutf8 replace

*******tax data clean 20220206  ***huang Zhuokai****
*******last time brand-new
cd "C:\Users\Benjamin Hwang\Documents\本科生科研\data\tax\data"
forvalues y = 2008(1)2011{
	
	use b0xxb_`y',clear
	keep year nsrsbh	nsrmc	hylb	djzclx	lsgx	yqdm	ssqy	gpdm	dqdm	zzsjnfs	zzsyhzc	zzsckts	jgmylb	jgmyywlx	sdsjnfs	sdszsjg	kysjn	kysjy	yyzt	dz	nsrsbh_xg ///
		zzs_xse	zzs_jzjtxse	zzs_jxse17	zzs_jxse13	zzs_jxse7	zzs_jxse6	zzs_yns	zzs_jzjt	zzckts_xse	zzckts_msxse	zzckts_sbmsxse	zzckts_mdtse	zzckts_stxfse	zzckts_ynjkgs	zzckts_ynckgs	xfs_yj	yys_jzsr	yys_yj	fcs_zyyjse	fcs_czyjse	cztdsys_yjse	ccs_yjse	tdzzs_ynse	gds_ynse	dfs_ynzys	dfs_yncsjss	dfs_ynyys	dfs_ynclgzs	dfs_yngrsds	dfs_yndkdjgrsds	dfs_yndkdjlxsds	dfs_qyyngrsds	dfs_ynyhs	sds_mbyqks	sds_ynssde	sds_sl25	sds_yjsdse	sds_jmsdse	sds_xwqy	sds_gxqy	sds_mzqydfs	sds_gdqyh	sds_xbdkf	sds_rjcy	sds_tzjj	sds_wstzqy	sds_xgzjy	sds_qtyh	sds_dmsdse	sds_hbtzdm	sds_jntzdm	sds_aqtzdm	sds_qtdm	sds_yjse	sds_srsrze	sds_srmssr	sds_srsl	sds_sryj	sds_cbcbze	sds_cbsl	sds_cbyj	sds_jfzcze	sds_jfsl	sds_jfsr	sds_jfyj	sds_yjsl	sds_yjyjse	sds_yjjmse	sds_yjyjsdse	sds_yjybse	sds_jdsjjne4	lrb_yysr	lrb_zysr	lrb_qtsr	lrb_xcpfy	lrb_yylr	lrb_yywsr	lrb_btsr	lrb_lrze	lrb_jlr	zcb_zcncs	zcb_cch	zcb_zcnms	zcb_mch	zcb_mgdzcjz	zcb_fzncs	zcb_fznms	zcb_mldfz	xjb_zfzg	xjb_zfzzs	xjb_zfsds	xjb_zfqt	qt_zjgdzc	qt_zjjygdzc	qt_wghw	qt_lxzzc	qt_jtgzjj	qt_jtsbfl	qt_nczgs	qt_nmzgs	qt_npjzgs	qt_zcz	qt_zjz	qt_dlxfl	qt_mtxfl	qt_yxfl	qt_sxfl sds_sjyjsdse

	*rename xxb
	rename	nsrsbh	id
	rename	nsrmc	name
	rename	hylb	cic4
	rename	djzclx	type
	rename	lsgx	sub_to
	rename	yqdm	central_id
	rename	ssqy	IPO_region
	rename	gpdm	stock_code
	rename	dqdm	region
	rename	zzsjnfs	vat_pay_way
	rename	zzsyhzc	vat_fav_code
	rename	zzsckts	vat_ex_rebate_code
	rename	jgmylb	process_trade_code
	rename	jgmyywlx	process_trade_type
	rename	sdsjnfs	inc_pay_way
	rename	sdszsjg	inc_collect_office
	rename	kysjn	setup_y
	rename	kysjy	setup_m
	rename	yyzt	operating
	rename	dz	region_name
	rename	nsrsbh_xg	post_id

	*rename b0
	rename	zzs_xse	vat_sales
	rename	zzs_jzjtxse	vat_sales_return
	rename	zzs_jxse17	vat_input_17
	rename	zzs_jxse13	vat_input_13
	rename	zzs_jxse7	vat_input_7
	rename	zzs_jxse6	vat_input_less_6
	rename	zzs_yns	vat
	rename	zzs_jzjt	vat_return
	rename	zzckts_xse	export_sales
	rename	zzckts_msxse	export_return_sales
	rename	zzckts_sbmsxse	export_return_sales_report
	rename	zzckts_mdtse	vat_ex_rebate
	rename	zzckts_stxfse	con_ex_rebate
	rename	zzckts_ynjkgs	import_tariff
	rename	zzckts_ynckgs	export_tariff
	rename	xfs_yj	con_tax
	rename	yys_jzsr	busi_base
	rename	yys_yj	busi_tax
	rename	fcs_zyyjse	est_base
	rename	fcs_czyjse	est_tax
	rename	cztdsys_yjse	land_tax
	rename	ccs_yjse	ve_tax
	rename	tdzzs_ynse	land_a_tax
	rename	gds_ynse	farmland_tax
	rename	dfs_ynzys	resource_tax
	rename	dfs_yncsjss	city_main_tax
	rename	dfs_ynyys	tobacco_tax
	rename	dfs_ynclgzs	ve_purchase_tax
	rename	dfs_yngrsds	p_inctax
	rename	dfs_yndkdjgrsds	p_inctax1
	rename	dfs_yndkdjlxsds	p_inctax2
	rename	dfs_qyyngrsds	p_inctax3
	rename	dfs_ynyhs	stamp_tax
	rename	sds_mbyqks	loss_carry
	rename	sds_ynssde	inctax_base
	rename	sds_sl25	inctax_rate
	rename	sds_yjsdse	inctax_pre
	rename	sds_jmsdse	inctax_reduction
	rename	sds_xwqy	small_reduction
	rename	sds_gxqy	hightech_reduction
	rename	sds_mzqydfs	minority_reduction
	rename	sds_gdqyh	transition_period_reduction
	rename	sds_xbdkf	west_development_reduction
	rename	sds_rjcy	software_circuit_reduction
	rename	sds_tzjj	stock_reduction
	rename	sds_wstzqy	foreign_reduction
	rename	sds_xgzjy	unemployment_reduction
	rename	sds_qtyh	other_reduction1
	rename	sds_dmsdse	inctax_credit
	rename	sds_hbtzdm	environment_credit
	rename	sds_jntzdm	saving_credit
	rename	sds_aqtzdm	safety_credit
	rename	sds_qtdm	other_credit
	rename	sds_yjse	inctax_post
	rename	sds_srsrze	inc_all_2
	rename	sds_srmssr	inc_notax_2
	rename	sds_srsl	inc_rate_2
	rename	sds_sryj	inctax_incbase_2
	rename	sds_cbcbze	cost_2
	rename	sds_cbsl	inc_cost_rate_2
	rename	sds_cbyj	inctax_costbase_2
	rename	sds_jfzcze	exp_2
	rename	sds_jfsl	inctax_exp_rate_2
	rename	sds_jfsr	income_2
	rename	sds_jfyj	inctax_expbase_2
	rename	sds_yjsl	inc_rate2
	rename	sds_yjyjse	inctax_check1
	rename	sds_yjjmse	inc_tax_reduction_2
	rename	sds_yjyjsdse	inc_tax_paid_2
	rename	sds_yjybse	inc_tax_payable_2
	rename	sds_jdsjjne4	inctax_check2
	rename	lrb_yysr	sales
	rename	lrb_zysr	sales_major
	rename	lrb_qtsr	sales_minor
	rename	lrb_xcpfy	rd
	rename	lrb_yylr	profit_ope_check
	rename	lrb_yywsr	no_op_inc
	rename	lrb_btsr	subsidy
	rename	lrb_lrze	profit_total_check
	rename	lrb_jlr	profit_posttax
	rename	zcb_zcncs	asset0
	rename	zcb_cch	inventory0
	rename	zcb_zcnms	asset1
	rename	zcb_mch	inventory1
	rename	zcb_mgdzcjz	fixasset
	rename	zcb_fzncs	debt_ini
	rename	zcb_fznms	debt_end
	rename	zcb_mldfz	debt_end_cur
	rename	xjb_zfzg	wage
	rename	xjb_zfzzs	vat_check
	rename	xjb_zfsds	inctax_check4
	rename	xjb_zfqt	othertax
	rename	qt_zjgdzc	invest
	rename	qt_zjjygdzc	invest_fix
	rename	qt_wghw	material
	rename	qt_lxzzc	interest_exp
	rename	qt_jtgzjj	wage_check
	rename	qt_jtsbfl	welfare
	rename	qt_nczgs	employ_begin
	rename	qt_nmzgs	employ_end
	rename	qt_npjzgs	employ_mean
	rename	qt_zcz	output
	rename	qt_zjz	va
	rename	qt_dlxfl	electricity
	rename	qt_mtxfl	coal
	rename	qt_yxfl	oil
	rename	qt_sxfl	water
	rename sds_sjyjsdse inctax_post1




	save b0xxb_`y'_1.dta, replace
}

use b0xxb_2008_1,clear
append using b0xxb_2009_1
append using b0xxb_2010_1
append using b0xxb_2011_1
save panel0.dta,replace

