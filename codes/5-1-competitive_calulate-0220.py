# calculate the HHI and CR8 CR20 to obtain the competitiveness in every ind4_index
# edited on 0220 
import numpy as np
import pandas as pd

#obtain the HHI cr8, cr20 in every ind4_index
# 1 cr
data = pd.read_stata('C:/Users/Benjamin Hwang/Documents/undergraduate_research-2021-Zhengwen_Liu/data/tax/data/market0220.dta')

market_scale1 = data.groupby(by=['year','ind4_index'])['sales'].sum()
market_scale2 = data.groupby(by=['year','ind4_index'])['sales_major'].sum() 
data = data.merge(market_scale1,on=['year','ind4_index'],suffixes=('','_ind'))
data = data.merge(market_scale2,on=['year','ind4_index'],suffixes=('','_ind'))
data['market_share1'] = data['sales']/data['sales_ind'] 
data['market_share2'] = data['sales_major']/data['sales_major_ind']
# 1 1.sales  2.sales_major
data = data.sort_values(by = ['year','ind4_index','market_share1'], ascending=[True,False,False])
data['rank1'] = data.groupby(['year','ind4_index'])['market_share1'].rank(method = 'first', na_option = 'bottom', ascending = False)
data = data.sort_values(by = ['year','ind4_index','market_share2'], ascending=[True,False,False])
data['rank2'] = data.groupby(['year','ind4_index'])['market_share2'].rank(method = 'first', na_option = 'bottom', ascending = False)
## sales
data_1cr8 = data.drop(index = data[data['rank1']>8].index)
data_1cr8 = data_1cr8.groupby(['year','ind4_index'])['market_share1'].sum()
data_1cr20 = data.drop(index = data[data['rank1']>20].index)
data_1cr20 = data_1cr20.groupby(['year','ind4_index'])['market_share1'].sum()
data1 = data_1cr8.to_frame()
data1 = data1.merge(data_1cr20,on = ['year','ind4_index'],suffixes=('_8','_20'))  # market_share1_8/20
## sales_major
data_2cr8 = data.drop(index = data[data['rank2']>8].index)
data_2cr8 = data_2cr8.groupby(['year','ind4_index'])['market_share2'].sum()
data_2cr20 = data.drop(index = data[data['rank2']>20].index)
data_2cr20 = data_2cr20.groupby(['year','ind4_index'])['market_share2'].sum()
data2 = data_2cr8.to_frame()
data2 = data2.merge(data_2cr20,on = ['year','ind4_index'],suffixes=('_8','_20')) # market_share2_8/20

data3 = data1.merge(data2, on=['year','ind4_index']) 

# 2 HHI
data_1hhi = data.drop(index = data[data['rank1']>50].index)
data_1hhi['s1'] = data_1hhi['market_share1'] * data_1hhi['market_share1']
data_1hhi = data_1hhi.groupby(['year','ind4_index'])['s1'].sum()
data_2hhi = data.drop(index = data[data['rank2']>50].index)
data_2hhi['s2'] = data_2hhi['market_share2'] * data_2hhi['market_share2']
data_2hhi = data_2hhi.groupby(['year','ind4_index'])['s2'].sum()
data_1hhi = data_1hhi.to_frame()
data_hhi = data_1hhi.merge(data_2hhi,on = ['year','ind4_index'])  # s1 s2

data4 = data3.merge(data_hhi,on=['year','ind4_index'])
data4.rename(columns = {'s1':'hhi1','s2':'hhi2'},inplace=True)
data4.to_stata('C:/Users/Benjamin Hwang/Documents/undergraduate_research-2021-Zhengwen_Liu/data/tax/data/competitiveness0220.dta')