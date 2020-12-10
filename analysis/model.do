/*clear
import delimited `c(pwd)'/output/input.csv


clear
import delimited `c(pwd)'/output/input_2019.csv
*/

*import delimited `c(pwd)'/output/covid_vs_noncovid.csv
*import delimited `c(pwd)'/output/covid_vs_noncovid_2019.csv

*cd analysis

*DATA MANAGEMENT
do ./analysis/cr_create_analysis_dataset
do ./analysis/cr_create_analysis_dataset_2019
do ./analysis/cr_create_analysis_dataset_sept2020

*TABLE 1 DESCRIPTIVES
do ./analysis/an_tablecontent_PublicationDescriptivesTable

*ABSOLUTE RISKS BY CAUSE OF DEATH (FIG 2)
do ./analysis/an_covid_vs_othercauses_abs_AGE

*SEPARATE AGE SEX-ADJUSTED and FULLY ADJUSTED "FACTORS ASSOC" LOGISTIC MODELS FOR COVID AND NON COVID DEATH, PLUS 2019 DEATH
do ./analysis/an_covidvsnoncovid_agesex
do ./analysis/an_covidvsnoncovid_full

do ./analysis/an_noncovid_2019_agesex.do
do ./analysis/an_noncovid_2019_full.do

*FOREST PLOT (PROCESSING OF ABOVE RR ESTIMATES) (FIG 3)
do ./analysis/an_processout_agesex_covvsnon_forestplots

*TABLE OF AGE-SEX ADJ ESTIMATES PLUS FULLY ADJ PLUS 2019 (APPX TABLE)
do ./analysis/an_processout_agesex_covvsnon_table

*ETHNICITY EFFECTS ON DIFFERENT CAUSE-SPECIFIC MORTALITY OUTCOMES (FIG 4)
do ./analysis/an_ethnicitybycod

*DEATHS ONLY LOGISTIC ANALYSIS
do ./analysis/an_deathsonlyanalysis

*FOREST PLOT OF DEATHS ONLY ANALYSIS
do ./analysis/an_processout_deathsonlyanalysis

*MI
/*
do ./analysis/an_impute_GENERAL MAIN
do ./analysis/an_impute_GENERAL SEPT2020
do ./analysis/an_impute_GENERAL 2019
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


*first argument dataset (MAIN SEPT2020 2019)
*second argument outcome (coviddeath noncoviddeath primarycaredeath)
*third argument modeltorun (agesex full)
*fourth argument agetype (agespl agegrp)
*/
