*-------------------------------------------------------------*
* 1. Control group (imply == 0)
*-------------------------------------------------------------*

* 1a. Compute mean and count for control
quietly summarize station_20_20 if imply==0
local mean0 = r(mean)       // sample mean for control
local n0    = r(N)          // sample size for control

* 1b. Create deviation and squared‐deviation for control
generate double diff0 = station_20_20 - `mean0' if imply==0
generate double sqdiff0 = diff0^2                   if imply==0

* 1c. Sum the squared deviations for control
quietly summarize sqdiff0 if imply==0
local sumsq0 = r(sum)        // ∑(x_i − mean0)^2

* 1d. Compute standard deviation for control: sqrt[∑(x−mean)^2/(n−1)]
local sd0 = sqrt(`sumsq0'/(`n0' - 1))

display as text "Standard deviation (control, imply==0): " as result %9.4f `sd0'


*-------------------------------------------------------------*
* 2. Treatment group (imply == 1)
*-------------------------------------------------------------*

* 2a. Compute mean and count for treatment
quietly summarize station_20_20 if imply==1
local mean1 = r(mean)       // sample mean for treatment
local n1    = r(N)          // sample size for treatment

* 2b. Create deviation and squared‐deviation for treatment
generate double diff1 = station_20_20 - `mean1' if imply==1
generate double sqdiff1 = diff1^2                   if imply==1

* 2c. Sum the squared deviations for treatment
quietly summarize sqdiff1 if imply==1
local sumsq1 = r(sum)        // ∑(x_i − mean1)^2

* 2d. Compute standard deviation for treatment: sqrt[∑(x−mean)^2/(n−1)]
local sd1 = sqrt(`sumsq1'/(`n1' - 1))

display as text "Standard deviation (treatment, imply==1): " as result %9.4f `sd1'


*-------------------------------------------------------------*
* 3. (Optional) Clean up intermediate variables
*-------------------------------------------------------------*

drop diff0 sqdiff0 diff1 sqdiff1
