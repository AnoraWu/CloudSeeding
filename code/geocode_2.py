import requests
import pandas as pd
import logging

# 设置日志文件和日志级别
logging.basicConfig(filename='geocode_log.txt', level=logging.ERROR, format='%(asctime)s - %(message)s')

# 读取 CSV 文件
df = pd.read_csv('geocode.csv')

# 高德地图 API 配置
api_key = '9deaf41d592ad149cdc6f36dbe95e835'
regeocode_url = 'https://restapi.amap.com/v3/geocode/regeo'

# 创建新列 'prov_geo', 'city_geo', 'county_geo'（如果还不存在）
for col in ['prov_geo', 'city_geo', 'county_geo']:
    if col not in df.columns:
        df[col] = ''

# 读取上次处理到的索引位置
start_index = 0
try:
    with open('geocode_index.txt', 'r') as f:
        start_index = int(f.read().strip())
except FileNotFoundError:
    pass

# 通过逆地理编码获取省、市、区信息
for index, row in df.iloc[start_index:].iterrows():
    try:
        if row['location'] != 'Not Found':
            params = {
                'location': row['location'],
                'key': api_key,
                'output': 'JSON'
            }
            response = requests.get(regeocode_url, params=params)
            data = response.json()

            if data['status'] == '1':
                address_component = data['regeocode']['addressComponent']
                df.at[index, 'prov_geo'] = address_component.get('province', 'Not Found')
                df.at[index, 'city_geo'] = address_component.get('city', address_component.get('province', 'Not Found'))
                df.at[index, 'county_geo'] = address_component.get('district', 'Not Found')
            else:
                df.at[index, 'prov_geo'] = 'Not Found'
                df.at[index, 'city_geo'] = 'Not Found'
                df.at[index, 'county_geo'] = 'Not Found'
        else:
            df.at[index, 'prov_geo'] = 'Not Found'
            df.at[index, 'city_geo'] = 'Not Found'
            df.at[index, 'county_geo'] = 'Not Found'

        # 实时显示进度
        print(f"Processed {index + 1}/{len(df)}: Location -> {row['location']}, Province -> {df.at[index, 'prov_geo']}, City -> {df.at[index, 'city_geo']}, District -> {df.at[index, 'county_geo']}")

        # 实时保存到文件
        df.to_csv('geocode1_with_district.csv', index=False)

    except Exception as e:
        logging.error(f"Error processing row {index}: {e}")
        print(f"Error processing row {index}: {e}")
        df.at[index, 'prov_geo'] = 'Error'
        df.at[index, 'city_geo'] = 'Error'
        df.at[index, 'county_geo'] = 'Error'

        # 保存当前索引
        with open('geocode_index.txt', 'w') as f:
            f.write(str(index))

        # 保存错误后进度
        df.to_csv('geocode1_with_district.csv', index=False)
        continue

# 保存最终索引，以便后续继续处理
with open('geocode_index.txt', 'w') as f:
    f.write(str(len(df) - 1))

print("Processing complete!")
