*an_impute
*KB 16/7/2020

cap log close
log using ./output/an_impute, replace t

run global 

frames reset
use "cr_create_analysis_dataset_STSET_onsdeath_fail1", clear

drop if _st==0

mi set wide
mi register imputed ethnicity

*Gen NA Cum Haz
sts generate cumh = na
egen cumhgp = cut(cumh), group(5)
replace cumhgp = cumhgp + 1

mi impute mlogit ethnicity i.hiv i.stp $adjustmentlist i.cumhgp _d, add(10) rseed(3040985)

save an_impute_imputeddata, replace

log close
