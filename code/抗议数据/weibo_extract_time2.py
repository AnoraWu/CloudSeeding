import ollama
import pandas as pd
import csv
import os
from multiprocessing import Pool

def get_qwen_response(row,output_file,index):
    # 构造prompt
    prompt = f"""这条微博发布于“{row['year']}年{row['month']}月{row['day']}日”,而“{row['time1']}”是微博中提到的时间。
    请根据逻辑判断“{row['time1']}”的日期，如果无法得出日期则返回”None“
    如果微博中提到多个时间，则全部判断并返回。
    格式：xxxx年xx月xx日
    除此之外不要返回任何其他内容和推理过程。
    例子：
    1. 微博发布于“2012年9月2日”，而微博中提到的时间是“昨天凌晨4点半”，那么则判断微博中提到的日期应为2012年9月1日。
    2. 微博发布于“2012年6月3日”，而微博中提到的时间是“6月1日”，那么则判断微博中提到的日期应为2012年6月1日。
    3. 微博发布于“2012年2月26日”，而微博中提到的时间是“2013年2月21日”，那么则判断微博中提到的日期应为2013年2月21日。
    3. 微博发布于“2012年2月26日”，而微博中提到的时间是“今天”，那么则判断微博中提到的日期应为2013年2月26日。
    """
    response = ollama.chat(model="qwen2:7b", messages=[
        {
            "role": "user",
            "content": prompt,
        },
    ])
    result = response['message']['content']
    row['time2'] = result
    df_row = pd.DataFrame([row])[["posts","size_mean","省","市","区","adcode","year",
                      "month","day","citycode","time1","time2"]]
    df_row.to_csv(output_file, mode='a', sep=',', index=False, header=False, lineterminator='\n')

    if (index / 1000) == int(index / 1000):
        print(index)


if __name__ == "__main__":
    
    folder_dir  = r"/Users/anorawu/BFI Dropbox/Wanru Wu/Cloudseeding/data/抗议数据"
    input_file   = rf"{folder_dir}/extracted_weibo_time.csv"
    output_file = rf"{folder_dir}/extracted_weibo_time2.csv"

    df = pd.read_csv(input_file, encoding="utf-8",dtype={"省":"string","市":"string","区":"string"},index_col=False )

    if not os.path.exists(output_file):
        with open(output_file, mode="w", newline="", encoding="utf-8") as f:
            header = ["posts","size_mean","省","市","区","adcode","year",
                      "month","day","citycode","time1","time2"]
            writer = csv.writer(f)
            writer.writerow(header)

    # Use multiprocessing
    num_workers = 8
    args = [(row,output_file,index) for index, row in df.iterrows()]
    with Pool(num_workers) as pool:
        pool.starmap(get_qwen_response,args)

    