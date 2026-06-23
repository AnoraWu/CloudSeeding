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

shell $pythonpath "weibo_extract.py"

shell $pythonpath "weibo_extract_time.py"

shell $pythonpath "weibo_extract_time2.py"

shell $pythonpath "weibo_extract_time3.py"

do "panel_data_creation_cleanedweibotime.do"

do "eventstudy_protest.do"




