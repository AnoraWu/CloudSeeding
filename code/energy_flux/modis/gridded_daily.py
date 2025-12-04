import sys
print("PYTHON:", sys.executable)

import numpy as np
import xarray as xr
import os
import glob
import geopandas as gpd
import matplotlib.pyplot as plt
import pandas as pd
import warnings
import multiprocessing as mp


from scipy.interpolate import griddata
from shapely.geometry import Point
from shapely.geometry import MultiPolygon
from pyproj import Transformer
from multiprocessing import Pool


warnings.filterwarnings(
    "ignore", 
    message="Duplicate dimension names present: dimensions {'vecdim'}", 
    category=UserWarning, 
    module="xarray.namedarray.core" # Targeting the specific file/module is more precise
)

def plot_5km_grid(mean_grid, x_bins, y_bins, title=""):
    plt.figure(figsize=(10, 10))

    # 自定义 colormap：加一个灰色用于 NaN
    cmap = plt.get_cmap("viridis")
    # 添加一行灰色作为 NaN color
    cmap_with_gray = cmap.with_extremes(bad="lightgray")

    plt.imshow(
        mean_grid,
        origin="lower",
        cmap=cmap_with_gray,
        extent=[x_bins[0], x_bins[-1], y_bins[0], y_bins[-1]]
    )

    plt.colorbar(label="Cloud Fraction")
    plt.title(title)
    plt.xlabel("x (meters in EPSG:4527)")
    plt.ylabel("y (meters in EPSG:4527)")

    plt.show()

