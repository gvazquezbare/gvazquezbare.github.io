********************************************************************************
** Writing Stata Packages
** Gonzalo Vazquez-Bare - UC Santa Barbara
********************************************************************************

capture mata: mata drop meanvars_fun()
mata:
void meanvars_fun(string scalar varnames)
{
	st_view(X=.,.,varnames,st_local("touse"))
	means = colsum(X):/colnonmissing(X)
	st_matrix("M",means)
	st_numscalar("r(k)",cols(X))

}
mata mosave meanvars_fun(), replace
end