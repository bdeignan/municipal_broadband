*Economic Analysis of Municipal Broadband by Brian Deignan
*Code for Stata version 13.1

/* Introduction to project:
Pulled data (1990-2012) together from various government sources and Broadband Communites'
Municipal FTTP Network Census, here: http://www.bbpmag.com/Features/0513feature-MuniCensus.php
I mapped networks to Core Based Statistical Areas, 2013 geographical delineation used by Census */

*User-made Stata add-on packages, run the following code to download:
ssc install estout
ssc install carryforward
ssc install coefplot
/* ssc install outreg2, not used in these files but useful for creating and appending regression results to a single
table */

*Read data notes in .dta file
notes list

*Summary Statistics
*to improve readability of code -- change command delimiter to ";", then back to carriage return
#delimit ;
tabstat network establishments realcomp_pj realcomp_pj_info realcomp_pj_finance realcomp_pj_health 
	realcomp_pj_manufact realcomp_pj_food realcomp_pj_locgovt employment employment_locgovt 
	employment_finance employment_info employment_health whitepop blackpop realincome_pj workage 
	unrate edu_bachelors poverty_state energycost_state edu_bachelors_state ptaxratio itaxratio,
	stat(min max mean sd n) column(statistics) save
	;

*export summary statistics to Excel file if you want
estout r(StatTotal, t) using /*C:\directory\filename.xls*/, replace;

*Examine outcomes of interest by CBSAs with and without public networks in 2012
sort mnet year;
by mnet: sum establishments realcomp_pj realcomp_pj_info realcomp_pj_finance realcomp_pj_health 
	realcomp_pj_manufact realcomp_pj_food realcomp_pj_locgovt employment employment_locgovt 
	employment_finance employment_info employment_health if year==2012;
	
/*View the CBSAs that deployed their own networks and the initial deployment year
Taking the difference of the dummy treatment variable creates indicator that equals "1"
in the year a CBSA deployed a network, if it did deploy */
gen dnetwork=D.network;
list cbsaname cbsa year if dnetwork==1;

*return delimiter to carriage return
#delimit cr
