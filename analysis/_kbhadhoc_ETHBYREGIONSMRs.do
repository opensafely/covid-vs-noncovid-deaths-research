
cap log close
log using "./analysis/output/_kbhadhoc_ETHBYREGIONSMRs", replace t

clear
gen str30 region="DUMMY"
save ./analysis/output/_kbhadhoc_ETHBYREGIONSMRs, replace

forvalues i = 1/9{
	use "./analysis/cr_create_analysis_dataset_SEPT2020_STSET.dta" , clear
	gen coviddeath = onsdeath==1 
	gen byte pop=1
	
	if `i'==1 local reg "East"
	if `i'==2 local reg "East Midlands"
	if `i'==3 local reg "London"
	if `i'==4 local reg "North East" 
	if `i'==5 local reg "North West" 
	if `i'==6 local reg "South East" 
	if `i'==7 local reg "South West" 
	if `i'==8 local reg "West Midlands" 
	if `i'==9 local reg "Yorkshire and The Humber" 

	di "REGION: `reg'"
	di _dup(30) "*"
	
	keep if region=="`reg'"

	collapse (sum) pop coviddeath, by(ethnicity agegroup male)

	preserve
	keep if ethnicity==1
	save _tempstandard`i', replace
	restore

	bysort ethnicity: egen totalcoviddeaths = sum(coviddeath)
	istdize totalcoviddeath pop agegroup male using _tempstandard`i', by(ethnicity) pop(coviddeath pop)
	foreach resulttype of any cases_obs cases_exp smr lb_smr ub_smr{
	    matrix `resulttype'=(r(`resulttype'))'
	}
	collapse (sum) pop, by(ethnicity)
	foreach resulttype of any cases_obs cases_exp smr lb_smr ub_smr{
		svmat `resulttype'
	}

		keep pop cases* smr lb ub
		keep if cases_obs<.
		gen str30 region = "`reg'"
		append using ./analysis/output/_kbhadhoc_ETHBYREGIONSMRs
		save ./analysis/output/_kbhadhoc_ETHBYREGIONSMRs, replace
	
}

log close

use _allregions, clear
gen ethnicity = mod(_n,5)
replace ethnicity=5 if ethnicity==0

gen reverseeth = 6-ethnicity

replace lb = 1 if eth==1
replace ub = 1 if eth==1

gen label = "White (REF)" if eth==1
replace label = "Mixed" if eth==2
replace label = "South Asian" if eth==3
replace label = "Black" if eth==4
replace label = "Other" if eth==5

gen labelpos=.002
gen leftarrowpos = 0.006

gen leftarrow = "<" if smr==0
replace lb = 0.012 if smr==0

scatter reverseeth smr if leftarrow!="<" || rcap lb ub reverseeth , lc(red) hor xscale(log) xline(1, lp(dash)) ///
 || scatter reverse labelpos, m(i) mlab(label) mlabsize(vsmall) ///
 || scatter reverse leftarrowpos, m(i) mlab(leftarrow) mlabc(red) ///
 || , by(region, legend(off)  title("Region specific SMRs for COVID death") t2("Standardised to age-sex-specific covid mortality of local white population")) xlab(0.25 0.5 1 2 5) legend(off) 

graph export ./analysis/output/_kbhadhoc_ETHBYREGIONSMRs_graph.svg, as(svg)
 
*graph bar pop if ethnicity!=1, by(region) over(ethnicity) 

keep region pop cases_ob cases_exp label
replace label = "White" if label=="White (REF)"
replace label = "S_Asian" if label=="South Asian"
rename pop cell1
rename cases_ob cell2
rename cases_exp cell3
reshape long cell, i(region label) j(cellname) string
reshape wide cell, i(region cellname) j(label) string
replace cellname = "Population" if cellname=="1"
replace cellname = "Observed" if cellname=="2"
replace cellname = "Expected" if cellname=="3"

for any White Mixed S_Asian Black Other: gen X = string(cellX)
for any White Mixed S_Asian Black Other: drop cellX
for any White Mixed S_Asian Black Other: replace X = "<=5" if real(X)>0 & real(X)<=5 & cellname=="Observed"
replace White = "-" if cellname=="Expected" 

outsheet using "./analysis/output/_kbhadhoc_ETHBYREGIONSMRs_table.csv", c

