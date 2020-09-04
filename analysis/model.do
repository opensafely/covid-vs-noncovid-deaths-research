/*clear
import delimited `c(pwd)'/output/input.csv


clear
import delimited `c(pwd)'/output/input_2019.csv
*/

*import delimited `c(pwd)'/output/covid_vs_noncovid.csv
*import delimited `c(pwd)'/output/covid_vs_noncovid_2019.csv

do cr_create_analysis_dataset
do cr_create_analysis_dataset_2019

do an_covidvsnoncovid_agesex
do an_covidvsnoncovid_full

do an_noncovid_agesex /*primary care deaths*/
do an_noncovid_full /*primary care deaths*/