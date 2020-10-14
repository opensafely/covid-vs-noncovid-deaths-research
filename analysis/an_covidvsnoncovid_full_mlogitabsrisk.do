cap log close
log using ./output/an_covidvsnoncovid_full_mlogitabsrisk, replace t

use cr_create_analysis_dataset, clear

stset stime_onsdeath, fail(onsdeath) id(patient_id) enter(enter_date) origin(enter_date)

gen mloutcome = onsdeath if _d==1
replace mloutcome = 0 if _d==0

local agegroup = 6

*FIT MAIN MODEL
mlogit mloutcome ///
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
			i.stroke_dementia		 		///
			i.other_neuro					///
			i.reduced_kidney_function_cat	///
			i.organ_transplant 				///
			i.spleen 						///
			i.ra_sle_psoriasis  			///
			i.other_immunosuppression if agegroup==`agegroup', rrr
 
cap prog drop getmargin
prog define getmargin
local marginsat "male=0 obese4cat=1 smoke_nomiss=1 ethnicity=1 imd=1 htdiag_or_highbp=0 			chronic_respiratory_disease=0 asthmacat=1 chronic_cardiac_disease=1 diabcat=1 cancer_exhaem_cat=1 			cancer_haem_cat=1 chronic_liver_disease=0 stroke_dementia=0	other_neuro=1 reduced_kidney_function_cat=1	organ_transplant=0 spleen=0	ra_sle_psoriasis=0 other_immunosuppression=0"
if "`1'"!="" {
	local eqposm1 = strpos("`1'","=")-1
	local var = substr("`1'",1,`eqposm1')
	local marginsat = subinstr("`marginsat'", "`var'=1", "`1'", 1)
	local marginsat = subinstr("`marginsat'", "`var'=0", "`1'", 1)
	}
di "`marginsat'"
cap margins , at(`marginsat')
end

cap frame drop absolutes
frame create absolutes str30 variable level pcovdeath lcicov ucicov pnoncovdeath lcinoncov ucinoncov

frame post absolutes ("") (99) (el(r(table), 1, 2)) (el(r(table), 5, 2)) (el(r(table), 6, 2)) (el(r(table), 1, 3)) (el(r(table), 5, 3)) (el(r(table), 6, 3)) 
foreach vartoprocess of any male obese4cat smoke_nomiss ethnicity imd htdiag_or_highbp chronic_respiratory_disease asthmacat chronic_cardiac_disease diabcat cancer_exhaem_cat cancer_haem_cat chronic_liver_disease stroke_dementia other_neuro reduced_kidney_function_cat organ_transplant spleen ra_sle_psoriasis other_immunosuppression{
summ `vartoprocess'
local mintoget = r(min)+1
local maxtoget = r(max)
forvalues i = `mintoget'/`maxtoget'{
	getmargin `vartoprocess'=`i'
	if _rc==0 frame post absolutes ("`vartoprocess'") (`i') (el(r(table), 1, 2)) (el(r(table), 5, 2)) (el(r(table), 6, 2)) (el(r(table), 1, 3)) (el(r(table), 5, 3)) (el(r(table), 6, 3))
}
}

frame change absolutes
save ./output/an_covidvsnoncovid_full_mlogitabsrisk_ESTIMATES, replace

 
log close