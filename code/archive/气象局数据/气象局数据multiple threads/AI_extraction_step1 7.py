import ollama
import pandas as pd
import csv
import logging
import sys
import json
import os
# from openai import OpenAI

# os.environ["OPENAI_API_KEY"] = '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'

def get_qwen_response(row):
    # 构造prompt
    prompt = f"""
    目标：请帮助我根据逻辑判断{row["气象局公告内容"]}是否包含人工降雨这个动作发生的地点或者时间信息。仅返回'True'或者'False'
    1. 如果包含，返回'True'
    2. 如果不包含，返回'False'
    3. 除了以上两种情况，不要返回任何其他值
    4. 一个返回'True'的例子是：'3月16日，湖北荆门沙尘来袭，出现中度以上污染。荆门市气象局迅速开展“人工增雨”作业，沉降空气中的扬沙与浮尘，发射增雨“火箭弹”四枚，人工增雨后效果明显。据荆门市气象局副局长苏磊介绍，这次适时开展人工增雨作业，对改善空气质量起到一定帮助'
    5. 一个返回'False'的例子是：'科学调度服务生态发展，增雨江淮共筑美好安徽”。为感谢民航安徽空管局对我省人工影响天气工作的支持，4月10日下午，省局党组成员、副局长包正擎带领减灾处、人影办和信息公司负责人赴民航安徽空管局对接工作，并赠送锦旗。民航安徽空管局副局长丁浩及相关处室和单位负责人参加了座谈会。双方围绕重大活动、抗旱和蓝天保卫战等人工影响天气活动空域管制协调，以及航空气象服务合作等方面进行了深入交流。'
    6. 如果难以确定，返回’True‘
    7. 如果包含其他格式，例如，xml文档，返回'True'
    """
    # Send the request to the model
    # client = OpenAI(
    #     # This is the default and can be omitted
    #     api_key=os.environ.get("OPENAI_API_KEY"),
    # )

    response = ollama.chat(model="qwen2:7b", messages=[
        {
            "role": "user",
            "content": prompt,
        },
    ])
    result = response['message']['content']
    return result


if __name__ == "__main__":
    
    logging.basicConfig(filename="log.txt", level=logging.ERROR)  # 设置日志文件

    os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding/data/气象局数据")
    df = pd.read_csv("data_bureau_7.csv", encoding="utf-8")
    
    start_index = 1370  # 设置开始分析的索引

    # 如果存在之前保存的索引，可以从中加载
    try:
        with open("index.txt", "r") as f:
            start_index = int(f.read().strip())
    except FileNotFoundError:
        pass

    # 遍历每一行并处理
    os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding/data/气象局数据output")
    with open("output_file_7.csv", "a", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        # 写入列名
        if start_index == 0:
            writer.writerow(list(df.columns))
        
        for index, row in df.iloc[start_index:].iterrows():  # 从指定的索引开始

            try:
                result = get_qwen_response(row)
                print(7)
                print(index)
                print(result)
                if 'True' in result:
                    writer.writerow(row.tolist())

            except Exception as e:
                logging.error(f"Error processing row {index}: {e}")
                print(f"Error processing row {index}: {e}")
                # 保存当前索引
                with open("index.txt", "w") as f:
                    f.write(str(index))
                continue  # 继续处理下一个数据行
