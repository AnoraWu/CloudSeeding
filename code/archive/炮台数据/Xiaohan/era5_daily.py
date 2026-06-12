import os 
import xarray as xr
import time
import netCDF4 as nc

months = range(1, 13)  # 月份范围
# 定义文件夹路径和命名Excel文件名称
folder_path = "D:\\ERA5"
nc_files = [os.path.join(folder_path,f) for f in os.listdir(folder_path) if f.endswith('.nc')]
 
for ncfile in nc_files:

    daily_means_all_months = []
    ds = xr.open_dataset(ncfile)
    # 计算逐日均值
    daily_means = ds.resample(valid_time='D').mean()
 
    daily_means_all_months.append(daily_means)
 

    ds_daily_combined = xr.concat(daily_means_all_months, dim='time')
 
# 输出合并后的NC文件，保留原始的经纬度和层级信息
    output_file_name = os.path.splitext(ncfile)[0] + '_daily'+'.nc'   
    ds_daily_combined.to_netcdf(os.path.join("D:\\ERA5", output_file_name))

   
