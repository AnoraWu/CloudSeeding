python fortdata_clean.py

# check if there are any missing dates, latitudes, and longitude
python cloud_checking.py

# merge with cloud fraction and thickness
python merge_with_cloud_1.py

# merge with weather station data
python merge_with_cloud_2.py
