/*
Master Do File

Purpose: Runs all code for the Protest Section

Author: Wanru(Anora) Wu

Date: 09/03/2024
*/

*------------------------------------------------------------------------------*
*Setting Directories*
*------------------------------------------------------------------------------*

*** Setting root directories - do not change unless you know the Dropbox file organization
* Set code directory
global rootdir		"/Users/anora/Documents/GitHub/CloudSeeding/code/抗议数据"

* Set Python environment executable path
* In terminal, activate environment and verify path with:
* $ conda activate cloudseeding
* $ which python  // should return the following path
global pythonpath	"/opt/anaconda3/envs/cloudseeding/bin/python"


cd "$rootdir"

* Purpose: find weibo posts that might contain the protests' time information
* input: rawdata/weibo_protest3.csv
* output: intermediate/extracted_weibo.csv
shell $pythonpath "weibo_extract.py"

* Purpose: extract the protests' time information from weibo posts
* input: intermediate/extracted_weibo.csv
* output: intermediate/extracted_weibo_time.csv
shell $pythonpath "weibo_extract_time.py"

* Purpose: refine the time information extracted from weibo posts
* input: intermediate/extracted_weibo_time.csv
* output: intermediate/extracted_weibo_time2.csv
shell $pythonpath "weibo_extract_time2.py"

* Purpose: clean the time information 
* input: intermediate/extracted_weibo_time2.csv
* output: intermediate/cleaned_time_weibo_protests.csv
shell $pythonpath "weibo_extract_time3.py"

* Purpose: prepare datasets used in "panel_data_creation_cleanedweibotime.do"
* input: 
* 1. rawdata/RFA_protest3.csv
* 2. Cloudseeding/Cloud Seeding/data/tem/cloudseeding.dta
* 3. Cloudseeding/Cloud Seeding/data/raw/meteorological data/Meteorological.dta
* output: 
* 1. intermediate/RFA_protest3_cropped.csv
* 2. intermediate/cloudseeding_adcode.csv
* 3. intermediate/meteorological_adcode.csv
shell $pythonpath "prepare_panel_data.py"

* Purpose: construct panel data for evert study analysis
* input:
* 1. rawdata/region.xlsx
* 2. rawdata/weibo_protest3.csv
* 3. intermediate/cleaned_time_weibo_protests.csv
* 4. intermediate/RFA_protest3_cropped.csv
* 5. intermediate/cloudseeding_adcode.csv
* 6. intermediate/meteorological_adcode.csv
* output:
* 1.  intermediate/region_time_cleaned.dta
* 2.  intermediate/weibo_cleaned_1.dta
* 3.  intermediate/cleaned_weibo_protests.dta
* 4.  intermediate/region_time_weibo_collapsed.dta
* 5.  intermediate/cleaned_rfa_protests.dta
* 6.  intermediate/region_time_rfa_collapsed.dta
* 7.  intermediate/protest_panel.dta
* 8.  intermediate/cleaned_cloudseeding.dta
* 9.  intermediate/protest_cloudseeding_panel.dta
* 10. intermediate/cleaned_rainfall.dta
* 11. intermediate/protest_cloudseeding_rainfal_panel.dta
* 12. final/final_panel_newweibo.dta     
do "panel_data_creation_cleanedweibotime.do"

* Purpose: clean panel data
* input: final/final_panel_newweibo.dta     
* output: final/eventstudy_city.dta
do "eventstudy_protest1.do"

* Purpose: identify events and prepare for the event study analysis
* input: final/eventstudy_city.dta
* output: final/eventstudy_weibo_city.csv
shell $pythonpath "eventstudy_clean.py"

* Purpose: 
* input: final/eventstudy_weibo_city.csv
do "eventstudy_protest2.do"



