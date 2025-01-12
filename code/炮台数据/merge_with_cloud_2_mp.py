"""
Script Name: merge_with_cloud_2_mp.py
Author: Wanru Wu
Date: Jan 11, 2025
Purpose: Merge fort data with weather station statistics
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


def process_row(row, rain_gdf, fort_gdf, buffer_radius, output_file):
    print(f"Processing fort index: {row['index']}")

    results = []
    fort_geometry = row['geometry']

    for year in range(2010, 2023):
        for month in range(1, 13):
            days_in_month = calendar.monthrange(year, month)[1]
            for day in range(1, days_in_month + 1):
                rain_gdf_day = rain_gdf[(rain_gdf["Year"] == year) & 
                                        (rain_gdf["Mon"] == month) & 
                                        (rain_gdf["Day"] == day)]

                var_list = ['Alti', 'EVP', 'GST_Avg', 'GST_Max', 'GST_Min', 'PRE_Max_1h',
                            'PRE_Time_2008', 'PRE_Time_0820', 'PRE_Time_2020', 'PRS_Avg', 
                            'PRS_Max', 'PRS_Min', 'RHU_Avg', 'RHU_Min', 'SSH', 'TEM_Avg', 
                            'TEM_Max', 'TEM_Min', 'WIN_S_2mi_Avg', 'WIN_S_10mi_Avg', 
                            'WIN_D_S_Max', 'WIN_S_Max', 'WIN_D_INST_Max', 'WIN_S_Inst_Max']
                
                computed_weights = {}

                for var in var_list:
                    rain_gdf_day_var = rain_gdf_day[[f"{var}", "geometry"]].dropna()
                    
                    if rain_gdf_day_var.empty:
                        computed_weights[f"wt_{var}"] = float("nan")
                        continue

                    # Find points within the buffer
                    pts_inside = rain_gdf_day_var[rain_gdf_day_var.geometry.within(fort_geometry.buffer(buffer_radius))]

                    if pts_inside.empty:
                        # Try enlarging the buffer if no points are found
                        pts_inside = rain_gdf_day_var[rain_gdf_day_var.geometry.within(fort_geometry.buffer(buffer_radius + 0.5))]

                    if not pts_inside.empty:
                        # Compute weights based on distance
                        pts_inside["dist"] = pts_inside.geometry.apply(
                            lambda x: distance.distance(
                                (x.y, x.x), (fort_geometry.y, fort_geometry.x)
                            ).km
                        )
                        pts_inside["weight"] = 1 / (pts_inside["dist"] + 1e-6)**2
                        # Select up to 4 nearest stations
                        pts_inside = pts_inside.nlargest(4, "weight")
                        # Weighted average
                        computed_weights[f"wt_{var}"] = np.average(
                            pts_inside[f"{var}"], weights=pts_inside["weight"]
                        )
                    else:
                        computed_weights[f"wt_{var}"] = float("nan")

                # Append results for this day
                result = [row['longitude'], row['latitude'], year, month, day] + \
                         [computed_weights[f"wt_{var}"] for var in var_list]
                results.append(result)

    # Write results to file
    with open(output_file, mode="a", newline="") as f:
        writer = csv.writer(f)
        writer.writerows(results)


# Main script
if __name__ == "__main__":
    data_dir = r"/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data"
    output_file = f"{data_dir}/炮台数据/processed_cloud_data_2.csv"

    fort_data = pd.read_csv(f"{data_dir}/炮台数据/cleaned_炮台数据.csv")
    fort_point = fort_data[["longitude", "latitude"]].drop_duplicates()
    fort_point["index"] = fort_point.reset_index(inplace=True).index

    rain_data = pd.read_stata(f"{data_dir}/weatherstation_2010_2022.dta")
    rain_data.dropna(subset=["Lat", "Lon", "Year", "Mon", "Day"], inplace=True)

    # Convert to GeoDataFrames
    rain_gdf = gpd.GeoDataFrame(
        rain_data,
        geometry=gpd.points_from_xy(rain_data["Lon"], rain_data["Lat"]),
        crs="EPSG:4326",
    )
    fort_gdf = gpd.GeoDataFrame(
        fort_point,
        geometry=gpd.points_from_xy(fort_point["longitude"], fort_point["latitude"]),
        crs="EPSG:4326",
    )

    # Define buffer radius
    buffer_radius = 0.5

    # Write header to the output file
    var_list = ['Alti', 'EVP', 'GST_Avg', 'GST_Max', 'GST_Min', 'PRE_Max_1h',
                            'PRE_Time_2008', 'PRE_Time_0820', 'PRE_Time_2020', 'PRS_Avg', 
                            'PRS_Max', 'PRS_Min', 'RHU_Avg', 'RHU_Min', 'SSH', 'TEM_Avg', 
                            'TEM_Max', 'TEM_Min', 'WIN_S_2mi_Avg', 'WIN_S_10mi_Avg', 
                            'WIN_D_S_Max', 'WIN_S_Max', 'WIN_D_INST_Max', 'WIN_S_Inst_Max']
    
    with open(output_file, mode="w", newline="") as f:
        header = ["longitude", "latitude", "year", "month", "day"] + \
                 [f"wt_{var}" for var in var_list]
        writer = csv.writer(f)
        writer.writerow(header)

    # Use multiprocessing
    num_workers = max(1, cpu_count() - 5)
    with Pool(num_workers) as pool:
        pool.starmap(
            process_row,
            [(row, rain_gdf, fort_gdf, buffer_radius, output_file) for _, row in fort_gdf.iterrows()],
        )



