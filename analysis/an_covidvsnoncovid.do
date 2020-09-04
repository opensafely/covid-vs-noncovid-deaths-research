*an_covidvsnoncovid
*KB 27/7/20

cap log close
log using ./output/an_covidvsnoncovid, replace t

use cr_create_analysis_dataset, clear

stset stime_onsdeath, fail(onsdeath) id(patient_id) enter(enter_date) origin(enter_date)

keep if _d==1

safetab onsdeath
safetab agegroup onsdeath, col
safetab male onsdeath, col

gen coviddeath = onsdeath==1

**UNIVARIATE
foreach var of any 							///
		agegroupsex							///
		agesplsex							///
		asthmacat							///
		cancer_exhaem_cat					///
		cancer_haem_cat						///
		chronic_cardiac_disease 			///
		reduced_kidney_function_cat			///
		dialysis							///
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
		smoke  								///
		smoke_nomiss 						///
		spleen 								///
		stroke_dementia {
	*Special cases
	if "`var'"=="agesplsex" local model "age1 age2 age3 i.male"
	else if "`var'"=="agegroupsex" local model "ib3.agegroup i.male"
	else if "`var'"=="bmicat" local model "age1 age2 age3 i.male ib2.bmicat"
	*General form of model
	else local model "age1 age2 age3 i.male i.`var'"

	*Fit and save model
	cap erase ./output/models/an_covidvsnoncovid_AGESEX_`var'.ster
	capture logistic coviddeath `model'
	if _rc==0 {
		estimates
		estimates save ./output/models/an_covidvsnoncovid_AGESEX_`var', replace
		}
	else di "WARNING - `var' vs `outcome' MODEL DID NOT SUCCESSFULLY FIT"

}


**MULTIVARIATE
cap prog drop baselogistic 
prog define baselogistic
	syntax , age(string) bp(string) [ethnicity(real 0) if(string)] 

	if `ethnicity'==1 local ethnicity "i.ethnicity"
	else local ethnicity

cap logistic coviddeath `age' 			///
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

baselogistic, age("age1 age2 age3")  bp("i.htdiag_or_highbp") ethnicity(0)
if _rc==0{
estimates
estimates save ./output/models/an_covidvsnoncovid_MAINFULLYADJMODEL_agespline_bmicat_noeth, replace
*estat concordance /*c-statistic*/
}
else di "WARNING AGE SPLINE MODEL DID NOT FIT (OUTCOME `outcome')"
 
*Age group model (not adj ethnicity)
baselogistic, age("ib3.agegroup") bp("i.htdiag_or_highbp") ethnicity(0)
if _rc==0{
estimates
estimates save ./output/models/an_covidvsnoncovid_MAINFULLYADJMODEL_agegroup_bmicat_noeth, replace
*estat concordance /*c-statistic*/
}
else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"

*Complete case ethnicity model
baselogistic, age("age1 age2 age3") bp("i.htdiag_or_highbp") ethnicity(1)
if _rc==0{
estimates
estimates save ./output/models/an_covidvsnoncovid_MAINFULLYADJMODEL_agespline_bmicat_CCeth, replace
*estat concordance /*c-statistic*/
 }
 else di "WARNING CC ETHNICITY MODEL WITH AGESPLINE DID NOT FIT (OUTCOME `outcome')"

 log close