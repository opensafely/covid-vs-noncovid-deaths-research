cap log close
*log using ./analysis/output/an_covid_vs_othercauses_abs_AGESEX, replace t

***

cap prog drop getprediction
prog define getprediction, rclass

cap frame drop topredict
frame put in 1, into(topredict)
frame change topredict
replace `1'


predict pr0 pr1 pr2 pr3 pr4 pr5 pr6 pr7 pr8, pr
return scalar pr0=pr0
return scalar pr1=pr1
return scalar pr2=pr2
return scalar pr3=pr3
return scalar pr4=pr4
return scalar pr5=pr5
return scalar pr6=pr6
return scalar pr7=pr7
return scalar pr8=pr8
frame change default
end

****

use ./analysis/cr_create_analysis_dataset, clear

stset stime_onsdeath, fail(onsdeath) id(patient_id) enter(enter_date) origin(enter_date)

gen mloutcome = onsdeath if _d==1
replace mloutcome = 0 if _d==0

*FIT AGE SEX MODEL
mlogit mloutcome i.agegroup, rrr
*est save ./analysis/output/models/an_covid_vs_othercauses_abs_AGESEX, replace

cap frame drop absolutes
frame create absolutes agegroup pcovdeath pcancer_exh pcancer_haem pdem_alz pcvd presp_lrty presp_noninfect pother

	forvalues j=1/6{
	getprediction agegroup=`j'
	frame post absolutes (`j') (r(pr1)) (r(pr2)) (r(pr3)) (r(pr4)) (r(pr5)) (r(pr6)) (r(pr7)) (r(pr8))  
	}

frame change absolutes
*save ./analysis/output/an_covid_vs_othercauses_abs_AGESEX_ESTIMATES, replace

graph bar (mean) pcovdeath pcancer_exh pcancer_haem pdem_alz pcvd presp_lrt presp_non pother, by(age, cols(3) rescale legend(off)) ylab(, angle(0)) showyvars yvaroptions(relabel(1 COVID 2 CANCER 3 HAEM_CANCER 4 DEM_ALZ 5 CVD 6 LRTI 7 RESP 8 OTHER) label(angle(90) labsize(vsmall)))
graph bar (mean) pcovdeath pcancer_exh pcancer_haem pdem_alz pcvd presp_lrt presp_non pother, by(age, cols(1) rescale legend(off)) ylab(, angle(0)) 
*graph export ./analysis/output/an_covid_vs_othercauses_abs_AGESEX_GRAPH.svg, as(svg) replace
wd



graph bar (mean) pcovdeath pcancer_exh pcancer_haem pdem_alz pcvd presp_lrt presp_non pother, by(male , cols(1) rescale) over(age) yscale(log r(.0001 .02)) exclude0 ylab(.000002 .00002 .0002 .002 .02, angle(0))

preserve
replace pdem_alz = 2*10^(-7) if pdem_alz < 2*10^(-7) 
graph bar (mean) pcovdeath pcancer_exh pcancer_haem pdem_alz pcvd presp_lrt presp_non pother, by(male , cols(1) rescale) over(age) yscale(log) exclude0 ylab( .00001 .0001 .001 .01, angle(0)) name(log)
restore

preserve
replace pdem_alz = 2*10^(-7) if pdem_alz < 2*10^(-7) 
graph bar (mean) pcovdeath pcancer_exh pcancer_haem pdem_alz pcvd presp_lrt presp_non pother, by(male , cols(1) rescale) over(age) exclude0 ylab( .00001 .0001 .001 .01, angle(0))
restore