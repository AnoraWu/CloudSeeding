import geopandas as gpd
import pandas as pd
import os
from shapely.geometry import Point
from joblib import Parallel, delayed  # For parallel processing

# Set working directories
cloud_dir = "/Users/anorawu/BFI Dropbox/Wanru Wu/MODIS"
data_dir = "/Users/anorawu/Documents/GitHub/CloudSeeding"

# Load the location data
os.chdir(data_dir)
data = gpd.read_file("data/炮台数据/cleaned_炮台数据/cleaned_炮台数据.shp")

# Rename columns for consistency
data.rename(columns={"operation_": "year", "operatio_1": "month", "operatio_2": "day"}, inplace=True)
data['date'] = pd.to_datetime(data[['year', 'month', 'day']])  # Combine year, month, day
data.set_crs("EPSG:4326", inplace=True)  # Ensure CRS is set

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

# Run processing in parallel for all months across all years
os.chdir(cloud_dir)  # Change to cloud directory
results = Parallel(n_jobs=4)(
    delayed(process_month)(year, month, data, cloud_dir) 
    for year in range(2011, 2024) 
    for month in range(1, 13)
)

# Combine results into a single GeoDataFrame
final_data = pd.concat([res for res in results if res is not None], ignore_index=True)

# Save the final result
output_file = data_dir + "/" + "matched_cloud_location_data.csv" 
final_data.to_csv(output_file, index=False)
print(f"Final data saved to {output_file}")