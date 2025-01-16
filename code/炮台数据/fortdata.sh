# extract fort locations
python fortdata_clean.py

# check if there are any missing dates, latitudes, and longitude
python cloud_checking.py

# merge with modis (cloud fraction and thickness)
python merge_with_cloud_1_mp.py

# merge with weather station data
python merge_with_cloud_2_mp.py
python merge_with_cloud_2_clean.py

# merge with merra data
python merge_with_cloud_3_mp.py



