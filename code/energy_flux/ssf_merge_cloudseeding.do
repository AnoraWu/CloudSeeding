cd "/Users/anorawu/Team MG Dropbox/Wanru Wu/Cloudseeding/data/SSF"

import delimited "combined_ssf.csv", clear

* collapse by group to eliminate duplicate data points 
* due to different original files cover the same day and place
ds date adcode, not
collapse `r(varlist)', by(date adcode)

gen year = real(substr(date, 1, 4))
gen month = real(substr(date, 6, 2))
gen day = real(substr(date, 9, 2))
drop date
ren adcode dt_adcode

duplicates report year month day dt_adcode

tempfile flux_data
save `flux_data'

use "/Users/anorawu/Team MG Dropbox/Wanru Wu/Cloudseeding/Cloud Seeding/data/raw/skeleton_merged2024.dta"

merge 1:1 year month day dt_adcode using `flux_data'

preserve
keep if _merge == 2
* only dt_adcode == 710000 is unmatched, we drop those data
restore

drop if _merge == 2

* final clean var name and label
label var v10 "CERES downward SW surface flux Model B clearsky"
label var v13 "CERES downward LW surface flux Model B clearsky"
ren v10 ceres_downward_sw_surface_flux_c
ren v13 ceres_downward_lw_surface_flux_c

label var ceres_sw_toa_flux___upwards "CERES SW TOA flux upwards"
label var ceres_sw_radiance___upwards "CERES SW radiance upwards"
label var ceres_lw_toa_flux___upwards "CERES LW TOA flux upwards"
label var ceres_lw_radiance___upwards "CERES LW radiance upwards"
label var ceres_wn_toa_flux___upwards "CERES WN TOA flux upwards"
label var ceres_wn_radiance___upwards "CERES WN radiance upwards"
label var toa_incoming_solar_radiation "TOA Incoming Solar Radiation"
label var ceres_downward_sw_surface_flux__ "CERES downward SW surface flux Model B"
label var ceres_net_sw_surface_flux___mode "CERES net SW surface flux Model B"
label var ceres_downward_lw_surface_flux__ "CERES downward LW surface flux Model B"
label var ceres_net_lw_surface_flux___mode "CERES net LW surface flux Model B"

save "ssf_cloudseeding.dta"

