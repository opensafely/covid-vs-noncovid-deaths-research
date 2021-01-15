# Covid vs noncovid deaths research

This study compares factors associated with covid death and non-covid death. 

The paper has been submitted to medRxiv and to an academic peer-reviewed journal

If you are interested in how we defined our variables, take a look at the study definition; this is written in python, but non-programmers should be able to understand what is going on there.

Developers and epidemiologists interested in the code should review our [OpenSAFELY documentation](https://docs.opensafely.org/en/latest/)

If you are interested in how we defined our code lists, look in the codelists folder. A new tool called OpenSafely Codelists was developed to allow codelists to be versioned and all of the codelists hosted online at codelists.opensafely.org for open inspection and re-use by anyone.

Raw analytical outputs are in the released_analysis_results folder.

# About the OpenSAFELY framework

The OpenSAFELY framework is a new secure analytics platform for
electronic health records research in the NHS.

Instead of requesting access for slices of patient data and
transporting them elsewhere for analysis, the framework supports
developing analytics against dummy data, and then running against the
real data *within the same infrastructure that the data is stored*.
Read more at [OpenSAFELY.org](https://opensafely.org).

The framework is under fast, active development to support rapid
analytics relating to COVID19; we're currently seeking funding to make
it easier for outside collaborators to work with our system.  You can
read our current roadmap [here](ROADMAP.md).
