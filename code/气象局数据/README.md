`os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding")` for codes 
`Cloudseeding/data'` dropbox directory for data 

1. get the data from Yang Zhang 
    data: `data/气象局数据/data_bureau.csv`
2. split into 11 chucks (`code/气象局数据/气象局数据clean.py`)
3. use qwen2:7b to judge if the content is cloud-seeding related, and put all related content in the file `data/气象局数据/气象局数据output/output_1-11.csv` (`code/气象局数据/AI_extraction_step1.py`), manually delete ten invalid rows and changed header.
4. use gpt-4-turbo-2024-04-09 to extract time and location and store in `data/气象局数据/人工处理/时间地点.csv` (`code/气象局数据/AI_extraction_step2.py`)
5. manually check `data/气象局数据/人工处理/时间地点.csv` and store in `data/气象局数据/人工处理/result_with_text.csv`
6. extract the post-issuing dates (`code/气象局数据/posting_time.py`) and store the extracted time in `data/气象局数据/人工处理/result_text_issuetime_cleaned.csv` 
7. use `clean_result_merge_with_weibo.do` to merge with weibo cloud seeding data