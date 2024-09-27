from threading import Thread
import subprocess
import os

# Set up directory
os.chdir('/Users/anorawu/Documents/GitHub/CloudSeeding/微博数据multiple threads')


t1 = Thread(target=subprocess.run, args=(["python", "人工影响天气/2010-2012.py"],))
t2 = Thread(target=subprocess.run, args=(["python", "人工影响天气/2013-2015.py"],))
t3 = Thread(target=subprocess.run, args=(["python", "人工影响天气/2016-2018.py"],))
t4 = Thread(target=subprocess.run, args=(["python", "人工影响天气/2019-2021.py"],))
t5 = Thread(target=subprocess.run, args=(["python", "人工影响天气/2022-2023.py"],))

t1.start()
t2.start()
t3.start()
t4.start()
t5.start()

t1.join()
t2.join()
t3.join()
t4.join()
t5.join()

