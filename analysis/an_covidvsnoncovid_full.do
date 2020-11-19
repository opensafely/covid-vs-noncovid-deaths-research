cap log close
log using ./analysis/output/an_covidvsnoncovid_full, replace t

use  ./analysis/cr_create_analysis_dataset_STSET_ONSCSDEATH.dta, clear
	
gen coviddeath = onsdeath==1 if  _d==1
replace coviddeath= 0 if _d==0
gen noncoviddeath = onsdeath>1 if _d==1
replace noncoviddeath= 0 if _d==0
	
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
			i.stroke_dementia		 		///
			i.other_neuro					///
			i.reduced_kidney_function_cat	///
			i.organ_transplant 				///
			i.spleen 						///
			i.ra_sle_psoriasis  			///
			i.other_immunosuppression
			
end			

baselogistic, outcome(coviddeath) age("age1 age2 age3")  bp("i.htdiag_or_highbp") ethnicity(0)
if _rc==0{
estimates
estimates save ./analysis/output/models/an_covidvsnoncovid_full_covid_agespline_bmicat_noeth, replace
}
else di "WARNING AGE SPLINE MODEL DID NOT FIT (OUTCOME `outcome')"
 
*Age group model (not adj ethnicity)
baselogistic, outcome(coviddeath) age("ib3.agegroup") bp("i.htdiag_or_highbp") ethnicity(0)
if _rc==0{
estimates
estimates save ./analysis/output/models/an_covidvsnoncovid_full_covid_agegroup_bmicat_noeth, replace
}
else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"

*Complete case ethnicity model
baselogistic, outcome(coviddeath) age("age1 age2 age3") bp("i.htdiag_or_highbp") ethnicity(1)
if _rc==0{
estimates
estimates save ./analysis/output/models/an_covidvsnoncovid_full_covid_agespline_bmicat_CCeth, replace
 }
 else di "WARNING CC ETHNICITY MODEL WITH AGESPLINE DID NOT FIT (OUTCOME `outcome')"
 
 ***

baselogistic, outcome(noncoviddeath) age("age1 age2 age3")  bp("i.htdiag_or_highbp") ethnicity(0)
if _rc==0{
estimates
estimates save ./analysis/output/models/an_covidvsnoncovid_full_noncovid_agespline_bmicat_noeth, replace
}
else di "WARNING AGE SPLINE MODEL DID NOT FIT (OUTCOME `outcome')"
 
*Age group model (not adj ethnicity)
baselogistic, outcome(noncoviddeath) age("ib3.agegroup") bp("i.htdiag_or_highbp") ethnicity(0)
if _rc==0{
estimates
estimates save ./analysis/output/models/an_covidvsnoncovid_full_noncovid_agegroup_bmicat_noeth, replace
}
else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"

*Complete case ethnicity model
baselogistic, outcome(noncoviddeath) age("age1 age2 age3") bp("i.htdiag_or_highbp") ethnicity(1)
if _rc==0{
estimates
estimates save ./analysis/output/models/an_covidvsnoncovid_full_noncovid_agespline_bmicat_CCeth, replace
 }
 else di "WARNING CC ETHNICITY MODEL WITH AGESPLINE DID NOT FIT (OUTCOME `outcome')"
 
 *** 
 
 log close