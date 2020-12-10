
*KB 10/12/2020
*first argument dataset (MAIN SEPT2020 2019)
*second argument outcome (coviddeath noncoviddeath primarycaredeath)
*third argument modeltorun (agesex full)
*fourth argument agetype (agespl agegrp)


local dataset `1'
local outcome `2'
local modeltorun `3'
local agetype `4'
if "`agetype'"=="agespl" local age "age1 age2 age3"
if "`agetype'"=="agegrp" local age "i.agegroup"

log using ./analysis/an_imputed_GENERAL_`dataset'_`outcome'_`modeltorun'_`agetype', replace t

use ./analysis/an_impute_imputeddata_`dataset', replace

tab coviddeath
		
if "`modeltorun'"=="agesex"{
*Age-sex model
mi estimate, eform post: logistic `outcome' age1 age2 age3 i.male i.ethnicity
estimates save ./analysis/output/models/an_imputed_agesex_`dataset'_`outcome', replace
}

if "`modeltorun'"=="full"{
*Full model
mi estimate, eform post: logistic `outcome' ///
			`age'		 					///
			i.male 							///
			i.obese4cat						///
			i.smoke_nomiss					///
			i.ethnicity						///
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
			i.other_immunosuppression
estimates save ./analysis/output/models/an_imputed_full_`agetype'_`dataset'_`outcome', replace
}

log close
