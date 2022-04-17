********************************************************************************
** Writing Stata Packages
** Gonzalo Vazquez-Bare - UC Santa Barbara
********************************************************************************

capture program drop regby1
program define regby1, eclass
	
	syntax varlist (min=2 max=2), CATVar(string)
	
	* Define outcome variable and main regressor
	
	tokenize `varlist'
	local yvar `1'
	local xvar `2'
	
	* List of categories in catvar
	
	levelsof `catvar', local(cats)
	local ncats = r(r)
	
	* Define matrices to collect results
	
	mat coefs = J(1,`ncats',.)
	mat Var = J(`ncats',`ncats',0)
	
	* Perform calculations
	
	local count = 1
	foreach cat of local cats{
		reg `yvar' `xvar' if `catvar'==`cat'
		matrix coefs[1,`count'] = _b[`xvar']
		matrix Var[`count',`count'] = _se[`xvar']^2
		local ++count
	}
	
	* Return values
	
	ereturn clear
	ereturn matrix Var = Var
	ereturn matrix coefs = coefs
	
end

********************************************************************************

capture program drop regby2
program define regby2, eclass
	
	syntax varlist (min=2 max=2) [if] [in], CATvar(string)
	
	* Select subsample
	
	marksample touse
	
	* Define outcome variable and main regressor
	
	tokenize `varlist'
	local yvar `1'
	local xvar `2'
	
	* List of categories in catvar
	
	quietly levelsof `catvar' if `touse', local(cats)
	local ncats = r(r)	
	
	* Define matrices to collect results
	
	mat coefs = J(1,`ncats',.)
	mat Var = J(`ncats',`ncats',0)
	
	* Perform calculations
	
	local count = 1
	foreach cat of local cats{
		capture reg `yvar' `xvar' if `catvar'==`cat' & `touse'
		matrix coefs[1,`count'] = _b[`xvar']
		matrix Var[`count',`count'] = _se[`xvar']^2
		local ++count
	}
	
	* Display results
	
	matlist coefs
	matlist Var
	
	* Return values
	
	ereturn clear
	ereturn matrix Var = Var
	ereturn matrix coefs = coefs
	
end

********************************************************************************

capture program drop regby3
program define regby3, eclass
	
	syntax varlist (min=2) [if] [in], CATvar(string) [summyx]
	
	* Select subsample
	
	marksample touse
	
	* Define outcome variable and main regressor
	
	tokenize `varlist'
	local yvar `1'
	macro shift
	local xvar `1'
	macro shift
	local covs `*'
	
	* Error checking
	
	capture confirm numeric variable `yvar' `xvar'
	if _rc!=0{
		di as error "yvar and xvar have to be numeric"
		exit 198
	}
	
	* Summarize y and x if specified
	
	if "`summyx'"!=""{
	    sum `yvar' `xvar'
	}
	
	* List of categories in catvar
	
	qui levelsof `catvar' if `touse', local(cats)
	local ncats = r(r)	
	
	* Define matrices to collect results
	
	tempname b V
	matrix `b'= J(1,`ncats',.)
	matrix `V' = J(`ncats',`ncats',0)
	
	* Perform calculations
	
	local count = 1
	foreach cat of local cats{		
		capture reg `yvar' `xvar' `covs' if `catvar'==`cat' & `touse'

		if _rc!=0{
		    local failed "`failed' `cat'"
			matrix `b'[1,`count'] = 0
			matrix `V'[`count',`count'] = 0
		}
		else {
			matrix `b'[1,`count'] = _b[`xvar']
			matrix `V'[`count',`count'] = _se[`xvar']^2	
		}
		local colnames "`colnames' cat_`cat'"
		local ++count
	}
		
	mat colnames `b' = `colnames'
	mat rownames `V' = `colnames'
	mat colnames `V' = `colnames'
		
	* Display output
	
	mat Mdisp = (`b'',vecdiag(`V')')
	mat colnames Mdisp = coef var
	
	matlist Mdisp
	
	if "`failed'" != ""{
	    di _newline as error "Warning: regby could not run in the following categories:"
		di as error "`failed'"
	}
	
	* Return values
	
	ereturn post `b' `V'
	ereturn local failed = "`failed'"
	ereturn scalar ncats = `ncats'
	ereturn local cmd "regby3"
	
end