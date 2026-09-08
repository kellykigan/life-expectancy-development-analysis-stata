/*******************************************************************************
PROJECT: Life Expectancy and Development Indicators
PURPOSE: Data import, inspection, validation, cleaning, transformation,
descriptive exploration, and panel-data preparation

DATASET: Life Expectancy Data.csv

AUTHOR: Kelly Kigan

SOFTWARE: Stata

DESCRIPTION:
This Do-file provides a reproducible workflow for preparing the Life Expectancy
dataset for quantitative development research analysis.

The workflow follows this sequence:

1. Project setup
2. Data import
3. Initial data inspection
4. Variable standardization and labeling
5. Dataset exploration
6. Missing data assessment
7. Duplicate and uniqueness checks
8. Descriptive statistics
9. Data visualization
10. Country and panel structure preparation
11. Data quality validation
12. Missingness investigation
13. GDP transformation
14. Panel declaration
15. Save prepared dataset

IMPORTANT REPRODUCIBILITY PRINCIPLE:
The original raw dataset should never be overwritten. All transformations are
performed in Stata and the prepared dataset is saved separately.
*******************************************************************************/

*===============================================================================

* SECTION 1: PROJECT SETUP
  *===============================================================================

* Clear Stata's memory to avoid conflicts with previously loaded datasets
  clear all

* Prevent Stata from pausing output after each screen
  set more off

* Close any open log files
  capture log close

* Define the main project directory
  global project "/Users/YourPCName/Documents/Life Expectancy Stata"

* Define commonly used project folders
  global rawdata "$project/data/raw"
  global cleandata "$project/data/clean"
  global graphs "$project/graphs"
  global dofiles "$project/dofiles"

*===============================================================================

* SECTION 2: IMPORT RAW DATA
  *===============================================================================

/*
Import the original CSV dataset.

The clear option ensures that any dataset currently loaded in Stata is removed
before importing the new dataset.

The encoding option is used to ensure special characters in the CSV are read
correctly.
*/

import delimited "$rawdata/Life Expectancy Data.csv", ///
encoding(ISO-8859-1) clear

*===============================================================================

* SECTION 3: INITIAL DATA INSPECTION
  *===============================================================================

/*
Before making any changes, inspect the structure of the imported dataset.

This allows us to confirm:

* Number of observations
* Number of variables
* Variable names
* Storage types
* Variable labels
  */

describe

* Display the first 10 observations to visually confirm successful import
  list in 1/10

* The browse command opens the dataset in Stata's Data Editor

* Useful for visual inspection, but not necessary for reproducible analysis
  browse

* Display a concise list of all variable names
  ds

*===============================================================================

* SECTION 4: STANDARDIZE VARIABLE NAMES
  *===============================================================================

/*
The CSV contains variable names that are converted during import.

We standardize important variable names using a consistent naming convention:

* Lowercase
* Underscores instead of spaces
* Clear and readable names

This improves readability and makes subsequent analysis easier.
*/

rename lifeexpectancy life_expectancy
rename adultmortality adult_mortality
rename infantdeaths infant_deaths
rename percentageexpenditure percentage_expenditure
rename hepatitisb hepatitis_b
rename underfivedeaths under_five_deaths
rename totalexpenditure total_expenditure
rename hivaids hiv_aids
rename incomecompositionofresources income_composition

*===============================================================================

* SECTION 5: APPLY VARIABLE LABELS
  *===============================================================================

/*
Variable labels improve the readability of Stata output.

Labels do not change the data. They simply provide descriptive information
about what each variable represents.
*/

label variable life_expectancy ///
"Life expectancy"

label variable adult_mortality ///
"Adult mortality"

label variable schooling ///
"Years of schooling"

label variable gdp ///
"GDP per capita"

label variable hiv_aids ///
"HIV/AIDS mortality"

label variable bmi ///
"Average BMI"

label variable income_composition ///
"Income composition of resources"

* Confirm that variable names and labels are correctly applied
  describe

*===============================================================================

