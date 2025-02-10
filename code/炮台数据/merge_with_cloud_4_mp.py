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

# warnings.filterwarnings("ignore")

def idw_geopy_for_dataframe(target_df, grid_df, k=5, power=2):
    for year in range(2010, 2024):
        for month in range(1, 13):

            # read the precipitation data
            rain_data = pd.read_stata(rf"{data_dir}/GPM/{year}/{year}{month:02}.dta")
            rain_data.dropna(inplace=True)


            def process_row(target_row):
                # Extract target coordinates
                target_lat = target_row['latitude']
                target_lon = target_row['longitude']
                target_coord = (target_lat, target_lon)

                # Calculate geodesic distances from target to all grid points
                grid_df['distance'] = grid_df.apply(lambda row: distance(target_coord, (row['lat'], row['lon'])).km, axis=1)

                # Select k nearest neighbors
                nearest_neighbors = grid_df.nsmallest(k, 'distance')

                # Extract distances and precipitation values
                nearest_distances = nearest_neighbors['distance'].values
                nearest_precip = nearest_neighbors['precipitation'].values

                # Avoid division by zero by setting a minimum distance threshold
                nearest_distances = np.maximum(nearest_distances, 1e-6)

                # Compute IDW weights
                weights = 1 / (nearest_distances ** power)
                weights /= np.sum(weights)  # Normalize the weights

                # Calculate weighted precipitation estimate
                estimated_precip = np.sum(weights * nearest_precip)
                return estimated_precip

    # Apply the function to each row of the target DataFrame
    target_df['estimated_precipitation'] = target_df.apply(process_row, axis=1)

    return target_df




def process_row(row, rain_gdf, buffer_radius, output_file):

    results = []
    fort_geometry = row['geometry']

    for year in range(2010, 2024):
        print(year)
        for month in range(1, 13):

            # read the precipitation data
            rain_data = pd.read_stata(rf"{data_dir}/GPM/{year}/{year}{month:02}.dta")
            rain_data.dropna(inplace=True)
            rain_gdf = gpd.GeoDataFrame(
                rain_data,
                geometry=gpd.points_from_xy(rain_data["lon"], rain_data["lat"]),
                crs="EPSG:4326",
            )

            pts_inside = rain_gdf[rain_gdf.geometry.within(fort_geometry.buffer(buffer_radius))]

            days_in_month = calendar.monthrange(year, month)[1]
            for day in range(1, days_in_month + 1):
                pts_inside_day = pts_inside[(pts_inside["year"] == year) & 
                                            (pts_inside["month"] == month) & 
                                            (pts_inside["day"] == day)]

                if not pts_inside_day.empty:
                    # Compute weights based on distance
                    for idx, pt in pts_inside_day.iterrows():
                        pts_inside_day.loc[idx,'dist'] = distance.distance((pt["Lat"], pt["Lon"]), (row["latitude"], row["longitude"])).km
                    pts_inside_day["weight"] = 1 / ((pts_inside_day["dist"] + 1e-6)**2)
                    # Select up to 4 nearest stations
                    pts_inside_day = pts_inside_day.nlargest(4, "weight")
                    # Weighted average
                    wt_rainfall= np.average(
                        pts_inside["precipitation"], weights=pts_inside["weight"] 
                    )
                else:
                    pts_inside["precipitation"] = float("nan")

                # Append results for this day
                result = [row['longitude'], row['latitude'], year, month, day, wt_rainfall] 
                results.append(result)

    # Write results to file
    with open(output_file, mode="a", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerows(results)


# Main script
if __name__ == "__main__":
    data_dir = r"/home/wanru/cloudseeding"
    output_file = f"{data_dir}/炮台数据/server/processed_cloud_data_4.csv"
    fort_data = pd.read_csv(rf"{data_dir}/炮台数据/cleaned_炮台数据.csv",encoding="utf-8")
    

    # Convert to GeoDataFrames
    fort_gdf = gpd.GeoDataFrame(
        fort_data,
        geometry=gpd.points_from_xy(fort_data["longitude"], fort_data["latitude"]),
        crs="EPSG:4326",
    )

    
    with open(output_file, mode="w", newline="", encoding="utf-8") as f:
        header = ["longitude", "latitude", "year", "month", "day", ""]
        writer = csv.writer(f)
        writer.writerow(header)

    # Use multiprocessing
    num_workers = 16
    args = [(row, buffer_radius, output_file) for _, row in fort_gdf.iterrows()]
    with Pool(num_workers) as pool:
        pool.starmap(process_row,args)



