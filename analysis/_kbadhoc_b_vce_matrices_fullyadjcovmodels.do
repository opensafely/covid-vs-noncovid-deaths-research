cap log close
log using analysis/output/_kbadhoc_b_vce_matrices_fullyadjcovmodels, replace t

estimates use ./analysis/output/models/an_covidvsnoncovid_full_MAIN_coviddeath_agegroup_bmicat_noeth

noi di _dup(50) "*"
noi di "MODEL FOR AGE GROUP ESTIMATES"
noi di _dup(50) "*"

estimates use ./analysis/output/models/an_imputed_full_MAIN_coviddeath_agegrp

noi matrix li e(b)
noi matrix li e(V)

noi di _dup(50) "*"
noi di "MODEL FOR ALL OTHER ESTIMATES"
noi di _dup(50) "*"

estimates use ./analysis/output/models/an_imputed_full_MAIN_coviddeath_agespl

noi matrix li e(b)
noi matrix li e(V)

log close
