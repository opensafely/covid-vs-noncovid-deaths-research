*an_impute
*KB 16/7/2020

cap log close
log using ./analysis/output/an_impute_MAIN, replace t

frames reset
use  ./analysis/cr_create_analysis_dataset_STSET_ONSCSDEATH.dta, clear

assert onsdeath>=1 & onsdeath<. if _d==1
		
gen coviddeath = onsdeath==1 
gen noncoviddeath = onsdeath>1 & onsdeath<. 
	
tab coviddeath
tab noncoviddeath
	
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
			coviddeath noncoviddeath, add(10) rseed(309484) noisily

save ./analysis/an_impute_imputeddata_MAIN, replace

log close
