cap log close
log using ./analysis/output/an_ethnicitybycod, replace t

frames reset
use ./analysis/an_impute_imputeddata_MAIN, replace

gen mloutcome = onsdeath 

mi estimate, eform post: mlogit mloutcome i.ethnicity i.agegroup i.male, rrr

cap frame drop estimates
frame create estimates outcome ethnicity rrr lci uci

foreach outcome of numlist 1/6{
	foreach ethnicity of numlist 2/5 {
		cap lincom [`outcome'] `ethnicity'.ethnicity, rrr
		if _rc==0 frame post estimates (`outcome') (`ethnicity') (r(estimate)) (r(lb)) (r(ub))
}
}

frame change estimates

sort ethnicity outcome

label define ethnicity 	1 "White"  					///
						2 "Mixed vs White" 					///
						3 "Asian or Asian British vs White"	///
						4 "Black vs White"  					///
						5 "Other vs White"					
						
label values ethnicity ethnicity

label define outcomes 1 COVID 2 CANCER 3 CVD 4 DEM_ALZ 5 RESPIR 6 OTHER 
label values outcome outcomes

gen outcometext = "COVID-19" if outcome==1
replace outcometext = "Cancer" if outcome==2
replace outcometext = "CVD" if outcome==3
replace outcometext = "Dementia/Alzheim" if outcome==4
replace outcometext = "Respiratory" if outcome==5
replace outcometext = "Other" if outcome==6

gen esthr = string(rrr, "%4.2f") + " (" + string(lci, "%4.2f") + "-" + string(uci, "%4.2f") + ")"

gen graphorder = 7-outcome

gen labelat = .
replace labelat = 0.06
gen outcomeheadat = .
replace outcomeheadat = 0.05
gen estimatesat = 3.5

expand 2 if outcome==1, gen(expanded)
replace graphorder=7 if expanded==1
gen outcomehead="Cause of death category" if expanded==1
for var rrr lci uci : replace X=. if expanded==1
replace outcometext="" if expanded==1
replace esthr="" if expanded==1

scatter graphorder rrr if outcome==1, mcol(black) ///
	|| rcap lci uci graphorder if outcome==1, hor lcol(black) ///
	|| scatter graphorder rrr if outcome>1 , mcol(gs10) ///
	|| rcap lci uci graphorder if outcome>1, hor lcol(gs10) ///
	|| scatter graphorder labelat, m(i) mlab(outcometext) mlabcol(black) mlabsize(small) ///
	|| scatter graphorder outcomeheadat if graphorder==7, m(i) mlab(outcomehead) mlabcol(black) ///
	|| scatter graphorder estimatesat , m(i) mlab(esthr) mlabcol(black) mlabsize(vsmall) ///
	||, yscale(off r(0 7) lcol(white)) ytitle("") ylab(none) legend(off) xscale(log r(13)) xlab(.5 1 2 4) xtitle(Relative risk of cause-specific death and 95% CI) xline(1, lp(dash)) ///
	by(ethnicity, legend(off) ) 
	
graph export ./analysis/output/an_ethnicitybycod.svg, as(svg) replace

log close