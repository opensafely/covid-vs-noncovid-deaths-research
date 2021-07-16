
*KB 10/12/2020
*first argument dataset (MAIN SEPT2020 2019)
*second argument outcome (coviddeath noncoviddeath primarycaredeath deathsonlyCvN)
*third argument modeltorun (agesex full)
*fourth argument agetype (agespl agegrp)
*(fifth argument for specific sens analyses - SA_anywhereonDC or SA_u071only)

local dataset `1'
local outcome `2'
local modeltorun `3'

local agetype agespl
	local age "age1 age2 age3"
local sensan 


log using ./analysis/output/an_imputed_GENERAL_ETHxDEPR_`dataset'`sensan'_`outcome'_`modeltorun'_`agetype', replace t

use ./analysis/an_impute_imputeddata_`dataset', replace

tab `outcome'
mi passive: gen ethnicity_depr = 10*ethnicity+imd
tab ethnicity_depr `outcome'

if "`modeltorun'"=="agesex"{
*Age-sex model
mi estimate, eform post: logistic `outcome' age1 age2 age3 i.male i.stp i.ethnicity##i.imd 
estimates save ./analysis/output/models/an_imputed_ETHxDEPR_agesex_`dataset'`sensan'_`outcome', replace

*Test of interaction
testparm i.ethnicity#i.imd

*Deprivation effect in White
forvalues i=2/5{
	cap lincom `i'.imd
	if _rc==0 lincom `i'.imd
}

*Deprivation effect in other groups
forvalues e=2/5{
forvalues i=2/5{
	cap lincom `i'.imd + `e'.ethnicity#`i'.imd
	if _rc==0 lincom `i'.imd + `e'.ethnicity#`i'.imd
	}
}



}

if "`modeltorun'"=="full"{
*Full model
mi estimate, eform post: logistic `outcome' ///
			`age'		 					///
			i.male 							///
			i.obese4cat						///
			i.smoke_nomiss					///
	i.ethnicity##i.imd 						///
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
			i.stp
estimates save ./analysis/output/models/an_imputed_ETHxDEPR_full_`dataset'`sensan'_`outcome'_`agetype', replace

*Test of interaction
testparm i.ethnicity#i.imd

*Deprivation effect in White
forvalues i=2/5{
	cap lincom `i'.imd
	if _rc==0 lincom `i'.imd
}

*Deprivation effect in other groups
forvalues e=2/5{
forvalues i=2/5{
	cap lincom `i'.imd + `e'.ethnicity#`i'.imd
	if _rc==0 lincom `i'.imd + `e'.ethnicity#`i'.imd
	}
}


}

log close
