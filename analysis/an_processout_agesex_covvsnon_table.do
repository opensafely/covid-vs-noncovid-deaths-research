


*Coding: Krishnan Bhaskaran
*
*Date drafted: 10/9/2020
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
	
	foreach run of numlist 1/6 {
	
		
		local non
		if `run'==1|`run'==4 local non ""
		else if `run'==2|`run'==5 local non "NON"
		local noestimatesflag 0 /*reset*/

		local noestimatesflag 0 /*reset*/

		
*CHANGE THE OUTCOME BELOW TO LAST IF BRINGING IN MORE COLS
		if `run'==6 local endwith "_n"

		***********************
		*1) GET THE RIGHT ESTIMATES INTO MEMORY

		

		*FOR AGEGROUP - need to use the separate univariate/multivariate model fitted with age group rather than spline
		*FOR ETHNICITY - use the separate complete case multivariate model
		*FOR REST - use the "main" multivariate model
		if `run'==1|`run'==2 {
				cap estimates use ./analysis/output/models/an_covidvsnoncovid_agesex_`non'covid_`variable'
				if _rc!=0 local noestimatesflag 1				
		}
		else if `run'==3{
				cap estimates use ./analysis/output/models/an_noncovid_2019_agesex_`variable'
				if _rc!=0 local noestimatesflag 1	
		}
		else if `run'==4|`run'==5{
			if "`variable'"=="agegroup" cap estimates use ./analysis/output/models/an_covidvsnoncovid_full_`non'covid_agegroup_bmicat_noeth
			else if "`variable'"=="ethnicity" cap estimates use ./analysis/output/models/an_covidvsnoncovid_full_`non'covid_agespline_bmicat_cceth
			else cap estimates use ./analysis/output/models/an_covidvsnoncovid_full_`non'covid_agespline_bmicat_noeth
			if _rc!=0 local noestimatesflag 1				
		}
		else if `run'==6{
			if "`variable'"=="agegroup" cap estimates use ./analysis/output/models/an_noncovid_2019_full_agegroup_bmicat_noeth
			else if "`variable'"=="ethnicity" cap estimates use ./analysis/output/models/an_noncovid_2019_full_agespline_bmicat_cceth
			else cap estimates use ./analysis/output/models/an_noncovid_2019_full_agespline_bmicat_noeth
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
			
		} /*run 1/6 */
		
} /*variable levels*/

end
***********************************************************************************************************************
*Generic code to write a full row of "ref category" to the output file
cap prog drop refline
prog define refline
file write tablecontents _tab _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)") _tab ("1.00 (ref)")   _n
end
***********************************************************************************************************************

*MAIN CODE TO PRODUCE TABLE CONTENTS

cap file close tablecontents
file open tablecontents using ./analysis/output/an_processout_agesex_covvsnon_table.txt, t w replace 

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



