
cap postutil clear
tempfile results
postfile results str13 outcome str6 model ethnicity imd or lb ub pval using `results'

foreach outcome of any coviddeath noncoviddeath{
foreach model of any agesex full{
    
	if "`model'"=="full" local agespl "_agespl"
	else local agespl
		
	estimates use analysis/output/models/an_imputed_ETHxDEPR_`model'_MAIN_`outcome'`agespl'

	use ./analysis/an_impute_imputeddata_MAIN, replace

	testparm i.ethnicity#i.imd
	local pint`outcome'`model' = round(100*r(p), 1)

	forvalues i=2/5{
		cap lincom `i'.imd
		if _rc==0 {
			lincom `i'.imd
			post results ("`outcome'") ("`model'") (1) (`i') (r(estimate)) (r(lb)) (r(ub)) (`pint`outcome'`model'')
		}
	}

	*Deprivation effect in other groups
	forvalues e=2/5{
	forvalues i=2/5{
		cap lincom `i'.imd + `e'.ethnicity#`i'.imd
		if _rc==0 {
			lincom `i'.imd + `e'.ethnicity#`i'.imd
			post results ("`outcome'") ("`model'") (`e') (`i') (r(estimate)) (r(lb)) (r(ub)) (`pint`outcome'`model'')
		}
		}
	}

} /*agesex full*/
} /*cov noncov*/

postclose results

foreach outcome of any coviddeath noncoviddeath{

use `results', clear
keep if outcome=="`outcome'"

/*TEMP
expand 2, gen(expanded)
replace imd = 3 if expanded==1 & imd==5
replace imd = 2 if expanded==1 & imd==4
drop expanded 
******/

expand 2 if imd==2, gen(expanded)
replace imd=1 if expanded==1
replace or = 1 if imd==1
replace lb = 1 if imd==1
replace ub = 1 if imd==1
drop expanded

expand 5 if imd==1, gen(expanded)

gsort outcome -ethnicity -model -imd expanded

gen ethlab = "White" if ethnicity==1 & imd==1 & expanded==1 & expanded[_n-1]==0 & model=="agesex"
replace ethlab = "Mixed" if ethnicity==2 & imd==1 & expanded==1 & expanded[_n-1]==0 & model=="agesex"
replace ethlab = "Asian/Asian British" if ethnicity==3 & imd==1 & expanded==1 & expanded[_n-1]==0 & model=="agesex"
replace ethlab = "Black" if ethnicity==4 & imd==1 & expanded==1 & expanded[_n-1]==0 & model=="agesex"
replace ethlab = "Other" if ethnicity==5 & imd==1 & expanded==1 & expanded[_n-1]==0 & model=="agesex"

gen yval=_n if expanded!=1 | ethlab!=""
for var or lb ub: replace X = . if ethlab!=""
replace yval = yval+1 if ethlab!=""

gen deplab = "1 (least deprived, reference)" if imd==1 & yval<. & ethlab==""
replace deplab = "2" if imd==2 & yval<. & ethlab==""
replace deplab = "3" if imd==3 & yval<. & ethlab==""
replace deplab = "4" if imd==4 & yval<. & ethlab==""
replace deplab = "5 (most deprived)" if imd==5 & yval<. & ethlab==""

gen ethlabpos = 0.03
gen deplabpos = 0.04
gen orandcipos = 8
gen orandci = string(or, "%5.2f") + " (" + string(lb, "%5.2f") + "-" + string(ub, "%5.2f") + ")" if yval<.&ethlab==""
replace orandci = "1.00 (ref)" if imd==1 & orandci!=""

    if "`outcome'"=="noncoviddeath" local titlepref "non-"
	else local titlepref
scatter yval or if model=="agesex", m(Oh) mc(black) || scatter yval or if model=="full" , mc(black) ///
|| rcap lb ub yval if model=="agesex", hor lc(black) || rcap lb ub yval if model=="full", hor lc(black) ///
|| scatter yval ethlabpos, m(i) mlab(ethlab) mlabsize(vsmall) ///
|| scatter yval deplabpos, m(i) mlab(deplab) mlabsize(tiny) ///
|| scatter yval orandcipos, m(i) mlab(orandci) mlabsize(tiny) ///
|| if outcome=="`outcome'", xlab(0.5 1 2 4) xscale(log) xscale(r(0.125 48)) yscale(off) legend(off) ysize(10) ///
xtitle("Odds Ratio vs least deprived and 95% CI") title(`titlepref'COVID-19 death) xline(1, lp(dash)) note(" " "open circles = age-sex adjusted " "solid circles = fully adjusted*" "(*see Bhaskaran et al Lancet Regional Health Europe 2021)" "p-interaction (fully adj model) = 0.`pint`outcome'full'", size(tiny)) name(`outcome', replace)
}

graph combine coviddeath noncoviddeath, rows(1) ysize(8)
graph export analysis/output/an_processout_ethxdepr.svg, as(svg) replace
