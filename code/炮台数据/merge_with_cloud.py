import geopandas as gpd
import pandas as pd
from geopy import distance

# Set directories
input_dir = r"D:/Git Local/CloudSeeding"
modis_dir = r"C:/Users/Anora/BFI Dropbox/Wanru Wu/MODIS"
output_file = f"{input_dir}\processed_cloud_data.csv"

# Load points data
df_pt = gpd.read_file(f"{input_dir}\data\cleaned_炮台数据\cleaned_炮台数据.shp")
df_pt = pd.DataFrame(df_pt.drop(columns='geometry'))


# Helper function: get four surrounding points
def get_four_points(longitude, latitude):
    lon1 = round(longitude * 2) / 2
    lat1 = round(latitude * 2) / 2
    if lon1.is_integer(): lon1 += 0.5
    if lat1.is_integer(): lat1 += 0.5

    lon2 = lon1 - 1 if lon1 > longitude else lon1 + 1
    lat2 = lat1 - 1 if lat1 > latitude else lat1 + 1
    return [(lon1, lat1), (lon1, lat2), (lon2, lat1), (lon2, lat2)]

# Check for already processed rows
try:
    processed_rows = pd.read_csv(output_file, usecols=['index'])['index'].tolist()
except FileNotFoundError:
    processed_rows = []

# Main processing loop
for index, row in df_pt.iterrows():
    # Skip if already processed
    if index in processed_rows:
        continue

    # Get the points on the coordinate grid
    pts_list = get_four_points(row["longitude"], row["latitude"])
    print(f"Processing row {index}, points: {pts_list}")

    cloud_data = []
    all_weight = []

    for pts in pts_list:

        month_data = []

        for year in range(2011, 2024):
            for month in range(1, 13):
                # Construct file path
                file_path = f"{modis_dir}/{year}/MODIS{year}{month:02}.dta"
                temp_df = pd.read_stata(file_path)

                condition = (temp_df['longitude'] == pts[0]) & (temp_df['latitude'] == pts[1])
                temp_df = temp_df[condition]

                # Remove abnormal date
                if (year == 2020) and (month == 6):
                    temp_df = temp_df[temp_df['day'] != 31]

                month_data.append(temp_df)
        
        # Concat monthly data and calculate weights
        month_df = pd.concat(month_data, ignore_index=True)

        dist = distance.distance(tuple(reversed(pts)), (row["latitude"], row["longitude"])).km
        weight = 1 / (dist * dist) 
        month_df['cloud_optical_thickness'] = weight*month_df['cloud_optical_thickness']
        month_df['cloud_mask_fraction'] = weight*month_df['cloud_mask_fraction']
        all_weight.append(weight)

        cloud_data.append(month_df)

    # Combine all data for the point
    cloud_df = pd.concat(cloud_data, ignore_index=True)
    grouped = cloud_df.groupby(['year', 'month', 'day']).sum(min_count=4)    
    grouped['wt_cloud_optical_thickness'] = grouped['cloud_optical_thickness'] / all_weight
    grouped['wt_cloud_mask_fraction'] = grouped['cloud_mask_fraction'] / all_weight

    # Prepare the final DataFrame
    final_df = grouped.reset_index()[['year', 'month', 'day', 'wt_cloud_optical_thickness', 'wt_cloud_mask_fraction']]
    final_df['latitude'] = row["latitude"]
    final_df['longitude'] = row["longitude"]
    final_df['index'] = index  # Add index for checkpointing

    # Append to CSV
    write_mode = 'w' if index == 0 and not processed_rows else 'a'
    final_df.to_csv(output_file, mode=write_mode, index=False, header=write_mode == 'w')

    print(f"Row {index} processed and written to file.")
