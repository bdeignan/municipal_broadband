Municipal_Broadband
===================
Stata code (version 13.1) and data for economic analysis of municipal broadband, aka community broadband, which occurs when local government finances or builds (and sometimes runs) a broadband communications network for local residents and businesses. With this data, I examine fiber-to-the-premises networks' effects on attracting businesses and worker pay.

This repo contains the data (.dta), and some .do files which will crunch the numbers.

Main_Point
-------------------
The main point of my project is to perform regression analysis, particularly difference-in-differences estimation, to tease out the effect of municipal broadband. This means I treat the cities (or rather Core Based Statistical Areas) that deploy their own fiber networks as the "treatment" group and other cities as the "control" group, conditional on observable characteristics.

I have data on 818 cities over 23 years, and what the regression ends up doing is the following:
```
Imagine two cities, treated and control, t=1,0 respectively. 
Each city is observed before and after "treatment" occurs, d=1,2 respectively,
although only one city is treated (with a fiber network). 

So if you take the differences between the two groups over time,
you can tease out the effect of the network on some outcome of interest Y:

Treatment Effect = (E[Y(d=2)|t=1)-E[Y(d=2)|t=0)) - (E[Y(d=1)|t=1)-E[Y(d=1)|t=0))
```

The current project differs from this example in that it has 23 periods of observation and 80 treated cities. The analysis requires that the cities be similar in other regards, which is what conditioning on other observable characteristics does, e.g. level of income, demographics, etc. Also, municipal broadband occurs in small to mid-size cities, so my data only includes CBSAs with around 600,000 people or less. Therefore, I can't extrapolate the measured effect to say, New York City. For more details on this approach, and modern econometrics in general, check out "Mostly Harmless Econometrics," an invaluable book from economists Angrist and Pischke (http://press.princeton.edu/titles/8769.html).

Guide to files
-------------------
"communitybroadband.dta" contains the data
"summarystats.do" has commands for summary statistics. 

Then you can run regression analysis in this order: "analysis_establishments.do" then "analysis_compensation.do" because the analysis of business establishments generates some indicator variables you may need for the compensation .do file.

User-written programs
---------------------
Type the following commands in Stata to install the user-written programs used for my project:
```
ssc install estout
ssc install carryforward
ssc install coefplot
ssc install outreg2
```
