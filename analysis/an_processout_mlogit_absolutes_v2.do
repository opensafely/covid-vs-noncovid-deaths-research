
use ./output/an_covidvsnoncovid_full_mlogitabsrisk_v2_ESTIMATES, clear
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

replace nameshort="NO RISK FACTORS" if nameshort==""

gen variable_level = nameshort + string(level)

label define agegrouplab 1 "18-39" 2 "40-49" 3 "50-59" 4 "60-69" 5 "70-79" 6 "80+"
label values agegroup agegrouplab

graph bar pnoncovdeath pcovdeath , over(variable_level, label(angle(90) labsize(tiny))) over(nameshort, label(nolabels)) nofill legend(label(1 "Pr(non-cov death)") label(2 "Pr(covid death)")) by(agegroup, title("Abs risk of cov and non-cov death, " "by individual risk factors - single yscale", size(medium))) ylabel(,angle(0)) xsize(7)
graph export ./output/an_processout_mlogit_absolutes_v2_BOTH_SINGLEY.svg, as(svg) 

graph bar pnoncovdeath pcovdeath , over(variable_level, label(angle(90) labsize(tiny))) over(nameshort, label(nolabels)) nofill legend(label(1 "Pr(non-cov death)") label(2 "Pr(covid death)")) by(agegroup, yrescale title("Abs risk of cov and non-cov death, " "by individual risk factors - variable yscale", size(medium))) ylabel(,angle(0) )  xsize(7)
graph export ./output/an_processout_mlogit_absolutes_v2_BOTH_VARIABLEY.svg, as(svg)

graph bar pcovdeath , over(variable_level, label(angle(90) labsize(tiny))) over(nameshort, label(nolabels)) nofill legend(label(1 "Pr(non-cov death)") label(2 "Pr(covid death)")) by(agegroup,  title("Abs risk of covid death only, " "by individual risk factors - single yscale", size(medium))) ylabel(,angle(0) ) bar(1, color(maroon))  xsize(7)
graph export ./output/an_processout_mlogit_absolutes_v2_COV_SINGLEY.svg, as(svg)

graph bar pcovdeath , over(variable_level, label(angle(90) labsize(tiny))) over(nameshort, label(nolabels)) nofill legend(label(1 "Pr(non-cov death)") label(2 "Pr(covid death)")) by(agegroup, yrescale title("Abs risk of covid death only, " "by individual risk factors - variable yscale", size(medium))) ylabel(,angle(0) ) bar(1, color(maroon))  xsize(7)
graph export ./output/an_processout_mlogit_absolutes_v2_COV_VARIABLEY.svg, as(svg)

*graph export ./output/an_processout_mlogit_absolutes_v2.svg, as(svg)
