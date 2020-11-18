  
from cohortextractor import (StudyDefinition, patients, filter_codes_by_category, combine_codelists)

from codelists import *

study = StudyDefinition(
    # Configure the expectations framework
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.1,
    },
    

# STUDY POPULATION

    # This line defines the study population
    population=patients.all(),

    #population=patients.satisfying(
    #        """
    #        has_follow_up AND
    #        (age >=18 AND age <= 110) AND
    #        (sex = "M" OR sex = "F") AND
    #        imd > 0 AND
    #        (rheumatoid OR sle) AND NOT
    #        chloroquine_not_hcq
    #        """,
    #        has_follow_up=patients.registered_with_one_practice_between(
    #        "2019-02-28", "2020-02-29"         
    #    ),

    #),

	has_12mfollow_up=patients.registered_with_one_practice_between(
        "2019-02-01", "2020-02-01", return_expectations={"incidence": 0.9},         
    ),

	under_fup_1feb=patients.registered_with_one_practice_between(
        "2020-02-01", "2020-02-01", return_expectations={"incidence": 0.9},         
    ),

    # The rest of the lines define the covariates with associated GitHub issues
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/33
    age=patients.age_as_of(
        "2020-02-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    # https://github.com/ebmdatalab/tpp-sql-notebook/issues/46
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),


    imd=patients.address_as_of(
        "2020-02-29",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),


)