def daily_grid_jx_5km(year, day, jx_poly, 
                      cloud_file, var,
                      grid_size=5000):
    
    print(year,day,var)

    # 江西 polygon 投影到 EPSG:4527 
    jx_proj = gpd.GeoSeries([jx_poly], crs="EPSG:4326").to_crs("EPSG:4527").iloc[0]
    minx, miny, maxx, maxy = jx_proj.bounds

    # 构建 5km × 5km 投影格网 
    x_bins = np.arange(minx, maxx + grid_size, grid_size)
    y_bins = np.arange(miny, maxy + grid_size, grid_size)

    # 容器
    sum_grid = np.zeros((len(y_bins)-1, len(x_bins)-1))
    count_grid = np.zeros((len(y_bins)-1, len(x_bins)-1))

    # 经纬度→投影转换器
    transformer = Transformer.from_crs("EPSG:4326", "EPSG:4527", always_xy=True)

    # 读取所有 swath 文件
    cloud_paths = sorted(
        glob.glob(f"{cloud_file}/{year}/{day}/{cloud_file}.A{year}{day}.*.hdf")
    )
    print("Found", len(cloud_paths), "files")

    if len(cloud_paths) == 0:
        # 直接返回空网格
        mean_grid = np.full((len(y_bins)-1, len(x_bins)-1), np.nan)
        return year, day, var, mean_grid, mean_grid, x_bins, y_bins

    for i, cp in enumerate(cloud_paths):
        try:
            cloud = xr.open_dataset(cp, engine="netcdf4", decode_times=False, mask_and_scale=True)
        
            lat = cloud["Latitude"].data
            lon = cloud["Longitude"].data
            dat = cloud[var].data

            # 先过滤 NaN
            with warnings.catch_warnings():
                warnings.filterwarnings("ignore")
                qa = cloud["Quality_Assurance_5km"].astype("uint16")

            # COT use flag
            cot_use = (qa[:, :, 1] >> 0) & 1
            cot_mask = (cot_use == 1)

            n_cot = cot_mask.sum().item()
            if n_cot == 0:
                continue

            mask = np.isfinite(lat) & np.isfinite(lon) & np.isfinite(dat) & cot_mask
            lat = lat[mask]
            lon = lon[mask]
            dat = dat[mask]

            # 经纬度 → EPSG:4527 (x, y meters)
            xs, ys = transformer.transform(lon, lat)

            # 落在 bbox 内
            inbbox = (xs >= minx) & (xs <= maxx) & (ys >= miny) & (ys <= maxy)

            if np.sum(inbbox) == 0:
                cloud.close()
                continue

            xs = xs[inbbox]
            ys = ys[inbbox]
            dat = dat[inbbox]

            # 精筛选：在江西 boundary 内
            points = gpd.GeoSeries(gpd.points_from_xy(xs, ys), crs="EPSG:4527")
            inside = points.intersects(jx_proj)
            inside = np.array(inside)
            if np.sum(inside) == 0:
                cloud.close()
                continue

            xs = xs[inside]
            ys = ys[inside]
            dat = dat[inside]

            # histogram2d 做 5km gridding
            H_sum = np.histogram2d(ys, xs, bins=[y_bins, x_bins], weights=dat)[0]
            H_cnt = np.histogram2d(ys, xs, bins=[y_bins, x_bins])[0]

            sum_grid += H_sum
            count_grid += H_cnt

            cloud.close()

        except Exception as e:
            print("Error:", cp, e)
            continue

    # 最终平均值 
    count_grid_div = count_grid.copy()
    count_grid_div[count_grid_div == 0] = 1
    mean_grid = sum_grid / count_grid_div
    mean_grid[count_grid == 0] = np.nan

    # Interpolation
    # 注意：bins 是边缘，我们需要的是中心点 (Centroids)
    x_centers = (x_bins[:-1] + x_bins[1:]) / 2
    y_centers = (y_bins[:-1] + y_bins[1:]) / 2

    # 创建完整的网格坐标 (xx, yy)
    yy, xx = np.meshgrid(y_centers, x_centers, indexing='ij') 

    # 识别已知点和缺失点
    nan_mask = np.isnan(mean_grid)

    # 提取已知点的坐标和值
    known_points = np.stack((xx[~nan_mask], yy[~nan_mask]), axis=-1)
    known_values = mean_grid[~nan_mask]

    if known_points.shape[0] < 4:
        # 如果没有已知点，则整个网格都无法插值。
        print(year,day,var, "no points to be interpolated")
        final_mean_grid = np.full(mean_grid.shape, np.nan) 
        return year, day, var, final_mean_grid, mean_grid, x_bins, y_bins

    # 提取所有需要插值的点的坐标 (这里是所有网格点)
    target_points = np.stack((xx.ravel(), yy.ravel()), axis=-1)


    # 插值
    interpolated_values = griddata(
        known_points, 
        known_values, 
        target_points, 
        method='linear'  # 这里选择线性插值
    )

    # 将一维结果重新塑形为原始网格
    filled_grid = interpolated_values.reshape(mean_grid.shape)

    # 将所有网格中心点转换为 GeoSeries
    grid_points = gpd.GeoSeries(map(Point, target_points), crs="EPSG:4527")
    is_inside = grid_points.intersects(jx_proj)
    is_inside = is_inside.values.reshape(mean_grid.shape)

    # 从原始网格开始，先用插值结果填充省内的缺失值
    final_mean_grid = mean_grid.copy()
    final_mean_grid[nan_mask & is_inside] = filled_grid[nan_mask & is_inside]
    final_mean_grid[~is_inside] = np.nan

    return year, day, var, final_mean_grid, mean_grid, x_bins, y_bins
    # return mean_grid, x_bins, y_bins


