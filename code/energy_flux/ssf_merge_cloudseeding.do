clear all
cd "/Users/anora/Team MG Dropbox/Wanru Wu/Cloudseeding_Anora/SSF/intermediate"

import delimited "combined_ssf.csv", clear

* collapse by group to eliminate duplicate data points 
* due to different original files cover the same day and place
ds date adcode, not
collapse (mean) `r(varlist)', by(date adcode)


gen year = real(substr(date, 1, 4))
gen month = real(substr(date, 6, 2))
gen day = real(substr(date, 9, 2))
drop date
ren adcode dt_adcode

duplicates report year month day dt_adcode

tempfile flux_data
save `flux_data'


* merge with skeleton
use "skeleton_merged2024.dta"

replace dt_adcode = ct_adcode if dt_adcode == .
replace ct_adcode = pr_adcode if ct_adcode ==.

merge 1:1 year month day dt_adcode using `flux_data'

preserve
keep if _merge == 2
* dt_adcode == 710000 is unmatched, we drop those data
* dates after 2024 sep 1st are not available in skeleton, we drop as well
restore

drop if _merge == 2

* final clean var name and label
label var v13 "CERES downward SW surface flux Model B clearsky"
label var v16 "CERES downward LW surface flux Model B clearsky"
ren v13 ceres_downward_sw_surface_flux_c
ren v16 ceres_downward_lw_surface_flux_c

label var ceres_viewing_zenith_at_surface "CERES viewing zenith at surface"
ren ceres_viewing_zenith_at_surface viewing_zenith 

label var ceres_relative_azimuth_at_surfac "CERES relative azimuth at surface"
ren ceres_relative_azimuth_at_surfac relative_azimuth

label var ceres_solar_zenith_at_surface "CERES solar zenith at surface"
ren ceres_solar_zenith_at_surface solar_zenith

label var ceres_sw_toa_flux___upwards "CERES SW TOA flux upwards"
ren ceres_sw_toa_flux___upwards sw_toa_flux_up

label var ceres_sw_radiance___upwards "CERES SW radiance upwards"
ren ceres_sw_radiance___upwards sw_radiance_up

label var ceres_lw_toa_flux___upwards "CERES LW TOA flux upwards"
ren ceres_lw_toa_flux___upwards lw_toa_flux_up

label var ceres_lw_radiance___upwards "CERES LW radiance upwards"
ren ceres_lw_radiance___upwards lw_radiance_up

label var ceres_wn_toa_flux___upwards "CERES WN TOA flux upwards"
ren ceres_wn_toa_flux___upwards wn_toa_flux_up

label var ceres_wn_radiance___upwards "CERES WN radiance upwards"
ren ceres_wn_radiance___upwards wn_radiance_up

label var toa_incoming_solar_radiation "TOA Incoming Solar Radiation"

label var ceres_downward_sw_surface_flux__ "CERES downward SW surface flux Model B"
ren ceres_downward_sw_surface_flux__ down_sw_surface_flux

label var ceres_net_sw_surface_flux___mode "CERES net SW surface flux Model B"
ren ceres_net_sw_surface_flux___mode net_sw_surface_flux

label var ceres_downward_lw_surface_flux__ "CERES downward LW surface flux Model B"
ren ceres_downward_lw_surface_flux__ down_lw_surface_flux

label var ceres_net_lw_surface_flux___mode "CERES net LW surface flux Model B"
ren ceres_net_lw_surface_flux___mode net_lw_surface_flux

label var ceres_lw_surface_emissivity "CERES LW surface emissivity"
ren ceres_lw_surface_emissivity lw_surface_emissivity

label var ceres_wn_surface_emissivity "CERES WN surface emissivity"
ren ceres_wn_surface_emissivity wn_surface_emissivity

label var ceres_broadband_surface_albedo "CERES broadband surface albedo"
ren ceres_broadband_surface_albedo broadband_surface_albedo

label var ceres_downward_lw_surface_flux_c "CERES downward LW surface flux - Model B, clearsky"
ren ceres_downward_lw_surface_flux_c down_lw_surface_flux_c

label var ceres_downward_sw_surface_flux_c "CERES downward SW surface flux - Model B, clearsky"
ren ceres_downward_sw_surface_flux_c down_sw_surface_flux_c

drop _merge


save "skeleton_merged2024_ssf.dta", replace

