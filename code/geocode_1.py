import requests
import pandas as pd
import logging

# 设置日志文件和日志级别
logging.basicConfig(filename='geocode_log.txt', level=logging.ERROR, format='%(asctime)s - %(message)s')

# 读取 CSV 文件
df = pd.read_csv('geocode.csv')

# 高德地图 API 配置
api_key = '9deaf41d592ad149cdc6f36dbe95e835'
geocode_url = 'https://restapi.amap.com/v3/geocode/geo'

# 创建新列 'location'（如果还不存在）
if 'location' not in df.columns:
    df['location'] = ''

# 读取上次处理到的索引位置
start_index = 0
try:
    with open('geocode_index.txt', 'r') as f:
        start_index = int(f.read().strip())
except FileNotFoundError:
    pass

# 通过地理编码获取经纬度
for index, row in df.iloc[start_index:].iterrows():
    try:
        params = {
            'address': row['geo_area'],
            'key': api_key,
            'output': 'JSON'
        }
        response = requests.get(geocode_url, params=params)
        data = response.json()

        if data['status'] == '1' and len(data['geocodes']) > 0:
            df.at[index, 'location'] = data['geocodes'][0]['location']
        else:
            df.at[index, 'location'] = 'Not Found'

        # 实时显示进度
        print(f"Processed {index + 1}/{len(df)}: {row['geo_area']} -> {df.at[index, 'location']}")

        # 实时保存到文件
        df.to_csv('geocode.csv', index=False)

    except Exception as e:
        logging.error(f"Error processing row {index}: {e}")
        print(f"Error processing row {index}: {e}")
        df.at[index, 'location'] = 'Error'

        # 保存当前索引
        with open('geocode_index.txt', 'w') as f:
            f.write(str(index))

        # 保存错误后进度
        df.to_csv('geocode.csv', index=False)
        continue

# 保存最终索引，以便后续继续处理
with open('geocode_index.txt', 'w') as f:
    f.write(str(len(df) - 1))

print("Processing complete!")
