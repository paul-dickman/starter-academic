/***************************************************************************
This code available at:
http://pauldickman.com/software/stnet/stnet.do

Illustrates basic use of -stnet-

Reproduces some of the analyses shown in:
E. Coviello, P. W. Dickman, K. Seppä, and A. Pokhrel,
Estimating net survival using a life-table approach.
Stata Journal, 2015.

I recommend you download popmort.dta and modify the code below
so that -stnet- reads the local version. The code runs, but very
slowly as -stnet- reads the popmort file multiple times and must
download it from the net each time.

Paul Dickman, July 2019
***************************************************************************/
use https://pauldickman.com/data/colon_net, clear

stset exit, origin(dx) f(status) scale(365.24)

// Single life table for all patients
stnet using http://pauldickman.com/data/popmort ///
  if yydx>=1980 & yydx<1985, mergeby(_year sex _age) /// 
  breaks(0(.083333333)10) diagdate(dx) birthdate(birthdate) ///
  list(n d cns locns upcns secns) listyearly

// Add weights using ICSS 1 
egen agegr = cut(age), at(0 45(10)75 100) icodes
recode agegr 0=0.07 1=0.12 2=0.23 3=0.29 4=0.29, generate(standw)

// Age-standardised net survival
stnet using http://pauldickman.com/data/popmort ///
  if yydx>=1980 & yydx<1985 [iw=standw],  ///
  mergeby(_year sex _age) breaks(0(.083333333)10)  ///
  diagdate(dx) birthdate(birthdate) noshow  ///
  standstrata(agegr) listyearly by(sex) savstand(agestand_sex_NS,replace)

// Graph of age-standardised net survival
use agestand_sex_NS, clear
  twoway (rarea locns upcns end, col(gs10)) ///
  (line cns end, lc(black) lw(medthick) lp(l)),  ///
  by(sex, legend(off)) xlabel(0(2)10) xtitle("Years from diagnosis")  ///
  ytitle("Net survival") ylabel(0(.2)1, format(%2.1f))
