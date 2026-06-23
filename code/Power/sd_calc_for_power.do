use "/Users/anora/Library/CloudStorage/Dropbox-TeamMG/Wanru Wu/Cloudseeding/Cloud Seeding/data/tem/match/forecast_rain/psm_10days.dta", clear

sort id_c id_t year month day

*-------------------------------------------------------------*
* 1. Calculate Control Group SD for EU = 24h
*-------------------------------------------------------------*

preserve

keep if refy == 0 
* drop unmatched ones
drop if id_c == 14723292 & id_t == 8533743
drop if id_c == 8936961 & id_t == 8533743

* drop missing precipitation values
drop if rain_IDW ==.

* compute mean and count for control
quietly summarize rain_IDW if imply==0
local mean0 = r(mean)       // sample mean for control
local n0    = r(N)          // sample size for control

* create deviation and squared‐deviation for control
generate double diff0 = rain_IDW - `mean0' if imply==0
generate double sqdiff0 = diff0^2 if imply==0

* sum the squared deviations for control
quietly summarize sqdiff0 if imply==0
local sumsq0 = r(sum)        // ∑(x_i − mean0)^2

* compute standard deviation for control: sqrt[∑(x−mean)^2/(n−1)]
local sd0 = sqrt(`sumsq0'/(`n0' - 1))

display as text "Standard deviation (control, imply==0): " as result %9.4f `sd0'

restore


*-------------------------------------------------------------*
* 2. Calculate Percentage of Correct Guess of Lady Tea Test
*-------------------------------------------------------------*

// preserve

// keep if refy == 0 
// * drop unmatched ones
// drop if id_c == 14723292 & id_t == 8533743
// drop if id_c == 8936961 & id_t == 8533743

// * drop missing precipitation values
// drop if rain_IDW ==.

// keep rain_IDW id_c id_t imply
// reshape wide rain_IDW, i(id_c id_t) j(imply)

// * drop if both control and target has no rainfall
// drop if (rain_IDW0 == 0) & (rain_IDW1 == 0)


// gen indi = rain_IDW1 - rain_IDW0
// count if indi > 0
// count if indi == 0 
// count if indi < 0 

// // di 9787 /  (6517+9787)
// // 0.60028214

// restore



*-------------------------------------------------------------*
* 3. Calculate PSM Coefficient for Day 0
*-------------------------------------------------------------*

// preserve
//
// gen event = refy+7
// fvset base 6 event
//
// egen unique_county=group(dt_adcode id_t)
// egen doy=group(month day)
//
// egen calendar_month=group(year month)
//
// gen cluster=.
// replace cluster = id_t if imply==1
// replace cluster = id_c if imply==0
//
//
// reghdfe rain_IDW i.event##c.imply, absorb(unique_county i.refy#i.id_t doy) vce(cluster cluster calendar_month)
//
// restore







