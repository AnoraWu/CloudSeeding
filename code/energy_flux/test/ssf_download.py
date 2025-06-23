from netCDF4 import Dataset
import gzip
import os
import re
import requests
from multiprocessing import Pool


def download(url):
    filename = url[url.find("CERES_SSF"):-6]
    r = requests.get(url,allow_redirects=True)
    open(filename+".gz","wb").write(r.content)

if __name__ == '__main__':

    # code for download the datasets
    file_url = "https://ceres-tool.larc.nasa.gov/ord-tool/data1//CERES_2025-05-31:36642/fileURLs.txt"
    response = requests.get(file_url)
    file_content = response.text
    urls = file_content.split('\n')
    urls = urls[1:-1]

    folder_path = "/Users/anorawu/Team MG Dropbox/Wanru Wu/Cloudseeding/data/SSF" 
    os.chdir(folder_path)

    with Pool(6) as p:
        print(p.map(download, urls))