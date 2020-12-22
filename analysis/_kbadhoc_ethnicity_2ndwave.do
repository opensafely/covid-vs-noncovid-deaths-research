
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

*Sex interaction
stcox age1 age2 age3 i.male##i.ethnicity , strata(stp) 
estimates save ./analysis/output/models/_kbadhoc_ethnicity_2ndwave_SEXINT, replace

lincom 2.ethnicity + 1.male#2.ethnicity , eform
lincom 3.ethnicity + 1.male#3.ethnicity , eform
lincom 4.ethnicity + 1.male#4.ethnicity , eform
lincom 5.ethnicity + 1.male#5.ethnicity , eform

test 1.male#2.ethnicity 1.male#3.ethnicity 1.male#4.ethnicity 1.male#5.ethnicity


gen ethnicity_16reduced = ethnicity_16

recode ethnicity_16reduced 2/3=2 4/7=4 13/14=13 15/16=15

label define ethnicity_16reducedlab 1 "White British" 2 "Other white" 4 "Mixed" 8 "Indian" 9 "Pakistani" 10 "Bangladeshi" 11 "Other Asian" 12 "Black Carribbean"  13 "Other Black" 15 "Other"
label values ethnicity_16reduced ethnicity_16reducedlab

stcox age1 age2 age3 i.male##i.ethnicity_16reduced , strata(stp) 
estimates save ./analysis/output/models/_kbadhoc_ethnicity_2ndwave_ETH16r_SEXINT, replace

lincom 2.ethnicity + 1.male#2.ethnicity , eform
lincom 4.ethnicity + 1.male#4.ethnicity , eform
lincom 8.ethnicity + 1.male#8.ethnicity , eform
lincom 9.ethnicity + 1.male#9.ethnicity , eform
lincom 10.ethnicity + 1.male#10.ethnicity , eform
lincom 11.ethnicity + 1.male#11.ethnicity , eform
lincom 12.ethnicity + 1.male#12.ethnicity , eform
lincom 13.ethnicity + 1.male#13.ethnicity , eform
lincom 15.ethnicity + 1.male#15.ethnicity , eform

test 1.male#2.ethnicity 1.male#4.ethnicity 1.male#8.ethnicity 1.male#9.ethnicity 1.male#10.ethnicity 1.male#11.ethnicity 1.male#12.ethnicity 1.male#13.ethnicity 1.male#15.ethnicity


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
