cap log close
log using ./output/an_noncovid_full, replace t

	cap prog drop baselogistic 
	prog define baselogistic
	syntax , age(string) bp(string) [ethnicity(real 0) if(string)] 

	if `ethnicity'==1 local ethnicity "i.ethnicity"
	else local ethnicity
	
		cap logistic _d `age' 			///
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

foreach year of numlist 2019 2020{
	if `year'==2019 use cr_create_analysis_dataset_2019, clear
	else if `year'==2020 use cr_create_analysis_dataset, clear
	
	stset stime_primarycaredeath, fail(primarycaredeath) id(patient_id) enter(enter_date) origin(enter_date)
	
	baselogistic, age("age1 age2 age3")  bp("i.htdiag_or_highbp") ethnicity(0)
	if _rc==0{
	estimates
	estimates save ./output/models/an_noncovid_full_`year'_agespline_bmicat_noeth, replace
	}
	else di "WARNING AGE SPLINE MODEL DID NOT FIT (OUTCOME `outcome')"
	 
	*Age group model (not adj ethnicity)
	baselogistic, age("ib3.agegroup") bp("i.htdiag_or_highbp") ethnicity(0)
	if _rc==0{
	estimates
	estimates save ./output/models/an_noncovid_full_`year'_agegroup_bmicat_noeth, replace
	}
	else di "WARNING GROUP MODEL DID NOT FIT (OUTCOME `outcome')"

	*Complete case ethnicity model
	baselogistic, age("age1 age2 age3") bp("i.htdiag_or_highbp") ethnicity(1)
	if _rc==0{
	estimates
	estimates save ./output/models/an_noncovid_full_`year'_agespline_bmicat_CCeth, replace
	 }
	 else di "WARNING CC ETHNICITY MODEL WITH AGESPLINE DID NOT FIT (OUTCOME `outcome')"
	 

	 
}