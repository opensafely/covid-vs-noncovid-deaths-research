/*clear
import delimited `c(pwd)'/output/input.csv


clear
import delimited `c(pwd)'/output/input_2019.csv
*/

*import delimited `c(pwd)'/output/covid_vs_noncovid.csv
*import delimited `c(pwd)'/output/covid_vs_noncovid_2019.csv

*cd analysis

*DATA MANAGEMENT
do ./analysis/cr_create_analysis_dataset_GENERAL MAIN
do ./analysis/cr_create_analysis_dataset_GENERAL sept2020
do ./analysis/cr_create_analysis_dataset_GENERAL 2019

*GEN MI DATA
do ./analysis/an_impute_GENERAL MAIN
do ./analysis/an_impute_GENERAL SEPT2020
do ./analysis/an_impute_GENERAL 2019

*TABLE 1 DESCRIPTIVES
do ./analysis/an_tablecontent_PublicationDescriptivesTable

*ABSOLUTE RISKS BY CAUSE OF DEATH (FIG 2)
do ./analysis/an_covid_vs_othercauses_abs_AGE

*SEPARATE AGE SEX-ADJUSTED and FULLY ADJUSTED "FACTORS ASSOC" LOGISTIC MODELS FOR COVID AND NON COVID DEATH, PLUS 2019 DEATH
do ./analysis/an_covidvsnoncovid_agesex_GENERAL MAIN 
do ./analysis/an_covidvsnoncovid_agesex_GENERAL SEPT2020
do ./analysis/an_covidvsnoncovid_agesex_GENERAL 2019

do ./analysis/an_covidvsnoncovid_agesex_GENERAL MAIN SA_anywhereonDC
do ./analysis/an_covidvsnoncovid_agesex_GENERAL MAIN SA_u071only

do ./analysis/an_covidvsnoncovid_full_GENERAL MAIN
do ./analysis/an_covidvsnoncovid_full_GENERAL SEPT2020
do ./analysis/an_covidvsnoncovid_full_GENERAL 2020

*ETHNICITY EFFECTS ON DIFFERENT CAUSE-SPECIFIC MORTALITY OUTCOMES (FIG 4)
do ./analysis/an_ethnicitybycod_logisticversion

*DEATHS ONLY LOGISTIC ANALYSIS
do ./analysis/an_deathsonlyanalysis

*MI
do ./analysis/an_imputed_GENERAL MAIN coviddeath agesex agespl
do ./analysis/an_imputed_GENERAL MAIN noncoviddeath agesex agespl
do ./analysis/an_imputed_GENERAL MAIN coviddeath full agespl
do ./analysis/an_imputed_GENERAL MAIN coviddeath full agegrp
do ./analysis/an_imputed_GENERAL MAIN noncoviddeath full agespl
do ./analysis/an_imputed_GENERAL MAIN noncoviddeath full agegrp
do ./analysis/an_imputed_GENERAL SEPT2020 coviddeath agesex agespl
do ./analysis/an_imputed_GENERAL SEPT2020 noncoviddeath agesex agespl
do ./analysis/an_imputed_GENERAL SEPT2020 coviddeath full agespl
do ./analysis/an_imputed_GENERAL SEPT2020 coviddeath full agegrp
do ./analysis/an_imputed_GENERAL SEPT2020 noncoviddeath full agespl
do ./analysis/an_imputed_GENERAL SEPT2020 noncoviddeath full agegrp
do ./analysis/an_imputed_GENERAL 2019 primarycaredeath agesex agespl
do ./analysis/an_imputed_GENERAL 2019 primarycaredeath full agespl
do ./analysis/an_imputed_GENERAL 2019 primarycaredeath full agegrp

do ./analysis/an_imputed_GENERAL MAIN coviddeath agesex agespl SA_anywhereonDC
do ./analysis/an_imputed_GENERAL MAIN noncoviddeath agesex agespl SA_anywhereonDC
do ./analysis/an_imputed_GENERAL MAIN coviddeath agesex agespl SA_u071only
do ./analysis/an_imputed_GENERAL MAIN noncoviddeath agesex agespl SA_u071only

do ./analysis/an_imputed_GENERAL MAIN deathsonlyCvN agesex agespl

*DISPLAY ITEMS
*FOREST PLOT (PROCESSING OF ABOVE RR ESTIMATES) (FIG 3)
do ./analysis/an_processout_agesex_covvsnon_forestplots

*TABLE OF AGE-SEX ADJ ESTIMATES PLUS FULLY ADJ PLUS 2019 (APPX TABLE)
do ./analysis/an_processout_agesex_covvsnon_table

*FOREST PLOT OF DEATHS ONLY ANALYSIS
do ./analysis/an_processout_deathsonlyanalysis
