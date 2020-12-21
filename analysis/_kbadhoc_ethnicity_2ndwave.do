
***
*DEATHS WITH COVID IN ANY POSITION (AS PER NATURE PPR)
cap log close
log using analysis/output/_kbadhoc_ethnicity_2ndwave, replace t

use  ./analysis/cr_create_analysis_dataset_SEPT2020_STSET.dta, clear

gen coviddeath = died_ons_covid_flag_any==1 & died_date_ons<=d(9/11/2020)

tab coviddeath

stset stime_onsdeath, fail(coviddeath) id(patient_id) enter(enter_date) origin(enter_date)

strate ethnicity, per(365.25) output(./analysis/_kbadhoc_ethnicity_2ndwaveSTRATES, replace)

safetab ethnicity if coviddeath==1

summ died_date_ons if coviddeath==1, f d

stcox age1 age2 age3 i.male i.ethnicity , strata(stp) 

stcox age1 age2 age3 i.male i.ethnicity_16 , strata(stp) 

stcox age1 age2 age3 i.male i.ethnicity i.imd, strata(stp) 

tab agegroup ethnicity, col
tab male ethnicity, col
tab imd ethnicity, col

table ethnicity , c(median age p25 age p75 age)


***SENS AN - DEATHS IN U/L POSITION ONLY



use  ./analysis/cr_create_analysis_dataset_SEPT2020_STSET.dta, clear

stset stime_onsdeath, fail(onsdeath=1) id(patient_id) enter(enter_date) origin(enter_date)

summ died_date_ons if onsdeath==1, f d

stcox age1 age2 age3 i.male i.ethnicity , strata(stp) 
stcox age1 age2 age3 i.male i.ethnicity i.imd, strata(stp) 

stcox age1 age2 age3 i.male i.ethnicity i.imd, strata(stp) 

*FULLY ADJUSTED
stcox age1 age2 age3 					///
			i.male 							///
			i.obese4cat						///
			i.smoke_nomiss					///
			i.ethnicity						///
			i.imd 							///
			i.htdiag_or_highbp						///
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
			i.other_immunosuppression			///
			, strata(stp)


log close
