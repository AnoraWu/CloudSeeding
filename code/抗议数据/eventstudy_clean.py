import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import cpca
import os
import math
os.chdir("/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/抗议数据")

df = pd.read_stata("eventstudy_city.dta")
df = df.sort_values(by=['citycode', 'date']).reset_index()
df["day"] = df.groupby("citycode").cumcount()
df['event'] = 0

# Identify events (first protest and subsequent protests >= 3 months apart)
for city, city_df in df.groupby('citycode'):
    protest_dates = city_df.loc[city_df['n_prt_weibo'] > 0, 'day'].sort_values().tolist()
    last_event = None
    
    for protest_date in protest_dates:
        if last_event is None or (protest_date - last_event) >= 45:
            df.loc[(df['citycode'] == int(city)) & (df['day'] == protest_date),'event'] = 1
            last_event = protest_date

index_list = df.loc[df['event']==1,'index'].tolist()
df['to_day']=None
for index in index_list:
    for i in range(-22,24):
        if not (index+i<0) or (index+i>len(df)):
            df.loc[df['index']==index+i,'to_day'] = i

df.to_csv('eventstudy_weibo_city.csv')