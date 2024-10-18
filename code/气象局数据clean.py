import os
import pandas as pd

os.chdir('/Users/anorawu/Documents/GitHub/CloudSeeding/data/气象局数据')
df = pd.read_csv('data_bureau.csv'.format(num=0), encoding='utf-8')
df=df.drop_duplicates(subset='url')
df=df.drop_duplicates(subset='气象局公告内容')

rows_per_file = 2000  
total_rows = len(df)  
file_count = total_rows // rows_per_file + (1 if total_rows % rows_per_file else 0)  

# Loop through and save each chunk
for i in range(file_count):
    start_row = i * rows_per_file
    end_row = (i + 1) * rows_per_file
    chunk = df[start_row:end_row]
    chunk.to_csv(f"data_bureau_{i+1}.csv", index=False)
