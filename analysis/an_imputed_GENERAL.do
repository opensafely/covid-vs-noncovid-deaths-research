
*KB 10/12/2020
*first argument dataset (MAIN SEPT2020 2019)
*second argument outcome (coviddeath noncoviddeath primarycaredeath deathsonlyCvN)
*third argument modeltorun (agesex full)
*fourth argument agetype (agespl agegrp)
*(fifth argument for specific sens analyses - SA_anywhereonDC or SA_u071only)

local dataset `1'
local outcome `2'
local modeltorun `3'
local agetype `4'
if "`agetype'"=="agespl" local age "age1 age2 age3"
if "`agetype'"=="agegrp" local age "ib3.agegroup"
local sensan `5'

log using ./analysis/output/an_imputed_GENERAL_`dataset'`sensan'_`outcome'_`modeltorun'_`agetype', replace t

use ./analysis/an_impute_imputeddata_`dataset', replace

if "`5'"=="SA_anywhereonDC"{
	replace coviddeath = 1 if onsdeath>=1 & onsdeath<. & died_ons_covid_flag_any==1
	replace noncoviddeath = 0 if died_ons_covid_flag_any==1
}

if "`5'"=="SA_u071only"{
	replace coviddeath = 0 if died_ons_covidconf_flag_und!=1
	replace noncoviddeath = 1 if onsdeath>=1 & onsdeath<. & died_ons_covidconf_flag_und!=1
}

if "`5'"=="SA_censorendAug"{
	replace coviddeath = 0 if coviddeath==1 & stime_onsdeath>d(1/9/2020)
	replace noncoviddeath = 0 if noncoviddeath==1 & stime_onsdeath>d(1/9/2020)
}

if "`outcome'"=="deathsonlyCvN"{
	drop if !(onsdeath>=1&onsdeath<.)
	gen deathsonlyCvN = (coviddeath==1)
}

tab `outcome'

if "`modeltorun'"=="agesex_cox"{
	gen onsdeath_cnc = onsdeath
	recode onsdeath_cnc 2/6=2
	if "`outcome'"=="coviddeath" local outcomenum = 1
	else if "`outcome'"=="noncoviddeath" local outcomenum = 2
	mi stset stime_onsdeath, fail(onsdeath_cnc==`outcomenum') id(patient_id) enter(enter_date) origin(enter_date)
	mi estimate, eform post: stcox age1 age2 age3 male i.ethnicity, strata(stp)
	estimates save ./analysis/output/models/an_imputed_agesex_`dataset'SA_Cox_`outcome', replace
	drop if !(onsdeath>=1&onsdeath<.)
	gen deathsonlyCvN = (coviddeath==1)
}
		
if "`modeltorun'"=="agesex"{
*Age-sex model
mi estimate, eform post: logistic `outcome' age1 age2 age3 i.male i.stp i.ethnicity 
estimates save ./analysis/output/models/an_imputed_agesex_`dataset'`sensan'_`outcome', replace
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
			i.other_immunosuppression		///
			i.stp
estimates save ./analysis/output/models/an_imputed_full_`dataset'`sensan'_`outcome'_`agetype', replace
}

log close
