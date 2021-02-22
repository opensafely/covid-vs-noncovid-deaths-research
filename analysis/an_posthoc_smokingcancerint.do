
cap log close
log using ./analysis/output/an_posthoc_smokingcancerint, replace t

use  ./analysis/cr_create_analysis_dataset_MAIN_STSET.dta, clear
gen coviddeath = onsdeath==1
gen noncoviddeath = onsdeath>1 & onsdeath<.

logistic coviddeath age1 age2 age3 male i.stp i.smoke_nomiss##i.cancer_exhaem
estimates save ./analysis/output/models/an_posthoc_smokingcancerint_COV, replace
testparm i.smoke_nomiss#i.cancer_exhaem

logistic noncoviddeath age1 age2 age3 male i.stp i.smoke_nomiss##i.cancer_exhaem
estimates save ./analysis/output/models/an_posthoc_smokingcancerint_NONCOV, replace
testparm i.smoke_nomiss#i.cancer_exhaem

log close

