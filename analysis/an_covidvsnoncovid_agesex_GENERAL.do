

if "`1'"=="MAIN" | "`1'"=="SEPT2020" {
local check "assert onsdeath>=1 & onsdeath<. if _d==1"
local genoutput1 "gen coviddeath = onsdeath==1" 
local genoutput2 "gen noncoviddeath = onsdeath>1 & onsdeath<." 
local taboutput1 "tab noncoviddeath"
local taboutput2 "tab coviddeath"
local outcomes "coviddeath noncoviddeath"
}

if "`1'"=="2019"{
local check "assert stime_primarycaredeath>d(1/2/2019) if primarycaredeath==1"
local outcomes "primarycaredeath"	
}

cap log close
log using ./analysis/output/an_covidvsnoncovid_agesex_`1'`2', replace t

use  ./analysis/cr_create_analysis_dataset_`1'_STSET.dta, clear
	
`check'
	
`genoutput1'
`genoutput2'

if "`2'"=="SA_anywhereonDC"{
	replace coviddeath = 1 if onsdeath>=1 & onsdeath<. & died_ons_covid_flag_any==1
	replace noncoviddeath = 0 if died_ons_covid_flag_any==1
}

if "`2'"=="SA_u071only"{
	replace coviddeath = 0 if died_ons_covidconf_flag_und!=1
	replace noncoviddeath = 1 if onsdeath>=1 & onsdeath<. & died_ons_covidconf_flag_und!=1
}

gen obese4catCC = obese4cat
replace obese4catCC = . if bmicat==.
	
foreach outcome of local outcomes{
	tab `outcome'
}
	
	foreach outcome of local outcomes {
	
	foreach addvariable of any asthmacat	///
		cancer_exhaem_cat					///
		cancer_haem_cat						///
		chronic_cardiac_disease 			///
		reduced_kidney_function_cat2		///
		dialysis							///
		chronic_liver_disease 				///
		chronic_respiratory_disease 		///
		diabcat								///
		ethnicity 							///
		htdiag_or_highbp					///
		 bpcat 								///
		 hypertension						///
		imd 								///
		obese4cat							///
		 obese4catCC						///
		organ_transplant 					///
		other_immunosuppression				///
		other_neuro 						///
		ra_sle_psoriasis 					///  
		smoke  								///
		smoke_nomiss 						///
		spleen 								///
		stroke 								///
		dementia {
			cap logistic `outcome' age1 age2 age3 male i.stp i.`addvariable'
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_covidvsnoncovid_agesex_`1'`2'_`outcome'_`addvariable', replace
			}
		else di "MODEL DID NOT FIT (adding `addvariable')"
	 }

	 cap logistic `outcome' age1 age2 age3 i.male i.stp
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_covidvsnoncovid_agesex_`1'`2'_`outcome'_MALE, replace
			}
	 cap logistic `outcome' ib3.agegroup i.male i.stp
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_covidvsnoncovid_agesex_`1'`2'_`outcome'_AGEGROUP, replace
			}
	 
}

log close
