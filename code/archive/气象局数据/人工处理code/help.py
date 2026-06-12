import pandas as pd
import json
import tkinter as tk
import numpy as np
from tkinter import messagebox
import os
os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding/data/气象局数据")

# Define a file to record mismatches
mismatch_log = 'mismatches.json'
mismatches = []
changes_log = 'changes_log.csv'

# Load the CSV files
file1 = '人工处理/output_1-11_test.csv'
file2 = '人工处理/result.csv'

# Load data1 normally
data1 = pd.read_csv(file1)

# Manually load data2 to handle variable-length rows, with UTF-8 encoding for Chinese characters
with open(file2, 'r', encoding='utf-8') as f:
    lines = [line.strip().split(',') for line in f]
max_columns = max(len(line) for line in lines)  # Find the maximum number of columns
data2 = pd.DataFrame([line + [None] * (max_columns - len(line)) for line in lines])

# Filter data1 to retain only the rows whose index values exist in data2
data1['index1'] = data1.index - 1
data1['Unnamed: 0'] = data1['index1']
data1.set_index("index1", inplace=True)
data2['index2'] = pd.to_numeric(data2[2])
data2.set_index("index2", inplace=True)
data1 = data1[data1.index.isin(data2.index)]

# Reverse the data frames to start from the last row
# data1 = data1.iloc[::-1]
# data2 = data2.iloc[::-1]

# Initialize indices and editing flag
index1, index2 = 1,1
is_edit_mode = False
is_edited = 0  # Flag to track if "Edit Keywords" was pressed

# Helper function to save the current change directly to the log file
def save_current_change(change):
    # Open the log file in append mode
    with open(作业点, 'a', encoding='utf-8') as f:
        # Format the entry as a raw text line without quotation marks
        index = change['Index']
        keywords = change['Keywords']
        # Write the index and keywords as a comma-separated line
        f.write(f"{index},{keywords}\n")


# Tkinter GUI setup
root = tk.Tk()
root.title("Data Comparison Tool")
root.geometry("600x600")

# Font setting for better Chinese support
chinese_font = ("SimSun", 12)

# Text widgets for displaying information with the Chinese-friendly font
index_label = tk.Label(root, font=(chinese_font[0], 14, "bold"))
index_label.pack(pady=10, fill=tk.X)

# Main text box with a fixed height that adjusts based on available space
main_text_box = tk.Text(root, font=chinese_font, wrap="word", padx=10, pady=10, spacing2=10, height=8)
main_text_box.pack(pady=(10, 10), padx=10, fill=tk.BOTH, expand=True)
main_text_box.config(state="disabled")  # Still read-only for main text

# Keywords text box with reduced height and enabled editing
keywords_text_box = tk.Text(root, font=chinese_font, wrap="word", padx=10, pady=10, spacing2=10, height=4)
keywords_text_box.pack(pady=(0, 20), padx=10, fill=tk.BOTH, expand=True)

def highlight_word(text_widget, word, tag_name="highlight"):
    """Highlights all occurrences of a word in a Tkinter Text widget."""
    text_widget.tag_configure(tag_name, background="yellow", foreground="black")
    start_pos = "1.0"
    while True:
        start_pos = text_widget.search(word, start_pos, stopindex="end")
        if not start_pos:
            break
        end_pos = f"{start_pos}+{len(word)}c"
        text_widget.tag_add(tag_name, start_pos, end_pos)
        start_pos = end_pos

# Toggle edit mode for keywords text box and set edit flag
def toggle_edit_mode():
    global is_edit_mode, is_edited
    is_edit_mode = not is_edit_mode
    is_edited = 1  # Set the flag to indicate that editing has started

    if is_edit_mode:
        # Switch to raw text (comma-separated) for editing
        raw_keywords = keywords_text_box.get("1.0", "end-1c").replace("\n", ", ")
        keywords_text_box.config(state="normal")  # Enable editing
        keywords_text_box.delete(1.0, "end")
        keywords_text_box.insert("end", raw_keywords)
        edit_button.config(text="Done Editing")
    else:
        # Switch back to display mode (newline-separated)
        raw_keywords = keywords_text_box.get("1.0", "end-1c")
        formatted_keywords = "\n".join([kw.strip() for kw in raw_keywords.split(",") if kw.strip()])
        keywords_text_box.delete(1.0, "end")
        keywords_text_box.insert("end", formatted_keywords)
        keywords_text_box.config(state="disabled")  # Disable editing
        edit_button.config(text="Edit Keywords")