* SECTION 6: EXPLORE CATEGORICAL AND TIME VARIABLES
  *===============================================================================

/*
Examine the main grouping and time variables.

status:
Developed versus Developing countries.

year:
The time dimension of the dataset.
*/

* Frequency distribution of country development status
  tabulate status

* Frequency distribution of years
  tabulate year

* Examine the country variable and number of unique countries
  codebook country

*===============================================================================

* SECTION 7: DESCRIPTIVE EXPLORATION OF KEY VARIABLES
  *===============================================================================

/*
Before conducting statistical analysis, examine the distribution of key
variables.

The detail option provides additional information including:

* Percentiles
* Median
* Variance
* Standard deviation
* Minimum
* Maximum
* Distribution characteristics
  */

- Overall summary of life expectancy
  summarize life_expectancy

- Detailed summary of life expectancy
  summarize life_expectancy, detail

- Detailed summary of schooling
  summarize schooling, detail

- Detailed summary of adult mortality
  summarize adult_mortality, detail

- Detailed summary of GDP per capita
  summarize gdp, detail

*===============================================================================

* SECTION 8: ASSESS MISSING DATA
  *===============================================================================

/*
Missing data can affect descriptive statistics, correlations, and regression
models.

This command provides an overview of missing values across all variables.
*/

misstable summarize

* Count observations with missing life expectancy
  count if missing(life_expectancy)

* Identify the countries and years where life expectancy is missing
  list country year if missing(life_expectancy)

*===============================================================================

* SECTION 9: CHECK FOR DUPLICATES AND DATA UNIQUENESS
  *===============================================================================

/*
The unit of observation in this dataset is a country-year.

Each country should have only one observation for a particular year.
*/

* Check for completely duplicated observations
  duplicates report

* Check for duplicate country-year combinations
  duplicates report country year

* Confirm that country and year uniquely identify each observation
  isid country year

*===============================================================================

* SECTION 10: DESCRIPTIVE ANALYSIS BY DEVELOPMENT STATUS
  *===============================================================================

/*
Compare life expectancy between Developed and Developing countries.

This provides an initial descriptive understanding of differences between
country groups.
*/

* Frequency distribution including any missing values
  tabulate status, missing

* Detailed descriptive statistics by development status
  tabstat life_expectancy, by(status) ///
  statistics(n mean median sd min max)

*===============================================================================

* SECTION 11: DATA VISUALIZATION
  *===============================================================================

/*
Visualizations help identify patterns, distributions, group differences,
and relationships between variables.

Only graphs relevant to the research questions are included.
*/

*------------------------------------------------------------------------------

* 11.1 Life Expectancy by Development Status
  *------------------------------------------------------------------------------

graph box life_expectancy, over(status) ///
title("Life Expectancy by Development Status") ///
ytitle("Life Expectancy (Years)") ///
name(box_status, replace)

* Save editable Stata graph
  graph save "$cleandata/life_expectancy_by_status.gph", replace

* Export publication-friendly PNG version
  graph export "$graphs/life_expectancy_by_status.png", replace

*------------------------------------------------------------------------------

* 11.2 Schooling and Life Expectancy
  *------------------------------------------------------------------------------

/*
Scatter plots are useful for examining the relationship between two continuous
variables.

Each point represents one country-year observation.
*/

scatter life_expectancy schooling, ///
title("Schooling and Life Expectancy") ///
ytitle("Life Expectancy (Years)") ///
xtitle("Years of Schooling") ///
name(scatter_schooling, replace)

graph save "$cleandata/scatter_schooling_life_expectancy.gph", replace

graph export "$graphs/scatter_schooling_life_expectancy.png", replace

*------------------------------------------------------------------------------

* 11.3 Schooling and Life Expectancy with Fitted Line
  *------------------------------------------------------------------------------

/*
The fitted line summarizes the average linear relationship between schooling
and life expectancy.

This visualization helps us assess whether higher levels of schooling are
generally associated with higher life expectancy.
*/

