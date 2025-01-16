"""
Script Name: cloud_checking.py
Author: Wanru Wu
Date: Jan 6, 2025
Purpose: Check the completeness of cloud data 
"""

import pandas as pd
import calendar
import numpy as np


if __name__ == "__main__":
    
    ### Set directories
    data_dir = "/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data"

    # cloud thickness and fraction
    modis_dir = f"{data_dir}/MODIS"
    # weather station statistics
    weather_station_dir = f"{data_dir}/weatherstation_2010_2022.dta"
    # air, ice, and liquid
    merra_dir = f"{data_dir}/MERRA_levmean" 

    ### If true, then check the data
    check_modis = False
    check_weather_station = True
    check_merra = False
    check_era5 = False

    ### Check MODIS
    if check_modis:
        lat_complete_modis = [latitude-0.5  for latitude in range(-89,91)]
        lon_complete_modis = [longitude-0.5 for longitude in range(-179,181)]

        print("\n\n\n check modis \n\n\n")

        try:
            for year in range(2010, 2024):
                for month in range(1, 13):

                    # Get the data frame for the month and year
                    file_path = f"{modis_dir}/{year}/MODIS{year}{month:02}.dta"
                    temp_df   = pd.read_stata(file_path)

                    # Check if dates are complete
                    days_in_month = range(1,calendar.monthrange(year, month)[1]+1)

                    # Extract all dates
                    date_list     = list(temp_df['day'].unique())

                    # Check if all dates are available
                    missing_days = [item for item in days_in_month if item not in date_list]
                    if missing_days:
                        print(f"In year {year} and month {month}, the missing days are", missing_days)
                    else:
                        print(f"In year {year} and month {month}, days are complete")

                    # Check if latitudes and longitudes are complete
                    lon_list = [round(x, 1) for x in temp_df['longitude'].unique()]
                    lat_list = [round(x, 1) for x in temp_df['latitude'].unique()]

                    missing_lat = [item for item in lat_complete_modis if item not in lat_list]
                    missing_lon = [item for item in lon_complete_modis if item not in lon_list]
                    if missing_lat:
                        print(f"In year {year} and month {month}, the missing latitudes are", missing_lat)
                    else:
                        print(f"In year {year} and month {month}, latitudes are complete")
                    if missing_lon:
                        print(f"In year {year} and month {month}, the missing longitudes are", missing_lon)
                    else:
                        print(f"In year {year} and month {month}, longitudes are complete")
        except Exception as e:
            print(e)
    
    ### Check weather station data 
    if check_weather_station:

        print("\n\n\n check weather station \n\n\n")

        # Check if there are any missing days for each StationId
        def check_continuity_with_gaps(group):
            first_date = group['Date'].min()
            full_date_range = pd.date_range(start=first_date, end=group['Date'].max())
            actual_dates = group['Date']
            missing_dates = set(full_date_range) - set(actual_dates)
            
            if not missing_dates:
                return "Continuous"
            else:
                return f"Missing Dates: {len(missing_dates)}"

        try:
            # Get the data frame
            temp_df = pd.read_stata(weather_station_dir)
            temp_df = temp_df[temp_df['StationId']!=999999.0]
            temp_df.rename(columns={"Year": "year", "Mon": "month", "Day": "day"},inplace=True)

            # Create a Date column for easier processing
            temp_df['Date'] = pd.to_datetime(temp_df[['year', 'month', 'day']])
            temp_df = temp_df.sort_values(by=['StationId', 'Date']).reset_index(drop=True)

            # Apply the function and summarize results
            continuity_summary = temp_df.groupby('StationId').apply(check_continuity_with_gaps)

            # Print the results
            for station_id, result in continuity_summary.items():
                if result != "Continuous":
                    print(f"StationId: {station_id}, Status: {result}")     
        
        except Exception as e:
            print(e)
    
            
    ### Check merra data
    if check_merra:
        print("\n\n\n check merra \n\n\n")

        # Define latitude and longitude ranges
        lat_complete_temp = np.arange(18, 55, 0.5).tolist()
        lon_complete_temp = np.arange(73.125, 135, 0.625).tolist()
        # Remove extra decimal digits for clean comparison
        lat_complete_merra = [int(num) if num == int(num) else num for num in lat_complete_temp]
        lon_complete_merra = [int(num) if num == int(num) else num for num in lon_complete_temp]

        # Initialize summary for column completeness
        column_completeness_summary = {}

        try:
            for year in range(2010, 2024):
                for month in range(1, 13):
                    # Get the data frame for the month and year
                    file_path = f"{merra_dir}/merra{year}{month:02}.dta"
                    temp_df = pd.read_stata(file_path)

                    # Check if dates are complete
                    days_in_month = range(1, calendar.monthrange(year, month)[1] + 1)
                    date_list = list(temp_df['day'].unique())

                    # Report missing days
                    missing_days = [item for item in days_in_month if item not in date_list]
                    if missing_days:
                        print(f"In year {year} and month {month}, the missing days are", missing_days)
                    else:
                        print(f"In year {year} and month {month}, days are complete")

                    # Check latitudes and longitudes completeness
                    lon_list = [x for x in temp_df['lon'].unique()]
                    lat_list = [x for x in temp_df['lat'].unique()]

                    missing_lat = [item for item in lat_complete_merra if item not in lat_list]
                    missing_lon = [item for item in lon_complete_merra if item not in lon_list]
                    if missing_lat:
                        print(f"In year {year} and month {month}, the missing latitudes are", missing_lat)
                    else:
                        print(f"In year {year} and month {month}, latitudes are complete")
                    if missing_lon:
                        print(f"In year {year} and month {month}, the missing longitudes are", missing_lon)
                    else:
                        print(f"In year {year} and month {month}, longitudes are complete")

                    # Initialize or update column completeness summary
                    for col in temp_df.columns:
                        if col not in ['day', 'lat', 'lon']:  # Exclude coordinates and day columns
                            if col not in column_completeness_summary:
                                column_completeness_summary[col] = {
                                    '1-50%': 0,
                                    '51-75%': 0,
                                    '76-90%': 0,
                                    '91-100%': 0
                                }

                            # Calculate completeness percentage for the column
                            completeness_percent = (temp_df[col].notnull().sum() / len(temp_df)) * 100

                            # Categorize by completeness percentage
                            if 1 <= completeness_percent <= 50:
                                column_completeness_summary[col]['1-50%'] += 1
                            elif 51 <= completeness_percent <= 75:
                                column_completeness_summary[col]['51-75%'] += 1
                            elif 76 <= completeness_percent <= 90:
                                column_completeness_summary[col]['76-90%'] += 1
                            elif 91 <= completeness_percent <= 100:
                                column_completeness_summary[col]['91-100%'] += 1

        except Exception as e:
            print(e)

        # Print column completeness summary
        print("\nSummary of MERRA Data Completeness (% Available Data by Column):")
        print("Column Name     | 1-50% | 51-75% | 76-90% | 91-100%")
        print("-----------------------------------------------------")
        for col, completeness in column_completeness_summary.items():
            print(f"{col:<15} | {completeness['1-50%']:<6} | {completeness['51-75%']:<6} | {completeness['76-90%']:<6} | {completeness['91-100%']:<6}")

    ### Check ERA5
    if check_era5:
        # Define latitude and longitude ranges
        lat_complete_temp = np.arange(18, 73, 0.25).tolist()
        lon_complete_temp = np.arange(55, 135, 0.25).tolist()
        # Remove extra decimal digits for clean comparison
        lat_complete_era5 = [int(num) if num == int(num) else num for num in lat_complete_temp]
        lon_complete_era5 = [int(num) if num == int(num) else num for num in lon_complete_temp]

        print("\n\n\n check modis \n\n\n")

        column_completeness_summary = {}
        try:
            for year in range(2010, 2024):
                for month in range(1, 13):

                    # Get the data frame for the month and year
                    file_path = f"{modis_dir}/{year}/MODIS{year}{month:02}.dta"
                    temp_df   = pd.read_stata(file_path)

                    # Check if dates are complete
                    days_in_month = range(1,calendar.monthrange(year, month)[1]+1)

                    # Extract all dates
                    date_list     = list(temp_df['day'].unique())

                    # Check if all dates are available
                    missing_days = [item for item in days_in_month if item not in date_list]
                    if missing_days:
                        print(f"In year {year} and month {month}, the missing days are", missing_days)
                    else:
                        print(f"In year {year} and month {month}, days are complete")

                    # Check if latitudes and longitudes are complete
                    lon_list = [x for x in temp_df['longitude'].unique()]
                    lat_list = [x for x in temp_df['latitude'].unique()]

                    missing_lat = [item for item in lat_complete_era5 if item not in lat_list]
                    missing_lon = [item for item in lon_complete_era5 if item not in lon_list]
                    if missing_lat:
                        print(f"In year {year} and month {month}, the missing latitudes are", missing_lat)
                    else:
                        print(f"In year {year} and month {month}, latitudes are complete")
                    if missing_lon:
                        print(f"In year {year} and month {month}, the missing longitudes are", missing_lon)
                    else:
                        print(f"In year {year} and month {month}, longitudes are complete")

        except Exception as e:
            print(e)






            




