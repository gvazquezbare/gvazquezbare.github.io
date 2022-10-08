********************************************************************************
** Writing Stata Packages
** Gonzalo Vazquez-Bare - UC Santa Barbara
********************************************************************************

********************************************************************************
** Example data set
********************************************************************************

sysuse nlsw88, clear

********************************************************************************
** Examples from the slides
********************************************************************************

describe

summarize age
return list

regress wage collgrad if married==1
ereturn list

local a "x y z"
display "`a'"

local b = 1
display `b'

local c = `b' + 1
display `c'

local d "`a' w"
display "`d'"

global a = 4
display $a

tempvar auxvar
gen `auxvar' = age^2
sum `auxvar'

scalar k = 6
display k + 4
gen k = runiform()
di k
di scalar(k)

local numbers "one two three"
di "`numbers'"
tokenize `numbers'
di "`1'"
di "`2'"
di "`3'"

mata
x = 1
x + 2
M = (1,2,3\4,5,6)
M
M'
end

********************************************************************************
** regby
********************************************************************************

/* Program to run OLS regressions of an outcome variable against a regressor 
of interest over the values of a categorical variable */

***************************************
** regby1
***************************************

* Basic syntax

tab collgrad 
regby1 wage married, catvar(collgrad)
eret list

* Abbreviate catvar option 

regby1 wage married, catv(collgrad)

* Richer categorical variable

tab grade
regby1 wage married, catvar(grade)

* Subsetting

tab industry
tab industry, nolabel
regby1 wage married if industry!=1, catvar(grade)

***************************************
** regby2
***************************************

** Skips regressions that cannot run
** Omits undesired output
** Adds if and in options

* Basic syntax

regby2 wage married, catvar(collgrad)
eret list

* Subsetting

tab industry
tab industry, nolabel
regby2 wage married if industry!=1, catvar(collgrad)

* Richer categorical variable

tab grade
regby2 wage married, catvar(grade)

***************************************
** regby3
***************************************

** Notifies user when the regression fails in a certain category
** Cleans output
** Adds error checking
** Allows for additional covariates
** Postestimation

* Basic syntax

regby3 wage married, catvar(grade)

* Subsetting

regby3 wage married if south==0, catvar(grade)

* Display summary statistics

regby3 wage married hours tenure, catvar(grade) summyx
mat coefs = e(b)
mat Var = e(V)

* Post-estimation testing

lincom cat_9-cat_8
di as text "Coefficient = " as result coefs[1,7] - coefs[1,6]
di as text "Std. err. = " as result sqrt(Var[6,6] + Var[7,7])
di as text "t-statistic = " as result round((coefs[1,7] - coefs[1,6]) / sqrt(Var[7,7] + Var[6,6]),.01)

regby3 wage married hours tenure, catvar(grade)
test cat_6 cat_7 cat_8


********************************************************************************
** Other examples (not included in the talk)
********************************************************************************

********************************************************************************
** meanvars
********************************************************************************

/* Program to calculate the means of a list of variables */

***************************************
** meanvars1
***************************************

* Basic syntax

meanvars1 age collgrad hours
ret list

matlist r(M)

***************************************
** meanvars2
***************************************

* Performs calculations using Mata
* Displays results

meanvars2 age collgrad hours
ret list

***************************************
** meanvars3
***************************************

* Performs calculations using external Mata function
* Adds data subsetting (if, in)

meanvars3 age collgrad hours
ret list

tab south
tab south, nolabel

meanvars3 age collgrad hours if south==0
ret list
