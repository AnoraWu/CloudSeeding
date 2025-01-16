import pandas as pd
import os
import requests
import ast
import numpy as np

# Change to the directory where your CSV files are stored
os.chdir('/Users/anorawu/Documents/GitHub/CloudSeeding/data/微博数据')
output_dir = '/Users/anorawu/Documents/GitHub/CloudSeeding/data/微博数据/微博数据图片'

filenames = [
    '微博数据_人影办_14-17.csv', '微博数据_人影办_18-20.csv', '微博数据_人影办_21-23.csv',
    '微博数据_人影作业_10-13.csv', '微博数据_人影作业_14-17.csv', '微博数据_人影作业_18-20.csv', '微博数据_人影作业_21-23.csv'
]

# Set the chunk size for processing large files
chunk_size = 500

# Loop through each CSV file
for filename in filenames:
    base_filename = os.path.splitext(filename)[0]
    csv_output_dir = os.path.join(output_dir, base_filename)

    # Ensure output directory for this CSV file exists
    os.makedirs(csv_output_dir, exist_ok=True)

    # Process the file in chunks to handle large files
    for chunk in pd.read_csv(filename, encoding='utf-8', on_bad_lines='skip', chunksize=chunk_size, low_memory=False):
        # Iterate through the chunk's rows
        for index, row in chunk.iterrows():
            # Use "发布时间" column for naming
            publication_time = row['发布时间']  # Replace "发布时间" with the exact column name if it's different
            urls = row.get('图片链接', '[]')  # Provide a default in case the column is missing or empty

            # Skip rows where 'urls' is NaN (completely empty value)
            if pd.isna(urls):
                print(f"Skipping row {index} due to NaN in '图片链接'.")
                continue

            try:
                # Safely evaluate the string representation of the list
                urls = ast.literal_eval(urls)
                if not isinstance(urls, list):
                    raise ValueError("Parsed '图片链接' is not a list.")
            except (ValueError, SyntaxError) as e:
                print(f"Skipping row {index} due to invalid '图片链接': {e}")
                continue

            if urls:
                for num, url in enumerate(urls):
                    try:
                        # Check if the image has already been downloaded
                        filepath = os.path.join(csv_output_dir, f'{base_filename}_{publication_time}_{num}.jpg')
                        if os.path.exists(filepath):
                            print(f"Image {filepath} already exists, skipping download.")
                            continue

                        headers = {
                            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36',
                            'Referer': 'https://weibo.com/'
                        }
                        response = requests.get(url, headers=headers, timeout=120)

                        # If the request is successful, save the image
                        if response.status_code == 200:
                            with open(filepath, 'wb') as f:
                                f.write(response.content)
                                print(f"Image {filepath} downloaded successfully!")
                        else:
                            print(f"Failed to download image from {url}, Status code: {response.status_code}")

                    except requests.exceptions.RequestException as e:
                        print(f"Error downloading image from {url}: {e}")
                        continue
            else:
                print(f"No valid URLs found in row {index}.")
    
    print(f"Finished processing {filename}")
            if urls:
                for num, url in enumerate(urls):
                    try:
                        # Check if the image has already been downloaded
                        filepath = os.path.join(csv_output_dir, f'{base_filename}_{publication_time}_{num}.jpg')
                        if os.path.exists(filepath):
                            print(f"Image {filepath} already exists, skipping download.")
                            continue

                        headers = {
                            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36',
                            'Referer': 'https://weibo.com/'
                        }
                        response = requests.get(url, headers=headers, timeout=120)

                        # If the request is successful, save the image
                        if response.status_code == 200:
                            with open(filepath, 'wb') as f:
                                f.write(response.content)
                                print(f"Image {filepath} downloaded successfully!")
                        else:
                            print(f"Failed to download image from {url}, Status code: {response.status_code}")

                    except requests.exceptions.RequestException as e:
                        print(f"Error downloading image from {url}: {e}")
                        continue
            else:
                print(f"No valid URLs found in row {index}.")
    
    print(f"Finished processing {filename}")