use  ./analysis/cr_create_analysis_dataset_SEPT2020_STSET.dta, clear

gen cons = 1

cap prog drop getrow
program define getrow
syntax, variable(string) min(real) max(real)

foreach level of numlist `min'/`max'{

local and "& `variable' == `level'"
    file write table _n ("`variable' = `level'") _tab
	foreach i of numlist 1/5{
		cou if ethnicity==`i' 
		local coldenom = r(N)
		cou if ethnicity==`i' `and'
		local numerator = r(N)
		local pct = 100*`numerator'/`coldenom'
		file write table (`numerator') (" (") %4.1f (`pct') (")") _tab
}

}

end 


file open table using ./analysis/output/_kbadhoc_ethnicity2wave_desctable.txt, replace write

getrow, variable(cons) min(1) max(1)
getrow, variable(agegroup) min(1) max(6)
getrow, variable(male) min(0) max(1)
getrow, variable(imd) min(1) max(5)

file close table