twoway ///
(scatter life_expectancy schooling) ///
(lfit life_expectancy schooling), ///
title("Relationship Between Schooling and Life Expectancy") ///
ytitle("Life Expectancy (Years)") ///
xtitle("Years of Schooling") ///
legend(order(1 "Country-Year Observations" 2 "Linear Fit")) ///
name(schooling_lfit, replace)

graph save "$cleandata/schooling_life_expectancy_lfit.gph", replace

graph export "$graphs/schooling_life_expectancy_lfit.png", replace

*===============================================================================

* SECTION 12: BIVARIATE CORRELATION
  *===============================================================================

/*
Examine the linear association between schooling and life expectancy.

The pwcorr command calculates pairwise correlations.

sig:
Displays statistical significance.

obs:
Displays the number of observations used in the correlation.
*/

pwcorr life_expectancy schooling, sig obs

*===============================================================================

* SECTION 13: CONFIRM DATASET SIZE
  *===============================================================================

/*
Record the total number of observations before creating additional variables.
*/

count

* Reconfirm the structure of the country variable
  codebook country

*===============================================================================

* SECTION 14: CREATE COUNTRY IDENTIFIER
  *===============================================================================

/*
The country variable is currently stored as text (string).

Panel-data commands in Stata require a numeric panel identifier.

The encode command creates a numeric version of country while retaining
country names through value labels.

The original country variable remains unchanged.
*/

encode country, gen(country_code)

* Verify the new country identifier
  describe country country_code

* Display selected observations to confirm the mapping
  list country country_code in 1/20

*===============================================================================

* SECTION 15: EXAMINE PANEL COMPLETENESS
  *===============================================================================

/*
The dataset covers multiple countries across multiple years.

We check whether each country has the expected number of yearly observations.

The full period covers 2000 to 2015, which represents 16 years.
*/

* Confirm the time range
  summarize year

* Display frequency of observations by year
  tabulate year

* Count observations available for each country
  bysort country: gen country_obs = _N

* Examine the distribution of country observation counts
  tabulate country_obs

* Identify countries with fewer than 16 observations
  list country country_obs if country_obs < 16

* Remove the temporary diagnostic variable
  drop country_obs

* Reconfirm that country-year combinations remain unique
  isid country year

*===============================================================================

* SECTION 16: CHECK DEVELOPMENT STATUS CONSISTENCY
  *===============================================================================

/*
Status should generally be consistent for each country across time.

We inspect the relationship between country and development status.
*/

tabulate country status

*===============================================================================

* SECTION 17: CHECK PLAUSIBLE VALUE RANGES
  *===============================================================================

/*
Before conducting regression analysis, check for clearly impossible values.

IMPORTANT:

Unusual observations should NOT automatically be deleted.

An extreme value may represent a real country characteristic rather than
a data error.

The correct approach is:

Identify -> Investigate -> Verify -> Document -> Modify only if justified.
*/

*------------------------------------------------------------------------------

* 17.1 Immunization indicators
  *------------------------------------------------------------------------------

/*
These variables are measured as percentages and should generally fall between
0 and 100.
*/

count if hepatitis_b < 0 | hepatitis_b > 100

count if polio < 0 | polio > 100

count if diphtheria < 0 | diphtheria > 100

*------------------------------------------------------------------------------

* 17.2 Life expectancy
  *------------------------------------------------------------------------------

summarize life_expectancy, detail

count if life_expectancy <= 0

*------------------------------------------------------------------------------

* 17.3 Schooling
  *------------------------------------------------------------------------------

summarize schooling, detail

count if schooling < 0

*------------------------------------------------------------------------------

* 17.4 BMI
  *------------------------------------------------------------------------------

summarize bmi, detail

count if bmi < 0

*------------------------------------------------------------------------------

* 17.5 GDP
  *------------------------------------------------------------------------------

summarize gdp, detail

count if gdp < 0

*===============================================================================

* SECTION 18: INVESTIGATE MISSINGNESS IN ANALYTICAL VARIABLES
  *===============================================================================

