frames reset
use ./analysis/cr_create_analysis_dataset_STSET_ONSCSDEATH.dta, clear

gen mloutcome = onsdeath if _d==1
replace mloutcome = 0 if _d==0

mlogit mloutcome i.ethnicity i.agegroup i.male, rrr

cap frame drop estimates
frame create estimates outcome ethnicity rrr lci uci

foreach outcome of numlist 1/6{
	foreach ethnicity of numlist 2/5 {
		cap lincom [`outcome'] `ethnicity'.ethnicity, rrr
		if _rc==0 frame post estimates (`outcome') (`ethnicity') (r(estimate)) (r(lb)) (r(ub))
}
}

frame change estimates