# Display data with automatic height adjustment
def display_data():
    global index1, index2, data1, data2
    if index1 < len(data1) and index2 < len(data2):
        row1 = data1.iloc[index1]
        row2 = data2.iloc[index2]
        keywords = (row2.dropna())[:-1].tolist()
        
        try:
            index_2csv = int(next(item for item in reversed(row2) if item is not None))
        except (StopIteration, ValueError):
            index1 -= 1
            return

        if row1[0] == index_2csv:
            index_label.config(text=f"Index: {row1[0]}")
            
            main_text_box.config(state="normal")
            main_text_box.delete(1.0, "end")
            main_text_box.insert("end", f"Main Text:\n\n{row1[2]}\n")
            highlight_word(main_text_box, "人工")
            highlight_word(main_text_box, "增雨")
            main_text_box.config(state="disabled")
            
            keywords_text_box.config(state="normal")
            keywords_text_box.delete(1.0, "end")
            keywords_text_box.insert("end", "\n".join(keywords) + "\n")
            keywords_text_box.config(state="disabled")
        else:
            handle_mismatch(row1[0], index_2csv, row1[2], keywords)
    else:
        messagebox.showinfo("End of Data", "You've reached the end of the data.")

def handle_mismatch(index1_value, index2_value, text, keywords):
    global index1, index2
    mismatches.append({
        "1.csv_index": index1_value,
        "2.csv_index": index2_value,
    })
    index_label.config(text=f"Index Mismatch: {index1_value} (1.csv) vs {index2_value} (2.csv)")
    main_text_box.config(state="normal")
    main_text_box.delete(1.0, "end")
    main_text_box.insert("end", f"1.csv Text:\n\n{text}\n")
    main_text_box.config(state="disabled")

    keywords_text_box.config(state="normal")
    keywords_text_box.delete(1.0, "end")
    keywords_text_box.insert("end", "\n".join(keywords) + "\n")
    keywords_text_box.config(state="disabled")

    if index1_value < index2_value:
        index1 += 1
    else:
        index2 += 1
    display_data()

# Advance to the next index and save changes if edited
def next_entry():
    global index1, index2, is_edited
    if is_edit_mode:
        toggle_edit_mode()  # Turn off edit mode if it's on

    # Only save changes if the edit flag is set
    if is_edited == 1:
        # Get the raw comma-separated keywords from keywords_text_box
        raw_keywords = keywords_text_box.get("1.0", "end-1c").replace("\n", ", ").strip()

        # Log the index and raw keywords in changes_log.csv
        change = {
            'Index': data1.iloc[index1][0],
            'Keywords': raw_keywords
        }
        save_current_change(change)  # Save only the current change

        is_edited = 0  # Reset the edit flag

    # Move to the next entry
    index1 += 1
    index2 += 1
    display_data()

# Save mismatches to a JSON file on exit
def save_mismatches():
    serializable_mismatches = [
        {k: (int(v) if isinstance(v, (np.int64, np.int32)) else v)
         for k, v in mismatch.items()}
        for mismatch in mismatches
    ]
    with open(mismatch_log, 'w', encoding='utf-8') as f:
        json.dump(serializable_mismatches, f, ensure_ascii=False, indent=4)
    messagebox.showinfo("Mismatches Saved", "Mismatches have been saved to the JSON file.")
    root.destroy()

# Buttons for user actions
edit_button = tk.Button(root, text="Edit Keywords", command=toggle_edit_mode)
edit_button.pack(pady=5)

next_button = tk.Button(root, text="Next", command=next_entry)
next_button.pack(pady=5)

exit_button = tk.Button(root, text="Save & Exit", command=save_mismatches)
exit_button.pack(pady=5)

# Initialize by displaying the first entry
display_data()

# Run the Tkinter main loop
root.mainloop()
