`os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding")` for codes 
dropbox for data 

1. get the data from Yang Zhang (`data/气象局数据/data_bureau.csv`)
2. split into 11 chucks (`code/气象局数据/气象局数据clean.py`)
3. use qwen2:7b to judge if the content is cloudseeding related, and put all related content in the file `data/气象局数据/气象局数据output/output_1-11.csv` (`code/气象局数据/AI_extraction_step1.py`), mannually changed header (first column as 'index', second column has no header). Also, ten invalid rows was deleted
4. use gpt-4-turbo-2024-04-09 to extract time and location and store in `data/气象局数据/人工处理/时间地点.csv` (`code/气象局数据/AI_extraction_step2.py`)
5. manually check for time and location, record the changes in `data/气象局数据/人工处理/changes_log.csv` 
6. update `data/气象局数据/人工处理/时间地点.csv` with `data/气象局数据/人工处理/changes_log.csv`, create `data/气象局数据/人工处理/merged_output.csv`, and clean the data to store in the `data/气象局数据/人工处理/result.csv`. The cleanning process requires manual adjustment of `data/气象局数据/人工处理/merged_output.csv` . (`code/气象局数据/人工处理code/helpmerge.py`)
7. result.csv and output_1_11.csv has the same index system, the combined version is `data/气象局数据/人工处理/result_with_text.csv`)
8. extract the posts issue dates (`code/气象局数据/extract_posting_time.py`) and store the extracted time in `data/气象局数据/人工处理/披露时间.csv` and `data/气象局数据/人工处理/披露时间only.csv` （披露时间only是披露时间去掉'气象局公告内容'这一个column的文件）
9. manually clean the time data and store in `data/气象局数据/人工处理/披露时间only.csv` 