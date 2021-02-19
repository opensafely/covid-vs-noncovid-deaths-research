*KB 19/02/21

cap log close
log using ./analysis/output/an_cox_covnoncov_agesex, replace t

use  ./analysis/cr_create_analysis_dataset_MAIN_STSET.dta, clear

gen onsdeath_cnc = onsdeath
recode onsdeath_cnc 2/6=2

forvalues outcome = 1/2{
    
if `outcome'==1 local outcomename "cov"
else if `outcome'==2 local outcomename "noncov"

stset stime_onsdeath, fail(onsdeath_cnc==`outcome') id(patient_id) enter(enter_date) origin(enter_date)

	foreach addvariable of any asthmacat	///
		cancer_exhaem_cat					///
		cancer_haem_cat						///
		chronic_cardiac_disease 			///
		reduced_kidney_function_cat2		///
		chronic_liver_disease 				///
		chronic_respiratory_disease 		///
		diabcat								///
		ethnicity 							///
		htdiag_or_highbp					///
		imd 								///
		obese4cat							///
		organ_transplant 					///
		other_immunosuppression				///
		other_neuro 						///
		ra_sle_psoriasis 					///  
		smoke_nomiss 						///
		spleen 								///
		stroke 								///
		dementia {
			cap stcox age1 age2 age3 male i.`addvariable', strata(stp)
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_cox_covnoncov_agesex_`outcomename'_`addvariable', replace
			}
		else di "MODEL DID NOT FIT (adding `addvariable')"
	 }

	 cap stcox age1 age2 age3 i.male, strata(stp)
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_cox_covnoncov_agesex_`outcomename'__MALE, replace
			}
	 cap stcox ib3.agegroup i.male, strata(stp)
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_cox_covnoncov_agesex_`outcomename'__AGEGROUP, replace
			}
	 
}

log close
