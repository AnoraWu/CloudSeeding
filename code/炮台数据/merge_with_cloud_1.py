"""
Script Name: merge_with_cloud.py
Author: Wanru Wu
Date: Jan 2, 2025
Purpose: Merge fort data with 'cloud_optical_thickness' and 'cloud_mask_fraction' 
"""


import geopandas as gpd
import pandas as pd
import calendar
import numpy as np
import warnings
import csv
from geopy import distance

warnings.filterwarnings("ignore")


# Helper function: get four surrounding points
def get_four_points(longitude, latitude):
    lon1 = round(longitude * 2) / 2
    lat1 = round(latitude * 2) / 2
    if lon1.is_integer(): lon1 += 0.5
    if lat1.is_integer(): lat1 += 0.5

    lon2 = lon1 - 1 if lon1 > longitude else lon1 + 1
    lat2 = lat1 - 1 if lat1 > latitude else lat1 + 1
    return [(lon1, lat1), (lon1, lat2), (lon2, lat1), (lon2, lat2)]

if __name__ == "__main__":
    
    # Set directories
    data_dir = r"/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data"

    # cloud thickness and fraction
    modis_dir = f"{data_dir}/MODIS"
    output_file = f"{data_dir}/炮台数据/processed_cloud_data_1.csv"

    # Load points data
    df_pt = pd.read_csv(f"{data_dir}/炮台数据/cleaned_炮台数据.csv")

    # Open a CSV file in append mode
    with open(output_file, mode='a', newline='') as f:
        writer = csv.writer(f)
        
        # Write header if file is empty
        if f.tell() == 0: 
            writer.writerow(['longitude', 'latitude', 'operation_year', 
                            'operation_month', 'operation_day', 'first_operation_date',
                            'year', 'month', 'day', 
                            'wt_cloud_optical_thickness', 'wt_cloud_mask_fraction'])

        for index, row in df_pt.iterrows():
            pts_list = get_four_points(row["longitude"], row["latitude"])
            print(f"Processing row {index}, points: {pts_list}")

            for year in range(2011, 2024):
                for month in range(1, 13):

                    # Load cloud data
                    file_path = f"{modis_dir}/{year}/MODIS{year}{month:02}.dta"
                    cloud_df_month = pd.read_stata(file_path)

                    # Clean the data
                    # Convert missing value to zero, according to data documentation
                    cloud_df_month.loc[cloud_df_month['cloud_optical_thickness'].isna(), 'cloud_optical_thickness'] = 0
                    cloud_df_month.loc[cloud_df_month['cloud_mask_fraction'].isna(), 'cloud_mask_fraction'] = 0

                    # Remove abnormal date
                    if (year == 2020) and (month == 6):
                        cloud_df_month = cloud_df_month[cloud_df_month['day'] != 31]
                    if (year == 2013) and (month == 11):
                        cloud_df_month['day'] = cloud_df_month['day']-100


                    days_in_month = calendar.monthrange(year, month)[1]
                    for day in range(1, days_in_month + 1):
                        cloud_df_day = cloud_df_month[cloud_df_month['day']==day]
                        cloud_df_day_pts = cloud_df_day[
                            cloud_df_day[['longitude', 'latitude']].apply(tuple, axis=1).isin(pts_list)]
                        
                        num_pts = len(cloud_df_day_pts)
                        if num_pts == 3:
                            print(num_pts)

                        if len(cloud_df_day_pts) > 0: # Only process if points are available
                            # Compute weights based on distance
                            for idx, pt in cloud_df_day_pts.iterrows():
                                dist = distance.distance((pt["latitude"], pt["longitude"]), (row["latitude"], row["longitude"])).km
                                weight = 1 / (dist * dist) 
                                cloud_df_day_pts.loc[idx,'weight'] = weight
                            
                            # Did not count for missing values bc all missing values have been replaced by zero
                            wt_cloud_optical_thickness = np.average(cloud_df_day_pts['cloud_optical_thickness'], weights=cloud_df_day_pts['weight'])
                            wt_cloud_mask_fraction = np.average(cloud_df_day_pts['cloud_mask_fraction'], weights=cloud_df_day_pts['weight'])


                            writer.writerow([
                                row['longitude'], row['latitude'], 
                                row['operation_year'], row['operation_month'], row['operation_day'],	
                                row['first_operation_date'], year, month, day,
                                wt_cloud_optical_thickness, wt_cloud_mask_fraction
                            ])

            

    












