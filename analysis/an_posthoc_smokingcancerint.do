
cap log close
log using ./analysis/output/an_posthoc_smokingcancerint, replace t

/*
use  ./analysis/cr_create_analysis_dataset_MAIN_STSET.dta, clear
gen coviddeath = onsdeath==1
gen noncoviddeath = onsdeath>1 & onsdeath<.

logistic coviddeath age1 age2 age3 male i.stp i.smoke_nomiss##i.cancer_exhaem
estimates save ./analysis/output/models/an_posthoc_smokingcancerint_COV, replace
testparm i.smoke_nomiss#i.cancer_exhaem

logistic noncoviddeath age1 age2 age3 male i.stp i.smoke_nomiss##i.cancer_exhaem
estimates save ./analysis/output/models/an_posthoc_smokingcancerint_NONCOV, replace
testparm i.smoke_nomiss#i.cancer_exhaem
*/

use  ./analysis/cr_create_analysis_dataset_MAIN_STSET.dta, clear

keep if _d==1
gen coviddeath = onsdeath==1

gen hoc = (cancer_ex == 2)|(cancer_ex == 3)|(cancer_ex == 4)|(cancer_h == 2)|(cancer_h == 3)|(cancer_h == 4)
logistic coviddeath age1 age2 age3 i.male i.stp i.cancer_exhaem  i.cancer_haem i.smoke_nomiss 1.hoc#2.smoke_nomiss 1.hoc#3.smoke_nomiss 
lincom 3.smoke_nomiss+ 1.hoc#3.smoke_nomiss, or

log close

