


*Coding: Krishnan Bhaskaran
*
*Date drafted: 18/12/2020
*************************************************************************


***********************************************************************************************************************
*Generic code to ouput the HRs across outcomes for all levels of a particular variables, in the right shape for table
cap prog drop outputHRsforvar
prog define outputHRsforvar
syntax, variable(string) min(real) max(real) 
forvalues i=`min'/`max'{
local endwith "_tab"

	*put the varname and condition to left so that alignment can be checked vs shell
	file write tablecontents ("`variable'") _tab ("`i'") _tab
	
	foreach run of numlist 1/10 { /*AGESEX: ORIG_C ORIG_NC U71_C U71_NC UL_C UL_NC SEP_C SEP_NC CCA_C CC_NC*/
	
		/*reset to main obesity/smoking variables after runs 9/10*/
		if "`variable'"=="obese4catCC" local variable "obese4cat"
		if "`variable'"=="smoke" local variable "smoke_nomiss"	
			
	
		if mod(`run',2)==1 local outcome coviddeath 
			else local outcome noncoviddeath
		if `run'==1|`run'==2 local datasetSA MAIN
				else if `run'==3|`run'==4 local datasetSA MAINSA_u071only
				else if `run'==5|`run'==6 local datasetSA MAINSA_anywhereonDC
				else if `run'==7|`run'==8 local datasetSA SEPT2020
				else if `run'==9|`run'==10 local datasetSA MAIN
				
				if (`run'==9|`run'==10) & "`variable'"== "obese4cat" local variable obese4catCC
				if (`run'==9|`run'==10) & "`variable'"== "smoke_nomiss" local variable smoke

						
		local noestimatesflag 0 /*reset*/

		
*CHANGE THE OUTCOME BELOW TO LAST IF BRINGING IN MORE COLS
		if `run'==10 local endwith "_n"

		***********************
		*1) GET THE RIGHT ESTIMATES INTO MEMORY

		cap estimates use ./analysis/output/models/an_covidvsnoncovid_agesex_`datasetSA'_`outcome'_`variable'
			if _rc!=0 local noestimatesflag 1				
			if "`variable'"=="ethnicity" & !(`run'==9|`run'==10) {
				cap estimates use ./analysis/output/models/an_imputed_agesex_`datasetSA'_`outcome'
				if _rc!=0 local noestimatesflag 1						
				}
		
		***********************
		*2) WRITE THE HRs TO THE OUTPUT FILE
		
		if `noestimatesflag'==0{
			cap lincom `i'.`variable', eform
			if _rc==0 file write tablecontents %4.2f (r(estimate)) (" (") %4.2f (r(lb)) ("-") %4.2f (r(ub)) (")") `endwith'
				else file write tablecontents %4.2f ("ERR IN MODEL") `endwith'
			}
			else file write tablecontents %4.2f ("DID NOT FIT") `endwith' 
			
			
		*3) Save the estimates for plotting
		if `noestimatesflag'==0{
				local hr = r(estimate)
				local lb = r(lb)
				local ub = r(ub)
				cap gen `variable'=.
				cap testparm i.`variable'
				if _rc==0 post HRestimates (`run') ("`outcome'") ("`variable'") (`i') (`hr') (`lb') (`ub') (r(p))
				drop `variable'
				}	
			
		} /*run 1/10 */
		
} /*variable levels*/

end
***********************************************************************************************************************
*Generic code to write a full row of "ref category" to the output file
cap prog drop refline
prog define refline
file write tablecontents _tab _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _n
end
***********************************************************************************************************************

*MAIN CODE TO PRODUCE TABLE CONTENTS

cap file close tablecontents
file open tablecontents using ./analysis/output/an_processout_sensanresults.txt, t w replace 

tempfile HRestimates
cap postutil clear
postfile HRestimates run str20 outcome str28 variable level hr lci uci pval using `HRestimates'


*Age group
outputHRsforvar, variable("agegroup") min(1) max(2) 
refline
outputHRsforvar, variable("agegroup") min(4) max(6) 
file write tablecontents _n 

*Sex 
refline
outputHRsforvar, variable("male") min(1) max(1) 
file write tablecontents _n

*BMI
refline
outputHRsforvar, variable("obese4cat") min(2) max(4) 
file write tablecontents _n

*Smoking
refline
outputHRsforvar, variable("smoke_nomiss") min(2) max(3) 
file write tablecontents _n

*Ethnicity
refline
outputHRsforvar, variable("ethnicity") min(2) max(5) 
file write tablecontents _n

*IMD
refline
outputHRsforvar, variable("imd") min(2) max(5) 
file write tablecontents _n 

*BP/hypertension
refline
outputHRsforvar, variable("htdiag_or_highbp") min(1) max(1) 
file write tablecontents _n
outputHRsforvar, variable("chronic_respiratory_disease") min(1) max(1) 
file write tablecontents _n			
outputHRsforvar, variable("asthmacat") min(2) max(3) 			
outputHRsforvar, variable("chronic_cardiac_disease") min(1) max(1) 
file write tablecontents _n	
outputHRsforvar, variable("diabcat") min(2) max(4) 
file write tablecontents _n		
outputHRsforvar, variable("cancer_exhaem_cat") min(2) max(4) 
file write tablecontents _n		
outputHRsforvar, variable("cancer_haem_cat") min(2) max(4) 		
file write tablecontents _n
outputHRsforvar, variable("reduced_kidney_function_cat2") min(2) max(4) 		
outputHRsforvar, variable("chronic_liver_disease") min(1) max(1) 			
outputHRsforvar, variable("dementia") min(1) max(1) 	
outputHRsforvar, variable("stroke") min(1) max(1) 	
outputHRsforvar, variable("other_neuro") min(1) max(1) 		
outputHRsforvar, variable("organ_transplant") min(1) max(1)			
outputHRsforvar, variable("spleen") min(1) max(1) 
outputHRsforvar, variable("ra_sle_psoriasis") min(1) max(1) 
outputHRsforvar, variable("other_immunosuppression") min(1) max(1) 


file close tablecontents

postclose HRestimates
use `HRestimates', clear

replace variable="obese4cat" if variable=="obese4catCC"
replace variable="smoke_nomiss" if variable=="smoke"

drop if (run==9|run==10) &!(variable=="ethnicity"|variable=="obese4cat"|variable=="smoke_nomiss")

*LEAVE OUT THE SEPT2020 ANALYSIS FOR NOW
drop if run==7|run==8

*ORIG_C ORIG_NC U71_C U71_NC UL_C UL_NC SEP_C SEP_NC CCA_C CC_NC*/
gen analysis = "PRIMARY ANALYSIS" if run==1
replace analysis = "CONFIRMED COVID" if run==3
replace analysis = "ANY COVID ON DC" if run==5
replace analysis = "START SEPT 2020" if run==7
replace analysis = "COMPLETE CASE"  if run==9

sort variable run level 

expand 2 if variable!=variable[_n-1] | outcome!=outcome[_n-1], gen(expanded)
for var hr lci uci: replace X = 1 if expanded==1 
replace level = 0 if expanded == 1
replace level = 1 if expanded == 1 & (variable=="obese4cat"|variable=="smoke_nomiss"|variable=="ethnicity"|variable=="imd"|variable=="asthmacat"|variable=="diabcat"|substr(variable,1,6)=="cancer"|variable=="reduced_kidney_function_cat2"|variable=="agegroup")
replace level = 3 if expanded == 1 & variable=="agegroup"
rename expanded reference

sort variable run level 
expand 2 if outcome!=outcome[_n-1] 

sort variable run outcome level 
by variable run outcome: replace hr = . if _n==1
by variable run outcome: replace lci = . if _n==1
by variable run outcome: replace uci = . if _n==1
by variable run outcome: replace level = . if _n==1
by variable run outcome: replace analysis="" if _n!=1

expand 2 if analysis!="" 
replace level = -1 if level==.
sort variable run outcome level 
by variable run: replace analysis="" if _n==1

drop if level==0 & variable!="male"
drop if outcome=="noncoviddeath" & hr==. & hr[_n+1]

by variable : gen order = _N-_n

replace reference = 0 if hr==.

*Levels
gen leveldesc = ""
replace leveldesc = "18-39" if variable=="agegroup" & level==1
replace leveldesc = "40-49" if variable=="agegroup" & level==2
replace leveldesc = "50-59 (ref)" if variable=="agegroup" & level==3
replace leveldesc = "60-69" if variable=="agegroup" & level==4
replace leveldesc = "70-79" if variable=="agegroup" & level==5
replace leveldesc = "80+" if variable=="agegroup" & level==6

replace leveldesc = "Female (ref)" if variable=="male" & level==0
replace leveldesc = "Male" if variable=="male" & level==1

replace leveldesc = "Not obese (ref)" if variable=="obese4cat" & level==1
replace leveldesc = "Obese class I" if variable=="obese4cat" & level==2
replace leveldesc = "Obese class II" if variable=="obese4cat" & level==3
replace leveldesc = "Obese class III" if variable=="obese4cat" & level==4

replace leveldesc = "Never (ref)" if variable=="smoke_nomiss" & level==1
replace leveldesc = "Ex-smoker" if variable=="smoke_nomiss" & level==2
replace leveldesc = "Current" if variable=="smoke_nomiss" & level==3

replace leveldesc = "White (ref)" if variable=="ethnicity" & level==1
replace leveldesc = "Mixed" if variable=="ethnicity" & level==2
replace leveldesc = "South Asian" if variable=="ethnicity" & level==3
replace leveldesc = "Black" if variable=="ethnicity" & level==4
replace leveldesc = "Other" if variable=="ethnicity" & level==5

replace leveldesc = "1 (least deprived, ref)" if variable=="imd" & level==1
replace leveldesc = "2" if variable=="imd" & level==2
replace leveldesc = "3" if variable=="imd" & level==3
replace leveldesc = "4" if variable=="imd" & level==4
replace leveldesc = "5 (most deprived)" if variable=="imd" & level==5

replace leveldesc = "No diabetes (ref)" if variable=="diabcat" & level==1
replace leveldesc = "Controlled " if variable=="diabcat" & level==2
replace leveldesc = "Uncontrolled" if variable=="diabcat" & level==3
replace leveldesc = "Unknown HbA1c" if variable=="diabcat" & level==4

replace leveldesc = "No asthma (ref)" if variable=="asthmacat" & level==1
replace leveldesc = "With no recent OCS use" if variable=="asthmacat" & level==2
replace leveldesc = "With recent OCS use" if variable=="asthmacat" & level==3

replace leveldesc = "Never (ref)" if substr(variable,1,6)=="cancer" & level==1
replace leveldesc = "<1 year ago" if substr(variable,1,6)=="cancer" & level==2
replace leveldesc = "1-4.9 years ago" if substr(variable,1,6)=="cancer" & level==3
replace leveldesc = "5+ years ago" if substr(variable,1,6)=="cancer" & level==4

replace leveldesc = "None (ref)" if variable=="reduced_kidney_function_cat2" & level==1
replace leveldesc = "eGFR 30-60" if variable=="reduced_kidney_function_cat2" & level==2
replace leveldesc = "eGFR 15-<30 " if variable=="reduced_kidney_function_cat2" & level==3
replace leveldesc = "eGFR <15 or dialysis" if variable=="reduced_kidney_function_cat2" & level==4


*replace leveldesc = "Absent" if level==0
*replace leveldesc = "Present" if level==1 & leveldesc==""



cap drop xforanalysis levelx lowerlimit
gen xforanalysis = 10
gen levelx = 0.09
gen lowerlimit = 0.15
gen upperlimit = 13

gen displayhrcilo = "<<<" if lci<lowerlimit
gen displayhrcihi = ">>>" if uci>upperlimit
gen displayhrci = string(hr, "%3.2f") + " (" + string(lci, "%3.2f") + "-" + string(uci, "%3.2f") + ")" if hr!=.
replace displayhrci = "1.00 (REF)" if reference==1
replace displayhrci = ">>> " +  displayhrci if uci>upperlimit & uci<.

levelsof variable, local(vars)

foreach var of local vars{
	
local graphtitle = upper(substr((subinstr("`var'", "_", " ", 10)),1,1)) + substr((subinstr("`var'", "_", " ", 10)),2,.)
if "`graphtitle'"=="Agegroup" local graphtitle "Age group" 
if "`graphtitle'"=="Male" local graphtitle "Sex" 
if "`graphtitle'"=="Obese4cat" local graphtitle "Obesity" 
if "`graphtitle'"=="Smoke nomiss" local graphtitle "Smoking status" 
if "`graphtitle'"=="Imd" local graphtitle  "Deprivation (IMD) quintile" 
if "`graphtitle'"=="Htdiag or highbp" local graphtitle "Hypertension/high bp" 
if "`graphtitle'"=="Asthmacat" local graphtitle "Asthma" 
if "`graphtitle'"=="Diabcat" local graphtitle "Diabetes" 
if "`graphtitle'"=="Cancer exhaem cat" local graphtitle "Cancer (non-haematological)" 
if "`graphtitle'"=="Cancer haem cat" local graphtitle "Haematological malignancy"  
if "`graphtitle'"=="Stroke dementia" local graphtitle "Stroke or dementia" 
if "`graphtitle'"=="Other neuro" local graphtitle "Other neurological" 
if "`graphtitle'"=="Ra sle psoriasis" local graphtitle "Rheum arthritis/Lupus/Psoriasis" 
if "`graphtitle'"=="Reduced kidney function cat2" local graphtitle "Reduced kidney function" 
if "`graphtitle'"=="Spleen" local graphtitle "Asplenia" 

scatter order hr if outcome=="coviddeath" & lci>lowerlimit & uci<upperlimit, mc(black) msize(small) || rcap lci uci order if outcome=="coviddeath" & lci>lowerlimit & uci<upperlimit, hor lc(black) ///
|| scatter order hr if outcome=="noncoviddeath" & lci>lowerlimit & uci<upperlimit, mc(gs9) msize(small)  || rcap lci uci order if outcome=="noncoviddeath" & lci>lowerlimit & uci<upperlimit, hor  lc(gs9) ///
|| scatter order xforanalysis, m(i) mlab(analysis) mlabcol(black) mlabsize(tiny) ///
|| scatter order levelx, m(i) mlab(leveldesc) mlabsize(tiny) mlabcol(gs4) 	///
		xline(1,lp(dash)) 															///
|| scatter order lowerlimit, m(i) mlab(displayhrcilo) mlabcol(black) mlabsize(tiny) ///
|| scatter order xforanalysis, m(i) mlab(displayhrci) mlabcol(black) mlabsize(tiny) ///
|| if variable=="`var'", xtitle("HR and 95% CI") xscale(log range(45)) xlab(0.25 0.5 1 2 5 10 ) legend(order(1 3) label(1 "COVID-19 death") label(3 "Non-COVID death" )) ylab(none) ytitle("") name(`var', replace) title("`graphtitle'")
}

grc1leg agegroup male, name(agesex, replace)
graph export "./analysis/output/an_processout_sensanresults_AGESEX.svg", as(svg) replace

grc1leg ethnicity imd obese4cat smoke_nomiss, name(_otherdemog, replace)
graph combine _otherdemog, ysize(8) name(otherdemog, replace)
graph export "./analysis/output/an_processout_sensanresults_OTHERDEMOG.svg", as(svg) replace 

grc1leg diabcat cancer_exhaem_cat cancer_haem_cat reduced_kidney_function_cat2, name(_cm1, replace)
graph combine _cm1, ysize(8) name(cm1, replace)
graph export "./analysis/output/an_processout_sensanresults_COMORBS1.svg", as(svg) replace 

grc1leg asthmacat chronic_respiratory_disease chronic_cardiac_disease htdiag_or_highbp chronic_liver_disease dementia, name(cm2, replace)
graph export "./analysis/output/an_processout_sensanresults_COMORBS2.svg", as(svg) replace 

grc1leg stroke other_neuro organ_transplant spleen ra_sle_psoriasis other_immunosuppression, name(cm3, replace)
graph export "./analysis/output/an_processout_sensanresults_COMORBS3.svg", as(svg) replace 
