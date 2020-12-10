*an_impute
*KB 16/7/2020

cap log close
log using ./analysis/output/an_impute_2019, replace t

frames reset
use  ./analysis/cr_create_analysis_dataset_2019.dta, clear

stset stime_primarycaredeath, fail(primarycaredeath) id(patient_id) enter(enter_date) origin(enter_date)

mi set wide
mi register imputed ethnicity

mi impute mlogit ethnicity	///
			age1 age2 age3 			///
			i.male 							///
			i.obese4cat						///
			i.smoke_nomiss					///
			i.imd 							///
			i.htdiag_or_highbp				///
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
			_d, add(10) rseed(309484)

save ./analysis/an_impute_imputeddata_2019, replace

log close