def daily_grid_jx_1km(year, day, jx_poly, 
                      cloud_file, var,
                      grid_size=5000):
    
    print(year,day,var)

    # 江西 polygon 投影到 EPSG:4527 
    jx_proj = gpd.GeoSeries([jx_poly], crs="EPSG:4326").to_crs("EPSG:4527").iloc[0]
    minx, miny, maxx, maxy = jx_proj.bounds

    # 构建 5km × 5km 投影格网 
    x_bins = np.arange(minx, maxx + grid_size, grid_size)
    y_bins = np.arange(miny, maxy + grid_size, grid_size)

    # 容器
    sum_grid = np.zeros((len(y_bins)-1, len(x_bins)-1))
    count_grid = np.zeros((len(y_bins)-1, len(x_bins)-1))

    # 经纬度→投影转换器
    transformer = Transformer.from_crs("EPSG:4326", "EPSG:4527", always_xy=True)

    # 读取所有 swath 文件
    cloud_paths = sorted(glob.glob(f"{cloud_file}/{year}/{day}/{cloud_file}.A{year}{day}.*.hdf"))
    geo_paths = sorted(glob.glob(f"MOD03/{year}/{day}/MOD03.A{year}{day}.*.hdf"))

    print("Found", len(geo_paths), "geo files,", len(cloud_paths), "cloud files")

    if len(cloud_paths) == 0 or len(geo_paths) == 0:
        return year, day, var, np.full_like(sum_grid, np.nan), np.full_like(sum_grid, np.nan), x_bins, y_bins

    # 先把 geo_files 做成 timestamp -> path 的映射
    geo_by_time = {}
    for g in geo_paths:
        gname = os.path.basename(g)
        gparts = gname.split('.')   # MOD03.A2020001.0540.061.hdf
        g_ts = gparts[2]            # "0540"
        geo_by_time[g_ts] = g

    for cp in cloud_paths:
        try:
            # 从 cloud 名字里取 timestamp
            fname = os.path.basename(cp)
            parts = fname.split('.')   # MOD06_L2.A2020001.0540.061.hdf
            ts = parts[2]              # "0540"

            # 找“同一位置字段相同”的 geo
            geo_path = geo_by_time.get(ts, None)
            if geo_path is None:
                print("No matching geo for cloud:", fname)
                continue

            # 真正打开文件
            cloud = xr.open_dataset(cp, engine="netcdf4", decode_times=False, mask_and_scale=True)
            geo = xr.open_dataset(geo_path, engine="netcdf4", decode_times=False, mask_and_scale=True)

            lat = geo["Latitude"].data
            lon = geo["Longitude"].data
            dat = cloud[var].data

            # 先过滤 NaN
            with warnings.catch_warnings():
                warnings.filterwarnings("ignore")
                qa = cloud["Quality_Assurance_1km"].astype("uint16")

            # COT use flag
            cot_use = (qa[:, :, 0] >> 0) & 1
            cot_mask = (cot_use == 1)
            n_cot = cot_mask.sum().item()
            if n_cot == 0:
                continue

            # phase flag
            phase_arr = qa[:, :, 2]
            mask = (1 << 3) - 1
            phase_val = (phase_arr >> 0) & mask
            phase_mask = (phase_val != 0)
            n_phase = phase_mask.sum().item()
            if n_phase == 0:
                continue


            # retrieval flag
            retrieval_arr = qa[:, :, 2]
            mask = (1 << 1) - 1
            retrieval_val = (retrieval_arr >> 3) & mask
            retrieval_mask = (retrieval_val != 0)
            n_retrieval = retrieval_mask.sum().item()
            if n_retrieval == 0:
                continue


            mask = np.isfinite(lat) & np.isfinite(lon) & np.isfinite(dat) & cot_mask & phase_mask & retrieval_mask
            lat = lat[mask]
            lon = lon[mask]
            dat = dat[mask]

            # 经纬度 → EPSG:4527 (x, y meters)
            xs, ys = transformer.transform(lon, lat)

            # 落在 bbox 内
            inbbox = (xs >= minx) & (xs <= maxx) & (ys >= miny) & (ys <= maxy)

            if np.sum(inbbox) == 0:
                cloud.close()
                geo.close()
                continue

            xs = xs[inbbox]
            ys = ys[inbbox]
            dat = dat[inbbox]

            # 精筛选：在江西 boundary 内
            points = gpd.GeoSeries(gpd.points_from_xy(xs, ys), crs="EPSG:4527")
            inside = points.intersects(jx_proj)
            inside = np.array(inside)

            if np.sum(inside) == 0:
                geo.close()
                cloud.close()
                continue

            xs = xs[inside]
            ys = ys[inside]
            dat = dat[inside]

            # histogram2d 做 5km gridding
            H_sum = np.histogram2d(ys, xs, bins=[y_bins, x_bins], weights=dat)[0]
            H_cnt = np.histogram2d(ys, xs, bins=[y_bins, x_bins])[0]

            sum_grid += H_sum
            count_grid += H_cnt

            cloud.close()
            geo.close()
        
        except Exception as e:
                print("Error opening:", cp, e)
                continue


    # 最终平均值 
    count_grid_div = count_grid.copy()
    count_grid_div[count_grid_div == 0] = 1
    mean_grid = sum_grid / count_grid_div
    mean_grid[count_grid == 0] = np.nan

    # Interpolation
    # 注意：bins 是边缘，我们需要的是中心点 (Centroids)
    x_centers = (x_bins[:-1] + x_bins[1:]) / 2
    y_centers = (y_bins[:-1] + y_bins[1:]) / 2

    # 创建完整的网格坐标 (xx, yy)
    yy, xx = np.meshgrid(y_centers, x_centers, indexing='ij') 

    # 识别已知点和缺失点
    nan_mask = np.isnan(mean_grid)

    # 提取已知点的坐标和值
    known_points = np.stack((xx[~nan_mask], yy[~nan_mask]), axis=-1)
    known_values = mean_grid[~nan_mask]

    if known_points.shape[0] < 4:
        # 如果没有已知点，则整个网格都无法插值。
        print(year,day,var, "no points to be interpolated")
        final_mean_grid = np.full(mean_grid.shape, np.nan) 
        return year, day, var, final_mean_grid, mean_grid, x_bins, y_bins

    # 提取所有需要插值的点的坐标 (这里是所有网格点)
    target_points = np.stack((xx.ravel(), yy.ravel()), axis=-1)


    # 插值
    interpolated_values = griddata(
        known_points, 
        known_values, 
        target_points, 
        method='linear'  # 这里选择线性插值
    )

    # 将一维结果重新塑形为原始网格
    filled_grid = interpolated_values.reshape(mean_grid.shape)

    # 将所有网格中心点转换为 GeoSeries
    grid_points = gpd.GeoSeries(map(Point, target_points), crs="EPSG:4527")
    is_inside = grid_points.intersects(jx_proj)
    is_inside = is_inside.values.reshape(mean_grid.shape)

    # 从原始网格开始，先用插值结果填充省内的缺失值
    final_mean_grid = mean_grid.copy()
    final_mean_grid[nan_mask & is_inside] = filled_grid[nan_mask & is_inside]
    final_mean_grid[~is_inside] = np.nan

    return year, day, var, final_mean_grid, mean_grid, x_bins, y_bins
    # return mean_grid, x_bins, y_bins

