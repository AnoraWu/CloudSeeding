import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import cpca
import os

### cpca is a package (https://github.com/laofahai/cpca-rs) that detects and extracts the province, city, and county information in China
### I used the Dec 2025 version of the package

# cropping columns we want to use to avoid import error
df1 = pd.read_csv("/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/抗议数据/rawdata/RFA_protest3.csv",encoding='utf-8')
df1 = df1[['adcode','location','size_level','year','month','day','citycode','省','市','区']]
df1.to_csv("/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/抗议数据/intermediate/RFA_protest3_cropped.csv",index=False)

# generate the code variable
df2 = pd.read_stata("/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding/Cloud Seeding/data/tem/cloudseeding.dta")
df2["district"] = df2['prov'] + df2['city'] + df2['county']
df_adcode2 = cpca.transform(df2["district"])
df2['adcode'] = df_adcode2['adcode']
df2.to_csv("/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/抗议数据/intermediate/cloudseeding_adcode.csv")

# generate the code variable
# the Meteorological.dta was updated in Feb 2025, while previously I used the Jan 2025 version of it.
# So the precipitation data might not be the same.
# You can use the Feb 2025 version by running the following commented line
# df3 = pd.read_stata("/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding/Cloud Seeding/data/raw/meteorological data/Meteorological.dta")
df3 = pd.read_stata("/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/抗议数据/rawdata/Meteorological.dta")
df3["district"] = df3['prov'] + df3['city'] + df3['county']
df_adcode3 = cpca.transform(df3["district"])
df3['adcode'] = df_adcode3['adcode']
df3.to_csv("/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/抗议数据/intermediate/meteorological_adcode.csv")
