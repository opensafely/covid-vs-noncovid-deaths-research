cap log close
log using ./analysis/output/an_covid_vs_othercauses_abs_AGE, replace t

***

cap prog drop getprediction
prog define getprediction, rclass

cap frame drop topredict
frame put in 1, into(topredict)
frame change topredict
replace `1'
replace male = 0.5 
predict pr0 pr1 pr2 pr3 pr4 pr5 pr6, pr
return scalar pr0=pr0
return scalar pr1=pr1
return scalar pr2=pr2
return scalar pr3=pr3
return scalar pr4=pr4
return scalar pr5=pr5
return scalar pr6=pr6
frame change default
end

****
frames reset
use ./analysis/cr_create_analysis_dataset_STSET_ONSCSDEATH.dta, clear

gen mloutcome = onsdeath if _d==1
replace mloutcome = 0 if _d==0

*FIT AGE SEX MODEL
mlogit mloutcome i.agegroup i.male, rrr
*est save ./analysis/output/models/an_covid_vs_othercauses_abs_AGESEX, replace

cap frame drop absolutes
frame create absolutes agegroup pcovdeath pcancer pdem_alz pcvd presp pother

	forvalues j=1/6{
	getprediction agegroup=`j'
	frame post absolutes (`j') (r(pr1)) (r(pr2)) (r(pr3)) (r(pr4)) (r(pr5)) (r(pr6))  
	}

frame change absolutes
label define agegroup 	1 "18-<40" ///
						2 "40-<50" ///
						3 "50-<60" ///
						4 "60-<70" ///
						5 "70-<80" ///
						6 "80+"
label values agegroup agegroup
save ./analysis/output/an_covid_vs_othercauses_abs_AGE_ESTIMATES, replace

gen gap = 0

graph bar (mean) pcovdeath gap pcancer pdem_alz pcvd presp pother, by(age, cols(3) rescale legend(off)) ylab(, angle(0)) showyvars yvaroptions(relabel(1 COVID 2 "---------" 3 CANCER 4 CVD 5 DEM_ALZ 6 RESPIR 7 OTHER) label(angle(90) labsize(vsmall))) bargap(10) bar(1, color(black)) bar(3, color(gs7)) bar(4, color(gs7)) bar(5, color(gs7)) bar(6, color(gs7)) bar(7, color(gs7))
graph export ./analysis/output/an_covid_vs_othercauses_abs_AGE_GRAPH.svg, as(svg) replace