if __name__ == "__main__":

    mp.set_start_method("spawn")

    km5vars = ["Cloud_Fraction",         
            "Cloud_Fraction_Night",         
            "Cloud_Fraction_Day"] 

    km1vars = ["Cloud_Optical_Thickness",             
        "Cloud_Optical_Thickness_Uncertainty"]

    os.chdir("/project/mgreenst/cloudseeding/rawdata")

    jiangxi_shape = gpd.read_file('/project/mgreenst/cloudseeding/rawdata/jiangxi/jiangxi_shape.shp')
    jx_poly = jiangxi_shape.geometry.iloc[0]


    data = []
    # years = ["2020","2021","2022","2023","2024","2025"]
    # days  = ["{:03d}".format(num) for num in range(1,367)]
    years = ["2020"]
    days  = ["{:03d}".format(num) for num in range(1,367)]

    km5_tuple = [(year, day, jx_poly, "MOD06_L2", var) for year in years for day in days for var in km5vars]
    km1_tuple = [(year, day, jx_poly, "MOD06_L2", var) for year in years for day in days for var in km1vars]


    n = int(os.environ.get("SLURM_CPUS_PER_TASK", 15))

    with Pool(n) as p:
        data.append(p.starmap(daily_grid_jx_5km, km5_tuple))
    
    with Pool(n) as p:
        data.append(p.starmap(daily_grid_jx_1km, km1_tuple))


    # Convert data (list of lists) → long panel DataFrame
    records = []

    for result_list in data:   # first is 5km, second is 1km
        for result in result_list:
            year, day, var, final_grid, raw_grid, x_bins, y_bins = result

            # centers
            x_centers = (x_bins[:-1] + x_bins[1:]) / 2
            y_centers = (y_bins[:-1] + y_bins[1:]) / 2

            # grid dimensions
            ny, nx = final_grid.shape

            # iterate every cell
            for i in range(ny):
                for j in range(nx):
                    records.append({
                        "year": int(year),
                        "day": int(day),
                        "var": var,
                        "cell_i": i,
                        "cell_j": j,
                        "cell_id": f"{i}_{j}",
                        "x_center": x_centers[j],
                        "y_center": y_centers[i],
                        "value_interpolated": final_grid[i, j],
                        "value_raw": raw_grid[i, j]
                    })

    # create dataframe
    panel_df = pd.DataFrame(records)
    panel_df.to_pickle("/project/mgreenst/cloudseeding/intermediate/modis_panel_2020.pkl")




