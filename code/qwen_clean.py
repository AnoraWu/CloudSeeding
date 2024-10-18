import ollama
import pandas as pd
import csv
import logging
import sys
import json

def get_qwen_response(row):
    # 构造prompt
    prompt = f"""
请你提取出{row["operation_area"]}中的省份、地级市（或同一行政级别的州等行政区划）、县（或同一行政级别的区等行政区划）。
你的回答应仅以json列表的格式进行返回，格式例如： [{{"province": "贵州", "city": "毕节", "county": "七星关区"}}, {{"province": "四川", "city": "成都", "county": "双流区"}}]。
请注意：
1.如果某一级行政区划不存在，请将对应的字段置为None。
2.对于省一级的行政区划，只保留其简称，例如："贵州省"应返回"贵州"而不是"贵州省"。
3.对于地级市一级的行政区划，只保留其简称，例如："毕节市"应返回"毕节"而不是"毕节市"。
4.对于县一级的行政区划，应该保留全称。
5.如果出现无法识别的地名，请将对应的字段置为None。例如："池州市里山镇"你可能无法识别是哪个区（或同一级行政区划），应返回 [{{"province": "安徽", "city": "池州", "county": "None"}}]。
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
    df = pd.read_csv('qwen_clean.csv', encoding='utf-8')
    
    start_index = 0  # 设置开始分析的索引

    # 如果存在之前保存的索引，可以从中加载
    try:
        with open('index.txt', 'r') as f:
            start_index = int(f.read().strip())
    except FileNotFoundError:
        pass

    # 遍历每一行并处理
    with open('output_file.csv', 'a', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        # 写入列名
        if start_index == 0:
            writer.writerow(list(df.columns) + ['prov', 'city', 'county'])
        
        for index, row in df.iloc[start_index:].iterrows():  # 从指定的索引开始
            try:
                result = get_qwen_response(row)
                result_json = json.loads(result)
                
                # 遍历返回的JSON列表
                for item in result_json:
                    new_row = row.copy()
                    new_prov = item.get('province', None)
                    new_city = item.get('city', None)
                    new_county = item.get('county', None)
                    writer.writerow(new_row.tolist() + [new_prov, new_city, new_county])

            except Exception as e:
                logging.error(f"Error processing row {index}: {e}")
                print(f"Error processing row {index}: {e}")
                # 保存当前索引
                with open('index.txt', 'w') as f:
                    f.write(str(index))
                # 如果出错，写入None值
                writer.writerow(row.tolist() + [None, None, None])
                continue  # 继续处理下一个数据行
