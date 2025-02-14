"""
Script Name: merge_with_cloud_3_mp.py
Author: Wanru Wu
Date: Jan 8, 2025
Purpose: Merge fort data with MERRA data
"""

import pandas as pd
import numpy as np
import calendar
import csv
import warnings
import os
import sys

# In Python 3, UTF-8 is the default encoding for most environments.
from multiprocessing import Pool, cpu_count
from geopy import distance

warnings.filterwarnings("ignore")

def process_row(row, merra_dir, output_file):

    def get_four_points(longitude, latitude):
        lat1 = round(latitude * 2) / 2
        lat2 = lat1 - 0.5 if lat1 > latitude else lat1 + 0.5

        lon_list = np.arange(73.125, 135, 0.625).tolist()
        lon1 = min(lon_list, key=lambda lon: abs(lon-longitude))
        lon2 = lon1 - 0.625 if lon1 > longitude else lon1 + 0.625
        
        return [(lon1, lat1), (lon1, lat2), (lon2, lat1), (lon2, lat2)]

    # Initialize variables
    pts_list = get_four_points(row["longitude"], row["latitude"])
    results = []

    try:

        for year in range(2010, 2024):
            for month in range(1, 13):

                # Load cloud data
                file_path = f"{merra_dir}/merra{year}{month:02}.dta"
                cloud_df_month = pd.read_stata(file_path)

                days_in_month = calendar.monthrange(year, month)[1]
                for day in range(1, days_in_month + 1):
                    cloud_df_day = cloud_df_month[cloud_df_month['day']==day]
                    cloud_df_day_pts = cloud_df_day[
                        cloud_df_day[['lon', 'lat']].apply(tuple, axis=1).isin(pts_list)]
                    # drop NA values
                    cloud_df_day_pts = cloud_df_day_pts.dropna()

                    if len(cloud_df_day_pts) > 0: # Only process if points are available

                        # Compute weights based on distance
                        for idx, pt in cloud_df_day_pts.iterrows():
                            dist = distance.distance((pt["lat"], pt["lon"]), (row["latitude"], row["longitude"])).km
                            weight = 1 / ((dist + 1e-6) * (dist + 1e-6)) 
                            cloud_df_day_pts.loc[idx,'weight'] = weight
                        
                        wt_air= np.average(cloud_df_day_pts['air'], weights=cloud_df_day_pts['weight'])
                        wt_ice = np.average(cloud_df_day_pts['ice'], weights=cloud_df_day_pts['weight'])
                        wt_liquid = np.average(cloud_df_day_pts['liquid'], weights=cloud_df_day_pts['weight'])

                        # Append result
                        results.append([
                            row['longitude'], row['latitude'], 
                            row['operation_year'], row['operation_month'], row['operation_day'],	
                            row['first_operation_date'], year, month, day,
                            wt_air, wt_ice, wt_liquid
                        ])
            
        # Write results in chunks (append mode)
        with open(output_file, mode='a', newline='',encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerows(results)
    
    except Exception as e:
        print(e)


if __name__ == "__main__":


    # File paths and settings
    data_dir = r"/home/wanru/cloudseeding"
    # data_dir = r"/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data"
    merra_dir = f"{data_dir}/MERRA_levmean"
    output_file = f"{data_dir}/炮台数据/server/processed_cloud_data_3.csv"
    # output_file = f"{data_dir}/炮台数据/processed_cloud_data_3.csv"

    # Load data
    df_pt = pd.read_csv(rf"{data_dir}/炮台数据/cleaned_炮台数据.csv", encoding='utf-8')

    # Write header if file is empty
    if not os.path.exists(output_file):
        with open(output_file, mode='w', newline='',encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['longitude', 'latitude', 'operation_year', 
                            'operation_month', 'operation_day', 'first_operation_date',
                            'year', 'month', 'day', 
                            'wt_air', 'wt_ice','wt_liguid'])

    # Use multiprocessing
    args = [(row, merra_dir, output_file) for _, row in df_pt.iterrows()]
    num_workers = 16  # Use all available cores minus 5
    with Pool(num_workers) as pool:
        # Map rows to worker processes
        pool.starmap(process_row,args)
