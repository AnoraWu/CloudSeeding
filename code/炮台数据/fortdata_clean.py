"""
Script Name: fortdata_clean.py
Author: Wanru Wu
Date: Jan 2, 2025
Purpose: Extract fort location information
"""

import csv
import logging
import sys
import json
import ollama
import pandas as pd
import os
import re
import numpy as np
import requests
import shapely
import pyproj
import geopandas as gpd
from shapely.geometry import Point
from joblib import Parallel, delayed  # For parallel processing


def get_qwen_response_1(text):
    """
    Return the fort location text information using QWEN AI model
    Args: 
        text (str): weibo text
    Returns:
        string: 
    """
    # 构造prompt
    prompt = f"""目标：请帮助我返回“{text}”中所有的作业点或者炮台信息。
    不要返回除了作业点或者炮台之外的任何信息。
    如果没有作业点或者炮台信息，返回"None"
    """

    response = ollama.chat(model="qwen2:7b", messages=[
        {
            "role": "user",
            "content": prompt,
        },
    ])
    result = response['message']['content']
    return result

def get_qwen_response_2(city,area):
    # 构造prompt
    prompt = f"""目标：请帮助我根据“{city},{area}”返回所有具体位置信息，多条信息用逗号隔开。
    不要返回其他任何信息。
    例子1：city='上饶市',area='许村，中云等周边乡镇'，请返回：'上饶市许村，上饶市中云'。
    例子2：city='岳阳市‘,area=‘经开区康王，梅溪、君山柳林洲、南湖新区风雨山、临湘聂市镇、江南镇、长安街道’，请返回：
    '岳阳市经开区康王, 岳阳市梅溪，岳阳市君山柳林洲，岳阳市南湖新区风雨山，岳阳市临湘聂市镇，岳阳市江南镇，岳阳市长安街道'
    """

    response = ollama.chat(model="qwen2:7b", messages=[
        {
            "role": "user",
            "content": prompt,
        },
    ])
    result = response['message']['content']
    return result

# Function to process one month of cloud data
def process_month(year, month, data, cloud_dir):
    print(f"Processing Year: {year}, Month: {month}")
    
    # Load cloud data
    file_path = cloud_dir + "/" + str(year) + "/" + f"MODIS{year}{month:02d}.dta"  # Zero-pad month
    if not os.path.exists(file_path):  # Check if file exists
        print(f"File not found: {file_path}")
        return None
    
    cloud_df = pd.read_stata(file_path)
    if (year == 2020) & (month == 6):
        cloud_df = cloud_df[cloud_df['day'] != 31]
    cloud_df['date'] = pd.to_datetime(cloud_df[['year', 'month', 'day']])  # Combine year, month, day
    cloud_df['geometry'] = cloud_df.apply(lambda row: Point(row['longitude'], row['latitude']), axis=1)
    cloud_gdf = gpd.GeoDataFrame(cloud_df, geometry='geometry')
    cloud_gdf.set_crs("EPSG:4326", inplace=True)  # Ensure CRS matches

    # Filter location data and cloud data by the same day
    matched_data = []
    unique_dates = cloud_gdf['date'].unique()

    for date in unique_dates:
        location_chunk = data[data['date'] == date]
        cloud_chunk = cloud_gdf[cloud_gdf['date'] == date]
        if location_chunk.empty or cloud_chunk.empty:
            continue

        # Perform spatial join
        matched = gpd.sjoin(cloud_chunk, location_chunk, predicate='within', how='inner')
        matched_data.append(matched)

    # Return combined results for this month
    if matched_data:
        return pd.concat(matched_data, ignore_index=True)
    else:
        print(f"No data to process for Year: {year}, Month: {month}")
        return None