/*
Focus specifically on variables likely to be used in the main development
research analysis.
*/

misstable summarize ///
life_expectancy ///
schooling ///
adult_mortality ///
hiv_aids ///
bmi ///
gdp

/*
Examine whether missing observations are concentrated within particular
development-status groups.

This is important because systematic missingness can affect the composition
of the analytical sample.
*/

* Status distribution among observations with missing schooling
  tabulate status if missing(schooling)

* Status distribution among observations with missing GDP
  tabulate status if missing(gdp)

* Status distribution among observations with missing HIV/AIDS mortality
  tabulate status if missing(hiv_aids)

*===============================================================================

* SECTION 19: CREATE AND INSPECT A MISSINGNESS INDICATOR
  *===============================================================================

/*
This demonstrates how missing-data indicators can be created.

1 = schooling is missing
0 = schooling is observed

The variable is created temporarily to inspect missingness.
*/

gen schooling_missing = missing(schooling)

* Examine the missingness indicator
  tabulate schooling_missing

* Remove the temporary diagnostic variable
  drop schooling_missing

*===============================================================================

* SECTION 20: TRANSFORM GDP
  *===============================================================================

/*
GDP per capita is highly right-skewed.

A logarithmic transformation compresses extreme values and can improve the
distribution for regression analysis.

The original GDP variable is retained.

Only positive GDP observations can be logged.
*/

gen ln_gdp = ln(gdp) if gdp > 0

* Label the transformed variable
  label variable ln_gdp "Natural logarithm of GDP per capita"

* Compare the original and transformed distributions
  summarize gdp ln_gdp, detail

*===============================================================================

* SECTION 21: VISUALIZE GDP DISTRIBUTIONS
  *===============================================================================

/*
Compare the distribution of original GDP and log-transformed GDP.

This helps assess whether the transformation reduces extreme right-skewness.
*/

* Histogram of original GDP
  histogram gdp, ///
  title("Distribution of GDP per Capita") ///
  name(hist_gdp, replace)

graph save "$cleandata/histogram_gdp.gph", replace

graph export "$graphs/histogram_gdp.png", replace

* Histogram of log-transformed GDP
  histogram ln_gdp, ///
  title("Distribution of Log GDP per Capita") ///
  name(hist_lngdp, replace)

graph save "$cleandata/histogram_ln_gdp.gph", replace

graph export "$graphs/histogram_ln_gdp.png", replace

* Confirm the transformed variable
  describe ln_gdp

*===============================================================================

* SECTION 22: DECLARE PANEL DATA STRUCTURE
  *===============================================================================

/*
This dataset contains repeated observations of countries over time.

The panel structure is:

Panel unit: country_code
Time variable: year

The xtset command tells Stata that observations belong to countries observed
repeatedly across multiple years.
*/

xtset country_code year

* Describe the panel structure
  xtdescribe

*===============================================================================

* SECTION 23: EXAMINE WITHIN AND BETWEEN VARIATION
  *===============================================================================

/*
The xtsum command separates variation into:

Overall:
Variation across all country-year observations.

Between:
Variation between countries.

Within:
Variation occurring within countries over time.

Understanding these distinctions is important before conducting fixed-effects
panel regression.
*/

xtsum life_expectancy

*===============================================================================

* SECTION 24: SAVE PREPARED DATASET
  *===============================================================================

/*
Save the prepared dataset separately from the original raw data.

This dataset will be used for descriptive analysis, regression analysis,
and panel-data modelling in subsequent Do-files.
*/

save "$cleandata/life_expectancy_clean.dta", replace

*===============================================================================

* END OF DATA PREPARATION DO-FILE. Thank you for viewing my work!==
  *===============================================================================

REPRODUCIBILITY NOTE:

To reproduce this analysis:

1. Keep the raw CSV unchanged.
2. Maintain the same project folder structure.
3. Update the project path if running the Do-file on another computer.
4. Run this Do-file from the beginning rather than executing isolated commands.
5. Record and justify all future data transformations and analytical decisions.
   */
