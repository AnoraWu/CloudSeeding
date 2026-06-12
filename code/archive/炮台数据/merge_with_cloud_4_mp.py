"""
Script Name: merge_with_cloud_2_mp.py
Author: Wanru Wu
Date: Jan 11, 2025
Purpose: Merge fort data with GPM statistics
"""

import pandas as pd
import geopandas as gpd
from geopy import distance
import numpy as np
import calendar
import csv
import warnings
from multiprocessing import Pool, cpu_count
warnings.filterwarnings("ignore")

def process_row(row, data_dir, output_file):

    # Helper function: get four surrounding points
    def get_four_points(lon,lat):
        lat_min, lat_max, lat_step = 17.95, 54.95, 0.1
        lon_min, lon_max, lon_step = 73.05, 134.95, 0.1

        # Ensure the given point is within the range
        if not (lat_min <= lat <= lat_max and lon_min <= lon <= lon_max):
            raise ValueError("Latitude or longitude is out of the defined range.")

        # Find the closest grid points
        lat1 = round((round(lat - lat_min,2)+1e-6) // lat_step * lat_step + lat_min,2)
        lat2 = round(lat1 + lat_step if (lat-lat1>1e-9) else lat1,2)

        lon1 = round((round(lon - lon_min,2)+1e-6)// lon_step * lon_step + lon_min,2)
        lon2 = round(lon1 + lon_step if (lon-lon1>1e-9) else lon1,2)

        return [(lon1, lat1), (lon1, lat2), (lon2, lat1), (lon2, lat2)]


    # Initialize variables
    pts_list = get_four_points(row["longitude"], row["latitude"])
    results = []

    try:
        for year in range(2010, 2025):
            for month in range(1, 13):

                # No precipitation data after 2024 Jun
                if year == 2024 and month > 6:
                    continue

                # Load precipitation data
                rain_df = pd.read_stata(rf"{data_dir}/GPM/{year}/{year}{month:02}.dta")

                days_in_month = calendar.monthrange(year, month)[1]
                for day in range(1, days_in_month + 1):
                    rain_df_day = rain_df[rain_df['day']==day]
                    rain_df_day[['lon','lat']] = rain_df_day[['lon', 'lat']].round(2)
                    rain_df_day_pts = rain_df_day[
                        rain_df_day[['lon', 'lat']].apply(tuple, axis=1).isin(pts_list)]

                    if len(rain_df_day_pts) > 0: # Only process if points are available

                        # Compute weights based on distance
                        for idx, pt in rain_df_day_pts.iterrows():
                            dist = distance.distance((pt["lat"], pt["lon"]), (row["latitude"], row["longitude"])).km
                            weight = 1 / ((dist + 1e-6) * (dist + 1e-6)) 
                            rain_df_day_pts.loc[idx,'weight'] = weight
                        
                        # Did not count for missing values bc all missing values have been replaced by zero
                        wt_precipitation = np.average(rain_df_day_pts['precipitation'], weights=rain_df_day_pts['weight'])

                        # Append result
                        results.append([
                            row['longitude'], row['latitude'], 
                            row['operation_year'], row['operation_month'], row['operation_day'],	
                            row['first_operation_date'], year, month, day,
                            wt_precipitation
                        ])
            
        # Write results in chunks (append mode)
        with open(output_file, mode='a', newline='') as f:
            writer = csv.writer(f)
            writer.writerows(results)
    
    except Exception as e:
        print(e)

# Main script
if __name__ == "__main__":

    local = "local"

    if local == "local":
        data_dir = rf"/Users/anorawu/Team MG Dropbox/Wanru Wu/Cloudseeding/data"
        output_file = rf"{data_dir}/炮台数据/processed_cloud_data_4.csv"
        num_workers = 10
    else:
        data_dir = rf"/home/wanru/cloudseeding"
        output_file = rf"{data_dir}/炮台数据/server/processed_cloud_data_4.csv"
        num_workers = 16

    fort_data = pd.read_csv(rf"{data_dir}/炮台数据/cleaned_炮台数据.csv",encoding="utf-8")
    
    # Convert to GeoDataFrames
    fort_gdf = gpd.GeoDataFrame(
        fort_data,
        geometry=gpd.points_from_xy(fort_data["longitude"], fort_data["latitude"]),
        crs=4326,
    )

    with open(output_file, mode="w", newline="", encoding="utf-8") as f:
        header = ["longitude", "latitude","operation_year","operation_month", \
                  "operation_day", "first_operation_date", "year", "month", "day", "wt_precipitation"]
        writer = csv.writer(f)
        writer.writerow(header)

    # Use multiprocessing
    args = [(row, data_dir, output_file) for _, row in fort_gdf.iterrows()]
    with Pool(num_workers) as pool:
        pool.starmap(process_row,args)



