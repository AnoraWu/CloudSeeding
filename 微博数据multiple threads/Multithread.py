import threading
import pathlib

# Set up directory
os.chdir('/Users/anorawu/Documents/GitHub/CloudSeeding/微博数据multiple threads')

# Function to execute each Python script
def run_script(script):
    with open(script) as f:
        exec(f.read())

# List of your Python script filenames
scripts = ['人工增雨/2013-2015.py', '人工增雨/2016-2018.py', '人工增雨/2019-2021.py',
           '人工增雨/2022-2023.py', '人工影响天气/2010-2012.py','人工影响天气/2013-2015.py', 
           '人工影响天气/2016-2018.py','人工影响天气/2019-2021.py', '人工影响天气/2022-2023.py']

# Create a list to hold the threads
threads = []

# Create and start a thread for each script
for script in scripts:
    thread = threading.Thread(target=run_script, args=(script,))
    threads.append(thread)
    thread.start()

# Wait for all threads to finish
for thread in threads:
    thread.join()

print("All scripts have finished execution.")
