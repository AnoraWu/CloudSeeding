import h5py
import numpy as np
from os import listdir
from os.path import isfile, join

path = "/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/MODIS_L2/MOD06_L2/2020/001" 

for i in range(1,21):
    day = f"{i:03d}"
    folder_path = "/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding_Anora/MODIS_L2/MOD06_L2/2020/"+day 
    files = [file for file in listdir(folder_path) if isfile(join(folder_path, file))]
    for f in files:
        data = h5py.File(path, "r")
        for key in data.keys():
            print(key) #Names of the root level object names in HDF5 file - can be groups or datasets.
            print(type(f[key])) # get the object type: usually group or dataset

