
 
import delimited ./output/input_flow_chart.csv

cap log close
log using ./analysis/output/an_flowchart, replace t

cap drop corr
gen corr=8900 /*N additional patients added to dB between main run and flow chart run*/

count
di r(N)-corr

count if under_fup_1feb==1
di r(N)-corr

count if under_fup_1feb==1 & has_12 != 1

count if under_fup_1feb==1 & has_12 == 1
di r(N)-corr

log close
