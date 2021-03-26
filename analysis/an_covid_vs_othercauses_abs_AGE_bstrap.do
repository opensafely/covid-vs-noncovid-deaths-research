cap log close
log using ./analysis/output/an_covid_vs_othercauses_abs_AGE_bstrap, replace t

use ./analysis/cr_create_analysis_dataset_MAIN_STSET.dta, clear

gen mloutcome = onsdeath if _d==1
replace mloutcome = 0 if _d==0

keep mloutcome agegroup male
gen byte counter = 1

cap prog drop mybstrapmlogit
prog define mybstrapmlogit, rclass
*#RESAMPLE
preserve
collapse (sum) counter, by(male agegroup mloutcome)
mlogit mloutcome i.agegroup male [fw=counter], rrr

keep in 1
replace male=0.5
foreach agegroup of numlist 1/6{
replace agegroup = `agegroup'

*predictnl p_a`agegroup'_o`outcome' = predict(outcome(`outcome'))
predict pa`agegroup'o0 pa`agegroup'o1 pa`agegroup'o2 pa`agegroup'o3 pa`agegroup'o4 pa`agegroup'o5 pa`agegroup'o6
return scalar pa`agegroup'o0 =pa`agegroup'o0
return scalar pa`agegroup'o1 =pa`agegroup'o1
return scalar pa`agegroup'o2 =pa`agegroup'o2
return scalar pa`agegroup'o3 =pa`agegroup'o3
return scalar pa`agegroup'o4 =pa`agegroup'o4
return scalar pa`agegroup'o5 =pa`agegroup'o5
return scalar pa`agegroup'o6 =pa`agegroup'o6
}

restore
end

bootstrap 	pa1o1=r(pa1o1) pa1o2=r(pa1o2) pa1o3=r(pa1o3) ///
			pa1o4=r(pa1o4) pa1o5=r(pa1o5) pa1o6=r(pa1o6) ///
			pa2o1=r(pa2o1) pa2o2=r(pa2o2) pa2o3=r(pa2o3) ///
			pa2o4=r(pa2o4) pa2o5=r(pa2o5) pa2o6=r(pa2o6) ///
			pa3o1=r(pa3o1) pa3o2=r(pa3o2) pa3o3=r(pa3o3) ///
			pa3o4=r(pa3o4) pa3o5=r(pa3o5) pa3o6=r(pa3o6) ///
			pa4o1=r(pa4o1) pa4o2=r(pa4o2) pa4o3=r(pa4o3) ///
			pa4o4=r(pa4o4) pa4o5=r(pa4o5) pa4o6=r(pa4o6) ///
			pa5o1=r(pa5o1) pa5o2=r(pa5o2) pa5o3=r(pa5o3) ///
			pa5o4=r(pa5o4) pa5o5=r(pa5o5) pa5o6=r(pa5o6) ///
			pa6o1=r(pa6o1) pa6o2=r(pa6o2) pa6o3=r(pa6o3) ///
			pa6o4=r(pa6o4) pa6o5=r(pa6o5) pa6o6=r(pa6o6) ///
			, reps(1000) saving(analysis/an_covid_vs_othercauses_abs_AGE_bstrap_SAMPLES, replace) : mybstrapmlogit 


*extract final estimates and CIs and plot		

*refit the model on original data to get point estimates
use ./analysis/cr_create_analysis_dataset_MAIN_STSET.dta, clear

frame create absolutes agegroup pcovdeath pcancer pcvd pdem_alz presp pother

gen mloutcome = onsdeath if _d==1
replace mloutcome = 0 if _d==0

keep mloutcome agegroup male
gen byte counter = 1

collapse (sum) counter, by(male agegroup mloutcome)
mlogit mloutcome i.agegroup male [fw=counter], rrr

keep in 1
replace male=0.5
foreach agegroup of numlist 1/6{
replace agegroup = `agegroup'
predict pa`agegroup'o0 pa`agegroup'o1 pa`agegroup'o2 pa`agegroup'o3 pa`agegroup'o4 pa`agegroup'o5 pa`agegroup'o6
frame post absolutes (`agegroup') (pa`agegroup'o1) (pa`agegroup'o2) (pa`agegroup'o3) (pa`agegroup'o4) (pa`agegroup'o5) (pa`agegroup'o6)
}
frame absolutes{
    reshape long p, i(agegroup) string
	gen outcome = 1 if _j=="covdeath"
	replace outcome = 2 if _j=="cancer"
	replace outcome = 3 if _j=="cvd"
	replace outcome = 4 if _j=="dem_alz"
	replace outcome = 5 if _j=="resp"
	replace outcome = 6 if _j=="other"
	sort agegroup outcome
}

cap frame drop bootstraps
frame create bootstraps dummyvar

frame bootstraps: use analysis/an_covid_vs_othercauses_abs_AGE_bstrap_SAMPLES, clear
frame bootstraps{
        matrix CI = 0\0
        foreach var of varlist p*{
                 preserve
                 keep `var'
                 sort `var'
                 gen obsn = _n
                 keep if (obsn==50)| (obsn==950)
                 gen stat = "lci" if _n==1
                 replace stat = "uci" if _n==2
                 mkmat p* , matrix(CInew) rownames(stat) 
                 matrix CI = CI , CInew
                 restore
         }
}
matrix CIprime = CI[1...,2...]'
frame absolutes: svmat CIprime, names(col)

*plot the graph and output estimates
frame change absolutes

*alternative to bar chart
preserve
	sort outcome agegroup
	gen n=_n
	gen star = "V*" if agegroup<=2 & outcome==4
	gen starpoint = 10^(-6) if star=="*"
	scatter p n if p>(10^(-6)) & agegroup==1 , mc(gs12) || rcap r1 r2 n if r1>(10^(-6)) & agegroup==1, lc(gs12) ///
	|| scatter p n if p>(10^(-6)) & agegroup==2, mc(gs10) || rcap r1 r2 n if r1>(10^(-6)) & agegroup==2, lc(gs10)   /// 
	|| scatter p n if p>(10^(-6)) & agegroup==3, mc(gs8) || rcap r1 r2 n if r1>(10^(-6)) & agegroup==3, lc(gs8)  ///
	|| scatter p n if p>(10^(-6)) & agegroup==4, mc(gs6) || rcap r1 r2 n if r1>(10^(-6)) & agegroup==4 , lc(gs6) ///
	|| scatter p n if p>(10^(-6)) & agegroup==5, mc(gs3) || rcap r1 r2 n if r1>(10^(-6)) & agegroup==5 , lc(gs3) ///
	|| scatter p n if p>(10^(-6)) & agegroup==6, mc(gs1) || rcap r1 r2 n if r1>(10^(-6)) & agegroup==6 , lc(gs1) ///
	|| scatter starpoint n if p<=(10^(-6)) & agegroup==1, m(i) mlab(star) mlabcol(gs12) || scatter starpoint n if p<=(10^(-6)) & agegroup==2, m(i) mlab(star) mlabcol(gs10) ///
	|| , yscale(log) ylab(.00001 .0001 .001 .01 .1 1) ///
		text(0.1 1 "COVID-19", placement(e)) text(0.1 8 "Cancer", placement(e)) text(0.1 15 "CVD", placement(e)) text(0.1 20 "Dementia", placement(e)) text(0.1 26 "Respiratory", placement(e)) text(0.1 33 "Other", placement(e)) xsize(8) xlab(none) xtitle("") legend(label(1 "Age (yrs) 18-<40") label(3 "40-<50") label(5 "50-<60") label(7 "60-<70") label(9 "70-<80") label(11 "80+") order(1 3 5 7 9 11) rows(1)) ytitle(Estimated probability of cause-specific death) ///
		caption("* = estimated probability < 0.000001 not shown")
	graph export "./analysis/output/FIGURE 2 an_covid_vs_othercauses_abs_AGE_GRAPH_ALT.pdf", as(pdf) replace
restore
	
drop outcome
reshape wide p r1 r2, i(agegroup) j(_j) string

label define agegrouplab 1 "18-<40" 2 "40-<50" 3 "50-<60" 4 "60-<70" 5 "70-<80" 6 "80+"
label values agegroup agegrouplab

gen gap = 0

graph bar (mean) pcovdeath gap pcancer pcvd pdem_alz presp pother, by(age, cols(3) rescale legend(off)) ylab(, angle(0)) showyvars yvaroptions(relabel(1 COVID 2 "---------" 3 CANCER 4 CVD 5 DEM_ALZ 6 RESPIR 7 OTHER) label(angle(90) labsize(vsmall))) bargap(10) bar(1, color(black)) bar(3, color(gs7)) bar(4, color(gs7)) bar(5, color(gs7)) bar(6, color(gs7)) bar(7, color(gs7))
graph export ./analysis/output/an_covid_vs_othercauses_abs_AGE_GRAPH.svg, as(svg) replace

drop gap
for var p* r*: replace X = X*100
gen covid = string(pcovdeath, "%5.2g") + " (" + string(r1covdeath, "%5.2g") + "-" + string(r2covdeath, "%5.2g") + ")" 
gen cancer = string(pcancer, "%5.2g") + " (" + string(r1cancer, "%5.2g") + "-" + string(r2cancer, "%5.2g") + ")" 
gen cvd = string(pcvd, "%5.2g") + " (" + string(r1cvd, "%5.2g") + "-" + string(r2cvd, "%5.2g") + ")" 
gen dem_alz = string(pdem_alz, "%5.2g") + " (" + string(r1dem_alz, "%5.2g") + "-" + string(r2dem_alz, "%5.2g") + ")" 
gen resp = string(presp, "%5.2g") + " (" + string(r1resp, "%5.2g") + "-" + string(r2resp, "%5.2g") + ")" 
gen other = string(pother, "%5.2g") + " (" + string(r1other, "%5.2g") + "-" + string(r2other, "%5.2g") + ")" 

outsheet agegroup covid cancer cvd dem_alz resp other using ./analysis/output/an_covid_vs_othercauses_abs_AGE_ESTIMATES.txt, c replace

log close		