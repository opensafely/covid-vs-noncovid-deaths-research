
use ./output/an_covidvsnoncovid_full_mlogitabsrisk_ESTIMATES, clear
gen nameshort=""
replace nameshort="asthma" if variable=="asthmacat"
replace nameshort="cancer" if variable=="cancer_exhaem_cat"
replace nameshort="haem_can" if variable=="cancer_haem_cat"
replace nameshort="cardiac" if variable=="chronic_cardiac_disease"
replace nameshort="liver" if variable=="chronic_liver_disease"
replace nameshort="respiratory" if variable=="chronic_respiratory_disease"
replace nameshort="diab" if variable=="diabcat"
replace nameshort="ethnic" if variable=="ethnicity"
replace nameshort="htn" if variable=="htdiag_or_highbp"
replace nameshort="imd" if variable=="imd"
replace nameshort="male" if variable=="male"
replace nameshort="obese" if variable=="obese4cat"
replace nameshort="org_trans" if variable=="organ_transplant"
replace nameshort="other_immun" if variable=="other_immunosuppression"
replace nameshort="other_neur" if variable=="other_neuro"
replace nameshort="ra_etc" if variable=="ra_sle_psoriasis"
replace nameshort="kidney" if variable=="reduced_kidney_function_cat"
replace nameshort="smoke" if variable=="smoke_nomiss"
replace nameshort="spleen" if variable=="spleen"
replace nameshort="stroke_dem" if variable=="stroke_dementia"

gen variable_level = nameshort + string(level)

graph bar pnoncovdeath pcovdeath , stack over(variable_level, label(angle(45))) legend(label(1 "Pr(non-cov death)") label(2 "Pr(covid death)")) 

graph export ./output/an_processout_mlogit_absolutes.svg, as(svg)
