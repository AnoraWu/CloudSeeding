/*
Master Do File

Purpose: Runs all code for the Disaster Section

Author: Wanru(Anora) Wu

Date: 09/03/2024
*/

*------------------------------------------------------------------------------*
*Setting Directories*
*------------------------------------------------------------------------------*

*** Setting root directories - do not change unless you know the Dropbox file organization
* Set code directory
global rootdir		"/Users/anora/Documents/GitHub/CloudSeeding/code/灾害数据"

* Set Python environment executable path
* In terminal, activate environment and verify path with:
* $ conda activate cloudseeding
* $ which python  // should return the following path
global pythonpath	"/opt/anaconda3/envs/cloudseeding/bin/python"


cd "$rootdir"

shell $pythonpath "disaster_clean.py"

do "disaster_clean.do"

do "nice_table.do"


