*Analysis of Compensation created by municipal broadband
*Using Ordinary Least Squares (OLS) and Difference-in-Differences Estimation

/* Very Similar to Analysis of establishments, will use natural logarithmic transformations of
outcomes of interest instead of the raw figures 
Main finding is that public network deployment DECREASES worker pay (proxied by Compensation per Job) */

sort cbsa year
*OLS regression analysis
reg logrealcomp_pj network unrate edu_bachelors whitepop workage, r
*Create table to store results, and you can add to it
*Note: after "using" in next command, must specify your own file
outreg2 network unrate edu_bachelors whitepop workage using /* C:\directory\table */, word replace addtext(CBSA FE, No, Year FE, No) ///
	title(The Effect of Community Broadband Deployment on Compensation)

	
*Difference-in-differences regression, aka Two-way fixed effects model
xtset cbsa year
xtreg logrealcomp_pj network i.year, fe r
outreg2 network using /* C:\directory\table */, word append addtext(CBSA FE, Yes, Year FE, Yes)
*Difference-in-differences regression with control variables
xtreg logrealcomp_pj network unrate edu_bachelors whitepop workage i.year, fe r
outreg2 network unrate edu_bachelors whitepop workage using /* C:\directory\table */, word append addtext(CBSA FE, Yes, Year FE, Yes)


/*Interesting to slice up data into 4 subsamples, the highest and lowest quartiles of income
and educational attainment in 2010 (creates 4 groups, or subsamples of CBSAs to run regressions on) */
sum realincome_pc edu_bachelors if year==2010, detail

/*From summary statistics, highest income quartile>=$36464, lowest<=$29770
Highest educational attainment quartile>=23.84% of people aged 25 or older with a bachelor's degree or higher, lowest<=14.8%
Now: this is how I generated dummary variables to specify in regression via "if" statements, but the dummy variables are already 
included in the dataset */

*High and low income indicators
gen high_inc=1 if realincome_pc>=36464 & year==2010
gsort cbsa -year
by cbsa: carryforward high_inc, replace
sort cbsa year
by cbsa: carryforward high_inc, replace
replace high_inc=0 if high_inc==.
gen low_inc=1 if realincome_pc<=29770 & year==2010
gsort cbsa -year
by cbsa: carryforward low_inc, replace
sort cbsa year
by cbsa: carryforward low_inc, replace
replace low_inc=0 if low_inc==.

*High and low education indicators
gen high_edu=1 if realincome_pc>=23.84 & year==2010
gsort cbsa -year
by cbsa: carryforward high_edu, replace
sort cbsa year
by cbsa: carryforward high_edu, replace
replace high_edu=0 if high_edu==.
gen low_edu=1 if realincome_pc<=14.8 & year==2010
gsort cbsa -year
by cbsa: carryforward low_edu, replace
sort cbsa year
by cbsa: carryforward low_edu, replace
replace low_edu=0 if low_edu==.


*Difference-in-differences on the 4 subsamples
xtreg logrealcomp_pj network unrate edu_bachelors whitepop workage i.year if high_inc==1, fe r
estimates store Income
outreg2 network unrate edu_bachelors whitepop workage using /* C:\directory\table */, word append addtext(CBSA FE, Yes, Year FE, Yes)
xtreg logrealcomp_pj network unrate edu_bachelors whitepop workage i.year if low_inc==1, fe r
estimates store Income2
outreg2 network unrate edu_bachelors whitepop workage using /* C:\directory\table */, word append addtext(CBSA FE, Yes, Year FE, Yes)
xtreg logrealcomp_pj network unrate edu_bachelors whitepop workage i.year if high_edu==1, fe r
estimates store Education
outreg2 network unrate edu_bachelors whitepop workage using /* C:\directory\table */, word append addtext(CBSA FE, Yes, Year FE, Yes)
xtreg logrealcomp_pj network unrate edu_bachelors whitepop workage i.year if low_edu==1, fe r
estimates store Education2
outreg2 network unrate edu_bachelors whitepop workage using /* C:\directory\table */, word append addtext(CBSA FE, Yes, Year FE, Yes)


*You can plot the treatment effect across the 4 groups to visualize how the effect varies
#delimit ;
	coefplot Income  Income2 || Education Education2, 
	yline(0) vertical keep(network) rename(mnet="") swap scheme(sj) byopts(row(1))
	xtitle({it:Estimated Treatment Effects, Lines show 95 percent confidence interval for each estimate}, size(small)) nolabels
	legend(label(2 "Highest Quartile") label(4 "Lowest Quartile"))
	;
/* Note that you should highlight and execute the entire command when you change delimiter to ";" unless you execute entire .do file
Coefficient plot shows that compensation per job is negatively affected by municipal broadband especially in richer and highly education CBSAs */

/* Return the delimiter to a carriage return instead of semi-colon */
#delimit cr


*You can also do the long-run analysis as in the analysis of establishments
*Difference-in-differences with long-run treatment variables -- see establishments .do file if you haven't created long-run dummy variables
xi i.network_years i.year
xtreg logrealcomp_pj _I* unrate edu_bachelors whitepop workage, fe robust
/*Note that reported treatment effect coefficients are relative to the omitted "network_years" dummy for -99
which means that the coefficients can be read as "effect in Year X to Y relative to not deploying a network" */

*Results show that negative treatment effect persists for around 8 years
