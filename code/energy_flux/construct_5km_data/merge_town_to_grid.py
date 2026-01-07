import geopandas as gpd
import pandas as pd
import numpy as np
import os
from shapely.geometry import MultiPolygon
from pyproj import Transformer

### Change to your rawdata directory
os.chdir('/Users/anora/Team MG Dropbox/Wanru Wu/Cloudseeding_Anora')

### Construct 5km*5km grid
# Load and project JX polygon 
jx_poly = gpd.read_file('jiangxi/jiangxi_shape.shp').geometry.iloc[0]
jx_poly_proj = gpd.GeoSeries([jx_poly], crs="EPSG:4326").to_crs("EPSG:4527").iloc[0]

# Convert to wkt to follow the same process as cloud data processing
jx_wkt_proj = jx_poly_proj.wkt               
jx_bounds = jx_poly_proj.bounds              
minx, miny, maxx, maxy = jx_bounds

# Bins for grid
grid_size = 5000
x_bins = np.arange(minx, maxx + grid_size, grid_size)
y_bins = np.arange(miny, maxy + grid_size, grid_size)

# Add year and day of year
operation_data = pd.read_csv('operation/cleaned_data.csv')
operation_data['date'] = pd.to_datetime(operation_data['date'])
operation_data['day'] = operation_data['date'].dt.dayofyear
operation_data['year'] = operation_data['date'].dt.year

transformer = Transformer.from_crs("EPSG:4326", "EPSG:4527", always_xy=True)
# operation_data['x_proj'], operation_data['y_proj'] = transformer.transform(
#     operation_data['lon'].values, 
#     operation_data['lat'].values
# )

# For each day, fill in operation location into the grid
# Iterate over each day
results = []

for year in range(2020,2026):
    for day in range(1, 367):

        if (year != 2020) & (year != 2024) & (day == 366):
            continue

        target_condition = (operation_data['year']==year) & (operation_data['day']==day)
        target_operation = operation_data[target_condition]
        lon = np.array(target_operation['lon'])
        lat = np.array(target_operation['lat'])

        xs, ys = transformer.transform(lon, lat)

        H_cnt = np.histogram2d(ys, xs, bins=[y_bins, x_bins])[0]

        # Find indices where operations happened 
        x_centers = (x_bins[:-1] + x_bins[1:]) / 2
        y_centers = (y_bins[:-1] + y_bins[1:]) / 2
        ny, nx = H_cnt.shape

        for i in range(ny):
            for j in range(nx):
                print(i,j)
                results.append({
                    "year": int(year),
                    "day": int(day),
                    "cell_y": i,
                    "cell_x": j,
                    "cell_id": f"{i}_{j}",
                    "x_center": x_centers[j],
                    "y_center": y_centers[i],
                    "cloudseeding_count": H_cnt[i, j]
                })

# Create the panel of operations
df_panel = pd.DataFrame(results)

df_panel.to_csv("test.csv")


# I want to construct a panel data, with each day between 2020-2025 being the time variable and each grid being the identity. 
# Each identity has a geometry and a id. 
# Fill in the cloud seeding operation day and location into the time slots and the grid 