if __name__ == "__main__":
    os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding/data/炮台数据")
    df = pd.read_csv("炮台数据.csv", encoding="utf-8")
    for index, row in df.iterrows():
        df.loc[index,'area'] = get_qwen_response_1(df.loc[index,'微博内容'])
        print(get_qwen_response_1(df.loc[index,'微博内容']))
    df.to_csv('炮台数据_qwen.csv')
    df.rename(columns={"微博内容": "weibo_text"},inplace=True)

    os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding/data")
    df_county = pd.read_stata('微博数据_with time and location.dta') # comes from Young
    df_merge = pd.merge(df,df_county,how='inner',on='weibo_text')
    df_merge = df_merge[['weibo_text','operation_year', 'operation_month', 'operation_day','prov', 'city', 'county','area']]

    os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding/data/炮台数据")
    df_merge.to_csv('炮台数据_merged_county.csv')

    df_merge_nodup = df_merge.drop_duplicates(subset=['weibo_text','city'])
    df_merge_nodup['location'] = df_merge_nodup['area']

    for index, row in df_merge_nodup.iterrows():
        if str(df_merge_nodup.loc[index,'area']).find("None") == -1:
            df_merge_nodup.loc[index,'location'] = get_qwen_response_2(df_merge_nodup.loc[index,'city'],df_merge_nodup.loc[index,'area'])
        else:
            df_merge_nodup.loc[index,'location'] = float('nan')
        print(df_merge_nodup.loc[index,'location'])

    for index, row in df_merge_nodup.iterrows():
        l = re.split(r'[,.，、。：:]', str(df_merge_nodup.loc[index,'location']))
        l = [item for item in l if item]
        print(l)
        df_merge_nodup.at[index,'location'] = np.array(l)

    df_merge_nodup = df_merge_nodup.explode('location')

    df_merge_nodup.reset_index(drop=True,inplace=True)
    df_merge_nodup['coordinate'] = df_merge_nodup['location']
    df_merge_nodup['formatted_address'] = df_merge_nodup['location']
    df_merge_nodup['coordinate_level'] = df_merge_nodup['location'] 

    # 高德地图 API 配置
    api_key = '9deaf41d592ad149cdc6f36dbe95e835'
    geocode_url = 'https://restapi.amap.com/v3/geocode/geo'

    # 通过地理编码获取经纬度
    for index, row in df_merge_nodup.iterrows():
        df_merge_nodup.at[index,'location'] = str(df_merge_nodup.at[index,'prov'])+str(df_merge_nodup.at[index,'location'])
        params = {
            'address': str(row['location']),
            'key': api_key,
            'output': 'JSON'
        }
        response = requests.get(geocode_url, params=params)
        data = response.json()

        if data['status'] == '1' and len(data['geocodes']) > 0:
            df_merge_nodup.at[index, 'coordinate']       = data['geocodes'][0]['location']
            df_merge_nodup.at[index, 'coordinate_level'] = data['geocodes'][0]['level']
            df_merge_nodup.at[index, 'formatted_address']= data['geocodes'][0]['formatted_address']
        else:
            df_merge_nodup.at[index, 'coordinate']       = 'Not Found'
            df_merge_nodup.at[index, 'coordinate_level'] = 'Not Found'
            df_merge_nodup.at[index, 'formatted_address']= 'Not Found'

        print(index,df_merge_nodup.at[index, 'formatted_address'],
            df_merge_nodup.at[index, 'location'],df_merge_nodup.at[index, 'coordinate'],
            df_merge_nodup.at[index, 'coordinate_level'])

    print("Processing complete!")
    df_merge_nodup.to_csv('df_merge_nodup_coord.csv')

    os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding/data/炮台数据")
    df = pd.read_csv('df_merge_nodup_coord.csv')

    df=df[df["coordinate_level"]!='市']
    df=df[df["coordinate_level"]!='Not Found']
    df=df[df["coordinate_level"]!='区县']

    df = df[~df["location"].str.contains("请返回", na=False)]

    for index,row in df.iterrows():
        if str(row['prov']) not in str(row['formatted_address']):
            df.drop(index=index, inplace=True)

    df['operation_date'] = pd.to_datetime(dict(year=df.operation_year, month=df.operation_month, day=df.operation_day))
    df['first_operation_date'] = df.groupby('coordinate')[['operation_date']].transform('min')
    df.drop_duplicates(['operation_date','coordinate'],inplace=True)
    df[['longitude', 'latitude']] = df['coordinate'].str.split(",", expand=True).astype(float)

    df['point'] = df.apply(lambda x: shapely.Point((x.longitude, x.latitude)), axis = 1)


    gdf = gpd.GeoDataFrame(df, geometry=df.point, crs={'init': 'epsg:4326'})
    aeqd = pyproj.Proj(proj='aeqd', ellps='WGS84', datum='WGS84').srs
    gdf = gdf.to_crs(crs=aeqd)

    gdf['circle_10km'] = gdf.geometry.buffer(10000)
    gdf.set_geometry('circle_10km', drop=True, inplace=True)
    gdf.drop(columns=['point'],inplace=True)
    gdf = gdf.to_crs(crs={'init': 'epsg:4326'})

    gdf.drop(columns=['operation_date'],inplace=True)
    gdf['first_operation_date']=gdf['first_operation_date'].astype(str)
    gdf.to_file('cleaned_炮台数据/cleaned_炮台数据.shp',encoding='utf-8')

    