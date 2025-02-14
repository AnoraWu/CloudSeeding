import ollama
import pandas as pd
import csv
import os
from multiprocessing import Pool

def get_qwen_response(row,output_file,index):
    # 构造prompt
    prompt = f"""目标：请判断“{row['posts']}”是否有具体日期的表述,例如有“2016.6.15”、“11月三日”、“昨天”、“星期三”等等。
    如果有，则返回“True”。如果没有，则返回“False”。
    除此之外不要返回任何东西。
    """
    response = ollama.chat(model="qwen2:7b", messages=[
        {
            "role": "user",
            "content": prompt,
        },
    ])
    result = response['message']['content']
    if "true" in result.lower():
        row['contain_time'] = result
        df_row = pd.DataFrame([row])
        df_row.to_csv(output_file, mode='a', sep=',', index=False, header=False, lineterminator='\n')

    if (index / 1000) == int(index / 1000):
        print(index)


if __name__ == "__main__":
    
    folder_dir  = r"/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"
    input_file   = rf"{folder_dir}/weibo_protest3.csv"
    output_file = rf"{folder_dir}/extracted_weibo.csv"

    df = pd.read_csv(input_file, encoding="utf-8",dtype={"省":"string","市":"string","区":"string"})

    if not os.path.exists(output_file):
        with open(output_file, mode="w", newline="", encoding="utf-8") as f:
            header = ["event_id","posts","words","issues","forms",
                      "ML_violence","ML_forms","ML_police","ML_target",
                      "size_max","size_mean","省","市","区","adcode","year",
                      "month","day","ym","ymd","citycode","domains"]
            writer = csv.writer(f)
            writer.writerow(header)

    # Use multiprocessing
    num_workers = 9
    args = [(row,output_file,index) for index, row in df.iterrows()]
    with Pool(num_workers) as pool:
        pool.starmap(get_qwen_response,args)

    