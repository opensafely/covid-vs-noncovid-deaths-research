
cap log close
log using "./analysis/output/_kbhadhoc_ETHBYAGE", replace t

postfile results str5 agetype ageval ethval estimate lci uci using "./analysis/output/_kbhadhoc_ETHBYAGE_estimates", replace

cap prog drop postres
prog define postres
post results ("`1'") (`2') (`3') (r(estimate)) (r(lb)) (r(ub))
end

use "./analysis/cr_create_analysis_dataset_SEPT2020_STSET.dta" , clear

gen coviddeath = died_ons_covid_flag_any==1 & died_date_ons<=d(9/11/2020)

tab coviddeath

stset stime_onsdeath, fail(coviddeath) id(patient_id) enter(enter_date) origin(enter_date)

*Agegroup interaction (<70 vs 70+)
gen over70 = agegroup>=5
stcox age1 age2 age3 i.over70##i.ethnicity , strata(stp) 
estimates save ./analysis/output/models/_kbhadhoc_ETHBYAGE_byo70, replace

lincom 2.ethnicity, eform
postres o70 0 2
lincom 3.ethnicity, eform 
postres o70 0 3
lincom 4.ethnicity, eform
postres o70 0 4
lincom 5.ethnicity, eform
postres o70 0 5

lincom 2.ethnicity + 1.over70#2.ethnicity , eform
postres o70 1 2
lincom 3.ethnicity + 1.over70#3.ethnicity , eform
postres o70 1 3
lincom 4.ethnicity + 1.over70#4.ethnicity , eform
postres o70 1 4
lincom 5.ethnicity + 1.over70#5.ethnicity , eform
postres o70 1 5

test 1.over70#2.ethnicity 1.over70#3.ethnicity 1.over70#4.ethnicity 1.over70#5.ethnicity


*Agegroup interaction (all age groups)
stcox age1 age2 age3 i.ethnicity i.agegroup#i.ethnicity , strata(stp) 
estimates save ./analysis/output/models/_kbhadhoc_ETHBYAGE_byagegroup, replace

lincom 2.ethnicity, eform
postres ageg 1 2
lincom 3.ethnicity, eform 
postres ageg 1 3
lincom 4.ethnicity, eform
postres ageg 1 4
lincom 5.ethnicity, eform
postres ageg 1 5

forvalues i = 2/6{
	lincom 2.ethnicity + `i'.agegroup#2.ethnicity , eform
	postres ageg `i' 2
	lincom 3.ethnicity + `i'.agegroup#3.ethnicity , eform
	postres ageg `i' 3
	lincom 4.ethnicity + `i'.agegroup#4.ethnicity , eform
	postres ageg `i' 4
	lincom 5.ethnicity + `i'.agegroup#5.ethnicity , eform
	postres ageg `i' 5
}
test 2.agegroup#2.ethnicity 2.agegroup#3.ethnicity 2.agegroup#4.ethnicity 2.agegroup#5.ethnicity ///
3.agegroup#3.ethnicity 3.agegroup#3.ethnicity 3.agegroup#4.ethnicity 3.agegroup#5.ethnicity ///
4.agegroup#2.ethnicity 4.agegroup#3.ethnicity 4.agegroup#4.ethnicity 4.agegroup#5.ethnicity ///
5.agegroup#2.ethnicity 5.agegroup#3.ethnicity 5.agegroup#4.ethnicity 5.agegroup#5.ethnicity ///
6.agegroup#2.ethnicity 6.agegroup#3.ethnicity 6.agegroup#4.ethnicity 6.agegroup#5.ethnicity 

postclose results

log close

use "./analysis/output/_kbhadhoc_ETHBYAGE_estimates", clear
outsheet using "./analysis/output/_kbhadhoc_ETHBYAGE_estimates.csv", replace c