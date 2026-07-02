`os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding")` for codes 
`Cloudseeding/data'` dropbox directory for data 

1. get the data from Yang Zhang: \
code: None\
input: `气象局数据/data_bureau.csv`\
output: None

2. split the data into 11 chucks\
code: `code/气象局数据/气象局数据clean.py`\
input: `气象局数据/data_bureau.csv`\
output: `气象局数据/data_bureau_{i}.csv`

3. use qwen2:7b to judge if the content is cloud-seeding related, and put all related content in the file `气象局数据/气象局数据output/output_1-11.csv` 
code: `code/气象局数据/AI_extraction_step1.py`, then manually delete ten invalid rows and changed header.\
input: `气象局数据/data_bureau_{i}.csv`\
output: `气象局数据/气象局数据output/output_file_{i}.csv`, `气象局数据/气象局数据output/output_1-11.csv` 

4. use gpt-4-turbo-2024-04-09 to extract time and location and store in `气象局数据/人工处理/时间地点.csv` 
code: `code/气象局数据/AI_extraction_step2.py`\
input: `气象局数据/气象局数据output/output_1-11.csv`\
output: `气象局数据/人工处理/时间地点.csv`

5. manually check `气象局数据/人工处理/时间地点.csv` and store in `气象局数据/人工处理/result_with_text.csv`
code: None
input: `气象局数据/人工处理/时间地点.csv`\
output: `气象局数据/人工处理/result_with_text.csv`

6. extract the post-issuing dates and store the extracted time in `气象局数据/人工处理/result_text_issuetime_cleaned.csv`. This step requires mannually cleanning, which is indicated in the code. 
code: `code/气象局数据/posting_time.py`
input: `气象局数据/人工处理/result_with_text.csv`\
output: `气象局数据/人工处理/披露时间only.csv`, `气象局数据/人工处理/披露时间only_cleaned.csv`, `气象局数据/人工处理/result_text_issuetime.csv`, `气象局数据/人工处理/need_manual_issue_time.csv`, `气象局数据/人工处理/need_manual_issue_time_url.csv`, `气象局数据/人工处理/need_manual_issue_time_url_cleaned.csv`, `气象局数据/人工处理/result_text_issuetime_cleaned.csv`

7. use `clean_result_merge_with_weibo.do` to merge with weibo cloud seeding data