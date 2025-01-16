`os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding")`

1. get the data from Yang Zhang (`data/气象局数据/data_bureau.csv`)
2. split into 11 chucks (`code/气象局数据/气象局数据clean.py`)
3. use qwen2:7b to judge if the content is cloudseeding related, and put all related content in the file `data/气象局数据/气象局数据output/output_1-11.csv` (`code/气象局数据/AI_extraction_step1.py`), mannually changed header (first column as 'index', second column has no header). Also, ten invalid rows was deleted
4. use gpt-4-turbo-2024-04-09 to extract time and location and store in `data/气象局数据/人工处理/时间地点.csv` (`code/气象局数据/AI_extraction_step2.py`)
5. manually check for time and location, record the changes in `data/气象局数据/人工处理/changes_log.csv` 
6. update `data/气象局数据/人工处理/时间地点.csv` with `data/气象局数据/人工处理/changes_log.csv`, create `data/气象局数据/人工处理/merged_output.csv`, and clean the data to store in the `data/气象局数据/人工处理/result.csv`. The cleanning process requires manual adjustment of `data/气象局数据/人工处理/merged_output.csv` . (`code/气象局数据/人工处理code/helpmerge.py`)
7. for machine-learning training purposes, mannually add '炮台信息' to `data/气象局数据/人工处理/result.csv` and store in `data/气象局数据/人工处理/result_炮台.csv`

(result.csv and output_1_11.csv has the same index system)