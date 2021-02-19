
if "`1'"=="MAIN" | "`1'"=="SEPT2020" {
local check "assert onsdeath>=1 & onsdeath<. if _d==1"
local genoutput1 "gen coviddeath = onsdeath==1" 
local genoutput2 "gen noncoviddeath = onsdeath>1 & onsdeath<." 
local taboutput1 "tab noncoviddeath"
local taboutput2 "tab coviddeath"
local outcomes "coviddeath noncoviddeath"
}

if "`1'"=="SEPT2020"{
local inputfile "./analysis/cr_create_analysis_dataset_sept2020_STSET_ONSCSDEATH.dta"
}

if "`1'"=="2019"{
local inputfile "./analysis/cr_create_analysis_dataset_2019.dta"	
local check "assert stime_primarycaredeath>d(1/2/2019) if primarycaredeath==1"
local outcomes "primarycaredeath"	
}


cap log close
log using ./analysis/output/an_covidvsnoncovid_full_`1', replace t

use  ./analysis/cr_create_analysis_dataset_`1'_STSET.dta, clear

`check'
	
`genoutput1'
`genoutput2'
	
foreach outcome of local outcomes{
	tab `outcome'
}
	
**MULTIVARIATE
cap prog drop baselogistic 
prog define baselogistic
	syntax , outcome(string) age(string) bp(string) [ethnicity(real 0) if(string)] 

	if `ethnicity'==1 local ethnicity "i.ethnicity"
	else local ethnicity

cap logistic `outcome' `age' 			///
			i.male 							///
			i.obese4cat						///
			i.smoke_nomiss					///
			`ethnicity'						///
			i.imd 							///
			`bp'							///
			i.chronic_respiratory_disease 	///
			i.asthmacat						///
			i.chronic_cardiac_disease 		///
			i.diabcat						///
			i.cancer_exhaem_cat	 			///
			i.cancer_haem_cat  				///
			i.chronic_liver_disease 		///
			i.stroke						///	
			i.dementia		 				///
			i.other_neuro					///
			i.reduced_kidney_function_cat2	///
			i.organ_transplant 				///
			i.spleen 						///
			i.ra_sle_psoriasis  			///
			i.other_immunosuppression		///
			i.stp
			
end			

foreach outcome of local outcomes{
	baselogistic, outcome(`outcome') age("age1 age2 age3")  bp("i.htdiag_or_highbp") ethnicity(0)
	if _rc==0{
	estimates
	estimates save ./analysis/output/models/an_covidvsnoncovid_full_`1'_`outcome'_agespline_bmicat_noeth, replace
	}
	else di "WARNING AGE SPLINE MODEL DID NOT FIT (OUTCOME `outcome')"
	 
	*Age group model (not adj ethnicity)
	baselogistic, outcome(`outcome') age("ib3.agegroup") bp("i.htdiag_or_highbp") ethnicity(0)
	if _rc==0{
	estimates
	estimates save ./analysis/output/models/an_covidvsnoncovid_full_`1'_`outcome'_agegroup_bmicat_noeth, replace
	}
	else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"

	*Complete case ethnicity model
	baselogistic, outcome(`outcome') age("age1 age2 age3") bp("i.htdiag_or_highbp") ethnicity(1)
	if _rc==0{
	estimates
	estimates save ./analysis/output/models/an_covidvsnoncovid_full_`1'_`outcome'_agespline_bmicat_CCeth, replace
	 }
	 else di "WARNING CC ETHNICITY MODEL WITH AGESPLINE DID NOT FIT (OUTCOME `outcome')"
} 
