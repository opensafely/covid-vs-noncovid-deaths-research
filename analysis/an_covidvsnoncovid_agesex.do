cap log close
log using ./output/an_covidvsnoncovid_agesex, replace t

	cap prog drop baselogistic 
	prog define baselogistic
		syntax , age(string) addvariable(string)

	cap logistic _d `age' 			///
				i.male 				///
				i.`addvariable'			
	end			
	
	
	use  ./analysis/cr_create_analysis_dataset_STSET_ONSCSDEATH.dta, clear
	
	gen coviddeath = onsdeath==1 if  _d==1
	replace coviddeath= 0 if _d==0
	gen noncoviddeath = onsdeath>1 if _d==1
	replace noncoviddeath= 0 if _d==0
	
	foreach run of any covid noncovid {
	
	foreach addvariable of any asthmacat	///
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
		 bpcat 								///
		 hypertension						///
		imd 								///
		obese4cat							///
		 bmicat 							///
		organ_transplant 					///
		other_immunosuppression				///
		other_neuro 						///
		ra_sle_psoriasis 					///  
		smoke  								///
		smoke_nomiss 						///
		spleen 								///
		stroke_dementia {
			cap logistic `run'death age1 age2 age3 male i.`addvariable'
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_covidvsnoncovid_agesex_`run'_`addvariable', replace
			}
		else di "MODEL DID NOT FIT (adding `addvariable')"
	 }

	 cap logistic `run'death age1 age2 age3 i.male
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_covidvsnoncovid_agesex_`run'_MALE, replace
			}
	 cap logistic `run'death i.agegroup i.male
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_covidvsnoncovid_agesex_`run'_AGEGROUP, replace
			}
	 
}
