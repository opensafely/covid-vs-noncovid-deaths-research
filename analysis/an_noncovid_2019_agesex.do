cap log close
log using ./analysis/output/an_noncovid_2019_agesex, replace t


use ./analysis/cr_create_analysis_dataset, clear
stset stime_primarycaredeath, fail(primarycaredeath) id(patient_id) enter(enter_date) origin(enter_date)

cap prog drop baselogistic 
prog define baselogistic
	syntax , age(string) addvariable(string)

	cap logistic _d `age' 			///
				i.male 				///
				i.`addvariable'			
end			

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
			baselogistic, age("age1 age2 age3")  addvariable("i.`addvariable'") 
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_noncovid_2019_agesex_`addvariable'
			}
		else di "MODEL DID NOT FIT (adding `addvariable')"
 }

 cap logistic _d age1 age2 age3 i.male
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_noncovid_2019_agesex_SEX
		}
 cap logistic _d i.agegroup i.male
			if _rc==0{
			estimates
			estimates save ./analysis/output/models/an_noncovid_2019_agesex_AGEGROUP
		}
	 
