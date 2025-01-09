import pandas as pd
import geopandas as gpd
import os
from geopy import distance
import calendar

# 设置路径和读取数据
os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding/data/炮台数据")

# 加载炮台数据
fort_data = pd.read_csv("cleaned_炮台数据.csv")
fort_data = fort_data[fort_data['year'] <= 2022]

lon_max = fort_data['longitude'].max() + 1
lon_min = fort_data['longitude'].min() - 1
lat_max = fort_data['latitude'].max() + 1
lat_min = fort_data['latitude'].min() - 1

fort_points = fort_data[['index', 'longitude', 'latitude']].drop_duplicates()

# 加载气象站数据
rain_data = pd.read_stata("weatherstation_2010_2022.dta")
rain_data = rain_data.dropna(subset=['Lat', 'Lon'])
rain_data = rain_data[(rain_data['Lat'] >= lat_min) & (rain_data['Lat'] <= lat_max)]
rain_data = rain_data[(rain_data['Lon'] >= lon_min) & (rain_data['Lon'] <= lon_max)]

rain_points = rain_data[['StationId', 'Lon', 'Lat']].drop_duplicates()

# 转换为GeoDataFrame
rain_gdf = gpd.GeoDataFrame(
    rain_points,
    geometry=gpd.points_from_xy(rain_points['Lon'], rain_points['Lat']),
    crs="EPSG:4326"
)

fort_gdf = gpd.GeoDataFrame(
    fort_points,
    geometry=gpd.points_from_xy(fort_points['longitude'], fort_points['latitude']),
    crs="EPSG:4326"
)

# 定义半径和变量
radius = 0.5
columns = ['Alti', 'EVP', 'GST_Avg', 'GST_Max', 'GST_Min', 'PRE_Max_1h',
           'PRE_Time_2008', 'PRE_Time_0820', 'PRE_Time_2020', 'PRS_Avg', 'PRS_Max',
           'PRS_Min', 'RHU_Avg', 'RHU_Min', 'SSH', 'TEM_Avg', 'TEM_Max', 'TEM_Min',
           'WIN_S_2mi_Avg', 'WIN_S_10mi_Avg', 'WIN_D_S_Max', 'WIN_S_Max',
           'WIN_D_INST_Max', 'WIN_S_Inst_Max']

# 预计算炮台到气象站的距离
nearest_dict = {}

for _, fort_point in fort_gdf.iterrows():
    # 查找半径内的气象站
    buffer = fort_point.geometry.buffer(radius)
    pts_inside = rain_gdf[rain_gdf.within(buffer)]
    
    # 计算距离并存储
    pts_dic = {}
    for _, row in pts_inside.iterrows():
        dist = distance.distance(
            (fort_point.geometry.y, fort_point.geometry.x),
            (row['Lat'], row['Lon'])
        ).km
        pts_dic[row['StationId']] = dist
    
    # 按距离排序
    sorted_pts = sorted(pts_dic.items(), key=lambda item: item[1])
    nearest_dict[fort_point['index']] = sorted_pts

# 数据插值
result_list = []

for year in range(2011, 2023):
    for month in range(1, 13):
        days_in_month = calendar.monthrange(year, month)[1]
        for day in range(1, days_in_month + 1):
            for _, fort_point in fort_points.iterrows():
                index = fort_point['index']
                pts_list = nearest_dict[index]  # 获取附近站点

                weighted_sum = {col: 0 for col in columns}
                weight_total = {col: 0 for col in columns}

                # 遍历最近站点
                for rain_id, dist in pts_list:
                    # 筛选当天数据
                    filtered_row = rain_data[
                        (rain_data['Year'] == year) &
                        (rain_data['Mon'] == month) &
                        (rain_data['Day'] == day) &
                        (rain_data['StationId'] == rain_id)
                    ]

                    # 遍历每个变量，按需求选择最近的4个非缺失值站点
                    for col in columns:
                        value = filtered_row[col].values
                        if len(value) > 0 and pd.notna(value[0]):  # 确保值存在
                            weight = 1 / (dist ** 2)
                            weighted_sum[col] += value[0] * weight
                            weight_total[col] += weight

                    # 检查是否已找到4个有效站点
                    if sum([1 for w in weight_total.values() if w > 0]) >= 4:
                        break  # 已找到4个有效站点，停止循环

                # 计算加权平均
                final_values = {}
                for col in columns:
                    if weight_total[col] > 0:  # 确保有有效数据
                        final_values[col] = weighted_sum[col] / weight_total[col]
                    else:
                        final_values[col] = pd.NA  # 没有足够数据保持NaN

                # 存储结果
                final_values['index'] = index
                final_values['year'] = year
                final_values['month'] = month
                final_values['day'] = day
                result_list.append(final_values)

# 转换为DataFrame并保存
result_df = pd.DataFrame(result_list)
result_df.to_csv("merged_fort_weather.csv", index=False)