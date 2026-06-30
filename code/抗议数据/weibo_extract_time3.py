import pandas as pd
from multiprocessing import Pool

folder_dir  = r"/Users/anorawu/Team MG Dropbox/Wanru Wu/Cloudseeding/data/抗议数据/intermediate"
input_file   = rf"{folder_dir}/extracted_weibo_time2.csv"

df = pd.read_csv(input_file, encoding="utf-8",dtype={"省":"string","市":"string","区":"string"},index_col=False )

df['time2'] = df['time2'].astype(str)
df['time2'] = df['time2'].str.replace("[", "")
df['time2'] = df['time2'].str.replace("]", "")
df['time2'] = df['time2'].str.replace("，", ",")
df['time2'] = df['time2'].str.replace("、", ",")
df['time2'] = df['time2'].str.replace("；", ",")
df['time2'] = df['time2'].str.replace(";", ",")
df['time2'] = df['time2'].str.split(',')

df = df.explode('time2', ignore_index=True)
df[['month1','year1','day1']] = None
df[['month1','year1','day1']] = df[['month1','year1','day1']].astype(str)
df['month1'] = df['time2'].str.extract(r'(\d+)(?=月)')
df['year1'] = df['time2'].str.extract(r'(\d+)(?=年)')
df['day1'] = df['time2'].str.extract(r'(\d+)(?=日)')
df.loc[df['day1'].isna(), 'day1'] = df['time2'].str.extract(r'(\d+)(?=号)')

df1 = df.loc[(df['year1'].isna()) | (df['month1'].isna()) | (df['day1'].isna())].copy()
df1['time1'] = df1['time1'].astype(str)
df1['time1'] = df1['time1'].str.replace("[", "")
df1['time1'] = df1['time1'].str.replace("]", "")
df1['time1'] = df1['time1'].str.replace("，", ",")
df1['time1'] = df1['time1'].str.replace("、", ",")
df1['time1'] = df1['time1'].str.replace("；", ",")
df1['time1'] = df1['time1'].str.replace(";", ",")
df1['time1'] = df1['time1'].str.split(',')

df1 = df1.explode('time1', ignore_index=True)
df1 = df1[df1['time1'].str.contains(r'[号日]', na=False)]

df1.loc[df1['month1'].isna(), 'month1'] = df1['time1'].str.extract(r'(\d+)(?=月)')[0]
df1.loc[df1['year1'].isna(), 'year1'] = df1['time1'].str.extract(r'(\d+)(?=年)')[0]
df1.loc[df1['day1'].isna(), 'day1'] = df1['time1'].str.extract(r'(\d+)(?=日)')[0]
df1.loc[df1['day1'].isna(), 'day1'] = df1['time1'].str.extract(r'(\d+)(?=号)')[0]

# replace year1 = year if year1.isna() or if year1<2010
df1['year1'] = df1['year1'].astype('Int64')
df1['month1'] = df1['month1'].astype('Int64')
df1.loc[df1['year1'].isna() | (df1['year1'] < 2010), 'year1'] = df1['year']
df1.loc[df1['month1'].isna(), 'month1'] = df1['month']

df2 = pd.concat([df,df1])
df2.dropna(subset=['year1', 'month1','day1'],inplace=True)
df2.drop_duplicates(subset=['posts','year1', 'month1','day1'],inplace=True)
df2.to_csv(rf'{folder_dir}/cleaned_time_weibo_protests.csv')