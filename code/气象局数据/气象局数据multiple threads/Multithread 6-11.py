from threading import Thread
import subprocess
import os

# Set up directory
os.chdir('/Users/anorawu/Documents/GitHub/CloudSeeding/code/气象局数据multiple threads')

t1 = Thread(target=subprocess.run, args=(["python", "AI_extraction_step1 6.py"],))
t2 = Thread(target=subprocess.run, args=(["python", "AI_extraction_step1 7.py"],))
t3 = Thread(target=subprocess.run, args=(["python", "AI_extraction_step1 11.py"],))
t4 = Thread(target=subprocess.run, args=(["python", "AI_extraction_step1 9.py"],))
t5 = Thread(target=subprocess.run, args=(["python", "AI_extraction_step1 10.py"],))
# t6 = Thread(target=subprocess.run, args=(["python", "AI_extraction_step1 11.py"],))
# t5 = Thread(target=subprocess.run, args=(["python", "人工影响天气/2010-2013.py"],))
# t6 = Thread(target=subprocess.run, args=(["python", "人工影响天气/2014-2017.py"],))
# t7 = Thread(target=subprocess.run, args=(["python", "人工影响天气/2018-2020.py"],))
# t8 = Thread(target=subprocess.run, args=(["python", "人工影响天气/2021-2023.py"],))


t1.start()
t2.start()
t3.start()
t4.start()
t5.start()
# t6.start()
# t7.start()
# t8.start()


t1.join()
t2.join()
t3.join()
t4.join()
t5.join()
# t6.join()
# t7.join()
# t8.join()


