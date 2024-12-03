# open output files and combine them for manual checking

import os
import pandas as pd
from openai import OpenAI
import csv

# Function to process text and extract date and location of '人工降雨'
def extract_time_location(text):
    prompt = f"""
    根据以下文本，返回实施人工降雨的日期和地点信息。
    请将日期格式调整为“YYYY-MM-DD”，地点格式为“省级行政区 市级行政区 县级行政区 乡级行政区”。
    如果存在多个日期或地点，请将它们按以下格式列出：“YYYY-MM-DD~YYYY-MM-DD, 省级行政区 市级行政区 县级行政区 乡级行政区;…”
    示例：2014-02-08~2014-02-18, 广西省 南宁市;广西省 百色市 田林县 乐里镇
    请仅返回指定的日期和地点信息，勿包含其他内容。
    文本："{text}"
    """
    
    response = client.chat.completions.create(
        model="gpt-4-turbo-2024-04-09",
        messages=[
            {
                "role": "user",
                "content": prompt,
            },
        ],
    )
    content = response.choices[0].message.content.strip()
    print(content)
    return content

if __name__ == "__main__":

    os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding/data/气象局数据/气象局数据output")


    # Load your API key securely (do not hardcode it in production)
    client = OpenAI(
        # This is the default and can be omitted
        api_key='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'
    )

    start_index = 0

    # Load the CSV file
    file_path = 'output_1-11.csv'  
    data = pd.read_csv(file_path)

    for index,row in data.iloc[start_index:].iterrows():
    # Apply the function to each row in the target column
        with open('时间地点.csv', 'a') as csvfile:  
            csvfile.write(extract_time_location(row['气象局公告内容'])+','+str(row['index'])) 
            csvfile.write('\n')

