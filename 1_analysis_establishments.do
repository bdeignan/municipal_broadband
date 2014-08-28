*Analysis of Business Establishments created by municipal broadband
*Using Ordinary Least Squares (OLS) and Difference-in-Differences Estimation

sort cbsa year

*Will use natural logarithmic transformation of establishments as outcome of interest
gen logestablishments=log(establishments)

*OLS regression with standard error corrected for heteroskedasticity aka "robust"
reg logestablishments network unrate whitepop workage realincome_pc ptaxratio energycost_state, robust

*Tell Stata that you have panel data of Core Based Statistical Areas over time (years)
xtset cbsa year
*Difference-in-differences regression, aka Two-way fixed effects model
xtreg logestablishments network i.year, fe robust
*Difference-in-differences regression with control variables
xtreg logestablishments network unrate whitepop workage realincome_pc ptaxratio energycost_state i.year, fe robust


/*Interesting to slice up data into 2 samples, Above and Below median level of real per capita income in 2010 */
sum realincome_pc if year==2010, detail
/*From summary statistics median level is $32565.50, so generate dummy variable that indicates if CBSA is in high
income or low income group (which doesn't change during sample) */
gen belowmed_inc=1 if realincome_pc<32565.5 & year==2010
* 'gsort' allows you to reverse sort by year
gsort cbsa -year
/* 'carryforward' command in next line carries the '1' in the column for 'belowmed_inc' for the year 2010 to the years
2009 all the way back to 1990, IF the cbsa does indeed have below median level of per capita income in 2010, otherwise
the cell is empty for a cbsa in 2010, which we fix with the last command in this block */
by cbsa: carryforward belowmed_inc, replace
sort cbsa year
by cbsa: carryforward belowmed_inc, replace
replace belowmed_inc=0 if belowmed_inc==.

*Difference-in-differences regression
xtreg logestablishments network unrate whitepop workage realincome_pc ptaxratio energycost_state i.year if belowmed_inc==0, fe robust
estimates store HighIncome
xtreg logestablishments network unrate whitepop workage realincome_pc ptaxratio energycost_state i.year if belowmed_inc==1, fe robust
estimates store LowIncome
/* Regression results show that richer half of CBSAs experience almost 4 percent increase in businesses
while poorer half of cities do not experience a statistically significant effect (beyond the 10 percent level) */


/* Since public networks are public works projects, they deploy slowly over time, taking many years to complete.
Therefore, interesting to examine the long-run treatment effects, so I generate new "treatment variables" which 
are multiple dummy variables for each of the two years since the networks have deployed, topcoded at 15 years, for 
more details and scholarly research which actually used this method, see Justin Wolfers' data and article "Did Unilateral
 Divorce Raise Divorce Rates? A Reconciliation and New Results"
data and .do files available here: http://users.nber.org/~jwolfers/data.php */

*So I sum up the original treatment dummy variableand recode it
by cbsa: gen network_years=sum(network)
recode network_years (0=-99) (1 2 =1) (3 4 =3) (5 6 =5) (7 8 =7) (9 10 =9) (11 12 =11) (13 14 =13) (15/35 =15)
*Recoding the variable marks CBSAs that did not deploy a network, and the years before deployment, equal "=99"

*Difference-in-differences with long-run treatment variables
xi i.network_years i.year
xtreg logestablishments _I* unrate whitepop workage realincome_pc ptaxratio energycost_state, fe robust
/*Note that reported treatment effect coefficients are relative to the omitted "network_years" dummy for -99
which means that the coefficients can be read as "effect in Year X to Y relative to not deploying a network" */
