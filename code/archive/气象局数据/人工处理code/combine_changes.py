import csv

def replace_entries(timeplace_file, changes_file, output_file):
    # Create a dictionary from changes_log where key is the index and value is the concatenated string of remaining columns
    changes_dict = {}
    with open(changes_file, mode='r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row in reader:
            index = row[0]  # First column as the index
            value = ' '.join(row[1:])  # Concatenate all other columns into a single string
            changes_dict[index] = value

    # Read and update the 时间地点_test file
    updated_rows = []
    with open(timeplace_file, mode='r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row in reader:
            # Get the index from the last column
            index = row[-1]
            # If the index is found in changes_dict, replace the last entry with the concatenated value
            if index in changes_dict:
                row[-1] = changes_dict[index]
            updated_rows.append(row)

    # Write the updated content to a new file
    with open(output_file, mode='w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerows(updated_rows)

# Example usage
import os
os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding/data/气象局数据/人工处理")
replace_entries('时间地点.csv', 'changes_log.csv', 'updated_时间地点.csv')