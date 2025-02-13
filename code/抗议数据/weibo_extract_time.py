import ollama
import pandas as pd
import csv
import os
from multiprocessing import Pool

def get_qwen_response(row,output_file,index):
    # 构造prompt
    prompt = f"""目标：请判断“{row['posts']}”里面的日期和时间信息。返回这个日期和时间信息。除此之外不要返回任何东西。
    例子如下：
    1. 2012年1月22日下午
    2. 九月二十五日凌晨四五点
    3. 大年初三
    """
    response = ollama.chat(model="qwen2:7b", messages=[
        {
            "role": "user",
            "content": prompt,
        },
    ])
    result = response['message']['content']
    row['time1'] = result
    df_row = pd.DataFrame([row])[["posts","size_max","size_mean","省","市","区","adcode","year",
                    "month","day","citycode","time1"]]
    df_row.to_csv(output_file, mode='a', sep=',', index=False, header=False, lineterminator='\n')

    if (index / 1000) == int(index / 1000):
        print(index)


if __name__ == "__main__":
    
    folder_dir  = r"/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"
    input_file   = rf"{folder_dir}/extracted_weibo.csv"
    output_file = rf"{folder_dir}/extracted_weibo_time.csv"

    df = pd.read_csv(input_file, encoding="utf-8",dtype={"省":"string","市":"string","区":"string"},index_col=False)

    if not os.path.exists(output_file):
        with open(output_file, mode="w", newline="", encoding="utf-8") as f:
            header = ["posts","size_max","size_mean","省","市","区","adcode","year",
                      "month","day","citycode","time1"]
            writer = csv.writer(f)
            writer.writerow(header)

    # Use multiprocessing
    num_workers = 8
    args = [(row,output_file,index) for index, row in df.iterrows()]
    with Pool(num_workers) as pool:
        pool.starmap(get_qwen_response,args)

    