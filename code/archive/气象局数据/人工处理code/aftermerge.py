import re

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

# file1 = '时间地点_test.csv'
# file2 = 'changes_log.csv'
outfile = 'merged_output.csv'
# errorfile = 'errors.json'
ultoutfile = 'result.csv'

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
                    print(f"Line {ind+1}, ID {i[0]}, time format is not correct, t={t}")
                else:
                    locs = c.strip().split(';')
                    for loc in locs:
                        if loc and not loc.isspace():
                            f.write(f"{pt},{loc}\n")

print("Complete.")