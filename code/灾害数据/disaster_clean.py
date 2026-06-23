import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import cpca
import os
os.chdir("/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/灾害数据/rawdata")
df = pd.read_stata("自然灾害事件_since_2014_CN.dta")

# regenerate the hails event
df = df[df['Summary'].str.contains('雹', na=False)]
df = df[['EventStartDate','ProvinceCode','Areas','Province','City']]

# clean the data
df['City'] = df['City'].str.replace("、",",")
df['City'] = df['City'].str.replace("，",",")
df['City'] = df['City'].str.split(',')
df = df.explode('City')

# find the adcode
df.reset_index(drop=True,inplace=True)
df['adcode'] = cpca.transform(df["City"])['adcode']

data = df[~df['adcode'].isna() & (df['ProvinceCode'].astype(str).str[:2] == df['adcode'].astype(str).str[:2])]
# Drop rows where last four digits of adcode are "0000", except for specified values
mask = (data['adcode'].astype(str).str[-4:] == "0000") & (~data['adcode'].astype(str).isin(["120000", "110000", "500000", "310000"]))
data = data[~mask]
# Drop empty start date events
data = data[data['EventStartDate']!=""]

# Generate citycode2 from the first four digits of adcode
data['citycode2'] = data['adcode'].astype(str).str[:4]
#省直辖的单独算一个城市
data.reset_index(drop=True,inplace=True)
data['citycode3'] = data['adcode'].astype(str).str[2:4]
data.loc[data['citycode3'] == "90", 'citycode2'] = data['adcode'].astype(str)
data['citycode2'] = data['citycode2'].astype(int)

# Adjust citycode2 for direct-controlled municipalities
for code, new_code in zip(["11", "12", "31", "50"], [1100, 1200, 3100, 5000]):
    data.loc[data['citycode2'].astype(str).str[:2] == code, 'citycode2'] = new_code

os.chdir("/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/灾害数据")
data.to_csv("disaster_adcode_hails.csv")
