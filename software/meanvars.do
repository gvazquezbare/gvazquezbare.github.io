********************************************************************************
** Writing Stata Packages
** Gonzalo Vazquez-Bare - UC Santa Barbara
********************************************************************************

capture program drop meanvars1
program define meanvars1, rclass

	syntax varlist (min=1)
	
	local nvars: word count `varlist'
	
	matrix M = J(1,`nvars',.)
	
	local count = 1
	foreach var of varlist `varlist'{
		sum `var', meanonly
		mat M[1,`count'] = r(mean)
		local ++count
	}
	
	return matrix M = M
	return scalar k = `nvars'
	
end

********************************************************************************

capture program drop meanvars2
program define meanvars2, rclass

	syntax varlist (min=1)
	
	mata: st_view(X=.,.,"`varlist'")
	mata: means = colsum(X):/colnonmissing(X)
	mata: st_matrix("M",means)
	
	matlist M
	
	local k = colsof(M)
	
	di _newline as text "Number of variables = " as result `k'
	
	return matrix M = M
	return scalar k = `k'
	
end

********************************************************************************

capture program drop meanvars3
program define meanvars3, rclass

	syntax varlist (min=1) [if] [in]
	
	marksample touse
	
	mata: meanvars_fun("`varlist'")
	matlist M
	di _newline as text "Number of variables = " as result r(k)
	
	return scalar k = r(k)
	return matrix M = M
	
end
