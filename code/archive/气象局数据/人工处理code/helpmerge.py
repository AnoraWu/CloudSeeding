import pandas as pd
import re
import os
os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding/data/气象局数据/人工处理")

def process_date_string(t):
    # Check if t is in the 'YYYY-MM-DD' format
    if re.match(r'^\d{4}-\d{2}-\d{2}$', t):
        return t  # Return the date as is

    # Check if t is in the 'YYYY-MM-DD~YYYY-MM-DD' format
    elif re.match(r'^\d{4}-\d{2}-\d{2}~\d{4}-\d{2}-\d{2}$', t):
        return t.split('~')[0]  # Return the first date part

    # If t is in neither format, print it
    else:
        return None

file1 = '时间地点.csv'
file2 = 'changes_log.csv'
outfile = 'merged_output.csv'
# errorfile = 'errors.json'
ultoutfile = 'result.csv'

with open(file1, 'r', encoding='utf-8') as f:
    lines = [line.strip().split(',') for line in f]
dict1 = {line[-1]: [i+1] + line[:-1] for i, line in enumerate(lines)}

with open(file2, 'r', encoding='utf-8') as f:
    data2 = [line.strip().split(',') for line in f]

print(f"Reading {file2}...\n")
for i,line in enumerate(data2):
    if (not (line[0]).isdigit()):
        print(f"Line {i}, {line[0]} is not a number \n")

    if line[0] in dict1:
        dict1[line[0]] = [i+1]+line[1:]
    else:
        print(f"Line {i}, is not in dict1. Id: {line[0]}\n")

print(f"{file2} loading complete. Updating {file1} now.\n")

with open(outfile, 'a', encoding='utf-8') as f:
    for i,j in dict1.items():
        if (not i.isdigit()):
            print(f"Line {j[0]}, {i} is not a number \n")
        str= f"{i}"
        for ind,k in enumerate(j):
            if ind!=0:
                str+= f",{k}"
        str+="\n"
        f.write(str)

print(f"merging complete, starting reformating {outfile}...\n")

with open(outfile, 'r', encoding='utf-8') as f:
    data3 = [line.strip().split(',') for line in f]

with open(ultoutfile, 'w', encoding='utf-8') as f:
    for ind,i in enumerate(data3):
        leni = len(i)
        if leni !=2:
            if leni%2!=1:
                print(f"Line {ind+1}, ID {i[0]}, length is not correct")
            
            for k in range(int((leni-1)/2)):
                t = i[1+2*k]
                c = i[2+2*k]
                pt = process_date_string(t)
                if pt is None:
                    print(f"Line {ind+1}, ID {i[0]}, time format is not correct")
                else:
                    locs = c.strip().split(';')
                    for loc in locs:
                        if loc and not loc.isspace():
                            f.write(f"{pt},{loc},{i[0]}\n")

print("Complete.")