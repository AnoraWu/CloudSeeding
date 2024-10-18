import ollama
import pandas as pd
import csv
import logging
import sys
import json
import os

def get_qwen_response(row):
    # 构造prompt
    prompt = f"""
    目标：请帮助我
    1. 根据作业时间、作业地点等判断是否包含人工降雨相关信息。
    2. 如果包含，提取{row["气象局公告内容"]}所有与人工增雨作业相关的时间和地点信息，你的回答应仅以json列表的格式进行返回，格式如下 
    具体要求：
    1. 时间：提取出所有表示作业时间的词组或句子，包括精确的日期、时间、以及模糊时间表达（如“下午”、“上周”等）。
    2. 地点：提取出所有表示作业地点的词组或句子，包括具体地名/区域范围/城市名/地区名/省名等。
    3. 输出格式：你的回答应仅以json列表的格式进行返回，格式例如：[{{"time":"2024年10月12日", "location":"河北省张家口市"}},{{"time":"上午10点至下午2点", "location":"重庆市郊区"}}]
    4. 如果没有相关时间或者是地点信息，就返回空白，例如：[{{"time":"", "location":""}},{{"time":"", "location":"重庆市郊区"}}]
    """

    response = ollama.chat(model='qwen2:7b', messages=[
        {
            'role': 'user',
            'content': prompt,
        },
    ])
    result = response['message']['content']
    print(result)
    return result

if __name__ == "__main__":
    logging.basicConfig(filename='log.txt', level=logging.ERROR)  # 设置日志文件

    # 读取原始 CSV 文件
    os.chdir('/Users/anorawu/Documents/GitHub/CloudSeeding/data/气象局数据')
    for i in range(0,111):
        df = pd.read_csv('气象局数据_{num}.csv'.format(num=i), encoding='utf-8')
        
        start_index = 0  # 设置开始分析的索引

        # 如果存在之前保存的索引，可以从中加载
        try:
            with open('index.txt', 'r') as f:
                start_index = int(f.read().strip())
        except FileNotFoundError:
            pass

        # 遍历每一行并处理
        with open('output_file_{num}.csv'.format(num=i), 'a', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            # 写入列名
            if start_index == 0:
                writer.writerow(list(df.columns) + ['time', 'location'])
            
            for index, row in df.iloc[start_index:].iterrows():  # 从指定的索引开始
                try:
                    result = get_qwen_response(row)
                    result_json = json.loads(result)
                    
                    # 遍历返回的JSON列表
                    for item in result_json:
                        new_row = row.copy()
                        new_time = item.get('time', None)
                        new_location = item.get('location', None)
                        writer.writerow(new_row.tolist() + [new_time, new_location])

                except Exception as e:
                    logging.error(f"Error processing row {index}: {e}")
                    print(f"Error processing row {index}: {e}")
                    # 保存当前索引
                    with open('index.txt', 'w') as f:
                        f.write(str(index))
                    # 如果出错，写入None值
                    writer.writerow(row.tolist() + [None, None])
                    continue  # 继续处理下一个数据行
