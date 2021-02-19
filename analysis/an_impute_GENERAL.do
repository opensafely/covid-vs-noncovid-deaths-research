*an_impute
*KB 16/7/2020

set seed `2'

if "`1'"=="MAIN" | "`1'"=="SEPT2020" {
local check "assert onsdeath>=1 & onsdeath<. if _d==1"
local genoutput1 "gen coviddeath = onsdeath==1" 
local genoutput2 "gen noncoviddeath = onsdeath>1 & onsdeath<." 
local taboutput1 "tab noncoviddeath"
local taboutput2 "tab coviddeath"
local outcomes "coviddeath noncoviddeath"
}

if "`1'"=="2019"{
local check "assert stime_primarycaredeath>d(1/2/2019) if primarycaredeath==1"
local outcomes "primarycaredeath"	
}

cap log close
log using ./analysis/output/an_impute_`1', replace t

frames reset
use  ./analysis/cr_create_analysis_dataset_`1'_STSET, clear
`check'
	
`genoutput1'
`genoutput2'
foreach outcome of local outcomes{
	tab `outcome'
}

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
			`outcomes', add(10) rseed(309484) noisily

save ./analysis/an_impute_imputeddata_`1', replace

log close
