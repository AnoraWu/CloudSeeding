import pandas as pd

folder = "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/气象局数据/人工处理"
input_dir = f"{folder}/result_with_text.csv"

df = pd.read_csv(input_dir)

# 利用正则提取发布时间信息
df['time1'] = df['气象局公告内容'].str.extract(r'(发布时间：20\d{2}-\d{2}-\d{2})')
df['time1.5'] = df['气象局公告内容'].str.extract(r'(发布时间:\s20\d{2}-\d{2}-\d{2})')
df['time2'] = df['气象局公告内容'].str.extract(r'(发布日期：20\d{2}-\d{2}-\d{2})')
df['time3'] = df['气象局公告内容'].str.extract(r'(发布时间：\s*20\d{2}年\d{1,2}月\d{1,2}日)')
df['time4'] = df['气象局公告内容'].str.extract(r'(发布日期：\s*20\d{2}年\d{1,2}月\d{1,2}日)')
df['time5'] = df['气象局公告内容'].str.extract(r'(时间：20\d{2}-\d{2}-\d{2})')
df['time6'] = df['气象局公告内容'].str.extract(r'(日期：20\d{2}-\d{2}-\d{2})')
df['time7'] = df['气象局公告内容'].str.extract(r'(发布时间：\s*20\d{2}-\d{2}-\d{2})')
df['time8'] = df['气象局公告内容'].str.extract(r'(发布日期：\s*20\d{2}-\d{2}-\d{2})')
df['time9'] = df['气象局公告内容'].str.extract(r'(20\d{2}-\d{2}-\d{2} \d{2}:\d{2})')
df['time10'] = df['气象局公告内容'].str.extract(r'(人工增雨作业公告（20\d{2}\.\d{2}\.\d{2}）)')
df['time11'] = df['气象局公告内容'].str.extract(r'(人工增雨作业\s20\d{2}-\d{2}-\d{2})')
df['time12'] = df['气象局公告内容'].str.extract(r'(时间：20\d{2}年\d{2}月\d{2}日)')
df['time13'] = df['气象局公告内容'].str.extract(r'(日期：20\d{2}年\d{2}月\d{2}日)')

df[['time','location','index','time1','time1.5','time2',
    'time3','time4','time5','time6','time7','time8','time9',
    'time10','time11','time12','time13']].to_csv(f"{folder}/披露时间only.csv")

df2 = pd.read_csv(f"{folder}/披露时间only_cleaned.csv")
df['issue_time'] = df2[['time1','time1-5','time2','time3','time4','time5',
                        'time6','time7','time8','time9','time10','time11',
                        'time12','time13']].fillna(method='bfill', axis=1).iloc[:, 0]
df[['time','location','index','气象局公告内容','issue_time']].to_csv(f"{folder}/result_text_issuetime.csv")

df3 = df[df['issue_time'].isna()]
df3.drop_duplicates(subset=['气象局公告内容'],inplace=True)
df3.to_csv(f"{folder}/need_manual_issue_time.csv")

df4 = pd.read_csv("/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/气象局数据/data_bureau.csv")
df4["气象局公告内容"] = df4["气象局公告内容"].str.replace(r'\s+', ' ', regex=True)
df4.drop_duplicates(inplace=True)
df5 = df3.merge(df4, on='气象局公告内容', how='left')
df5.to_csv(f"{folder}/need_manual_issue_time_url.csv")
