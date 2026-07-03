import pandas as pd
import os
os.chdir("/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/抗议数据/final")

df = pd.read_stata("eventstudy_city.dta")
# Corrected a mistake in the next line: added "drop=True". 
# Will not affect the final result as the "eventstudy_city.dta" file is already sorted
df = df.sort_values(by=['citycode', 'date']).reset_index(drop=True)
df["day"] = df.groupby("citycode").cumcount()
df['event'] = 0

# Identify events (first protest and subsequent protests 45 days apart)
for city, city_df in df.groupby('citycode'):
    protest_dates = city_df.loc[city_df['n_prt_weibo'] > 0, 'day'].sort_values().tolist()
    last_event = None
    
    for protest_date in protest_dates:
        if last_event is None or (protest_date - last_event) >= 45:
            df.loc[(df['citycode'] == int(city)) & (df['day'] == protest_date),'event'] = 1
            last_event = protest_date

df['to_day'] = pd.NA
# Corrected a mistake: group the data by 'citycode' before assignning "to_day" variable. 
# Will affect the final result but the regression result difference is indistinguishable.
for city, g in df.groupby('citycode'):
    event_days = g.loc[g['event'] == 1, 'day'].tolist()
    for ed in event_days:
        for i in range(-22, 23):
            mask = (df['citycode'] == city) & (df['day'] == ed + i)
            df.loc[mask, 'to_day'] = i
df.to_csv('eventstudy_weibo_city.csv')