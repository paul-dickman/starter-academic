
//==================//
// EXERCISE 150
// REVISED MAY 2015
//==================//

// Adjusted survival curves
clear 

// (a) Obtained the KM estimates by treatment group
use rott2
stset rf, f(rfi==1) scale(12) exit(time 120)
sts *graph, by(hormon)
*graph export "../eps/q150a.pdf", replace		
sts gen S_km = s, by(hormon)

// (b) Fit PH model
stpm2 hormon, scale(hazard) df(3) eform
predict s,s

// (c) Compare survival curves
twoway	(line S_km _t if hormon == 0, sort lcolor(black) lpattern(dash) connect(stepstair)) ///
		(line S_km _t if hormon == 1, sort lcolor(red)  lpattern(dash) connect(stepstair)) ///
		(line s _t if hormon==0,sort lcolor(black) lwidth(thick)) ///
		(line s _t if hormon==1, sort lcolor(red) lwidth(thick)) ///
		, xtitle("Years from surgery") ///
		ytitle("S(t)") ///
		legend(order(3 "No hormonal therapy" 4 "hormonal therapy") ring(0) pos(1) cols(1)) ///
		caption("Dashed lines show KM estimates")
*graph export "../eps/q150c.pdf", replace		
		
// (d) incorporate enodes in the model
stpm2 hormon enodes, scale(hazard) df(3) eform 

// (e) generate splines for age and introduce in model
rcsgen age, df(3) gen(agercs) orthog 
stpm2 hormon i.size enodes agercs*, scale(hazard) df(3) eform 

// (f) obtain predicted survival at 2 and 5 years
gen t1 = 1
gen t5 = 5
predict s1, surv timevar(t1)
predict s5, surv timevar(t5)
hist s1, name(hist_1yr, replace) xlabel(0(0.1)1)
*graph export "../eps/q150f_1.pdf", replace
hist s5, name(hist_5yr, replace)xlabel(0(0.1)1)
*graph export "../eps/q150f_2.pdf", replace		

// (g) Predict prognostic index and plot survival functions
predict xb, xbnobaseline
stpm2 xb, scale(h) df(3)
forvalues i = 10(10)90 {
	centile xb, centile(`i')
	predict s_xb`i', surv at(xb `r(c_1)')
}
twoway	(line s_xb?? _t, sort lcolor(black ..)) ///
		, legend(off) ///
		ylabel(0(0.2)1, angle(h)) ///
		xtitle("Years from surgery") ///
		ytitle("S(t)") ///
		text(0.8 8 "10th centile") ///
		text(0.1 8 "90th centile") 
*graph export "../eps/q150g.pdf", replace		
		
// (h) Obtain survival function for whole study population. 
stpm2 hormon i.size enodes agercs*, scale(hazard) df(3) eform 
range timevar 0 10 100
predict s_mean, meansurv timevar(timevar) ci
twoway 	(rarea s_mean_lci s_mean_uci timevar, sort pstyle(ci)) ///
		(line s_mean timevar, sort) ///
		, xtitle("Years from surgery") ///
		ytitle("S(t)") ///
		legend(off)
*graph export "../eps/q150h.pdf", replace		
		
// (i) Obtain the adjusted survival curves by hormonal therapy status
//     standardising over the covariate pattern of the whole study population 		
predict s_h0, meansurv at(hormon 0) timevar(timevar) ci
predict s_h1, meansurv at(hormon 1) timevar(timevar) ci
twoway 	(line s_h0 timevar, sort) ///
		(line s_h1 timevar, sort) ///
		, xtitle("Years from surgery") ///
		ytitle("S(t)") ///
		ylabel(0(.2)1,angle(h)) ///
		legend(order(1 "No hormonal therapy" 2 "hormonal therapy") ring(0) pos(1) cols(1)) ///
		name(adj1, replace)
*graph export "../eps/q150i.pdf", replace		

// (j) Obtain the adjusted survival curves by hormonal therapy status
//     standardising over the covariate pattern of those not on hormonal therapy
predict s_h0b if hormon==0, meansurv at(hormon 0) timevar(timevar) ci
predict s_h1b if hormon==0, meansurv at(hormon 1) timevar(timevar) ci
twoway 	(line s_h0b timevar, sort) ///
		(line s_h1b timevar, sort) ///
		, xtitle("Years from surgery") ///
		ytitle("S(t)") ///
		ylabel(0(.2)1,angle(h)) ///
		legend(order(1 "No hormonal therapy" 2 "hormonal therapy") ring(0) pos(1) cols(1)) ///
		name(adj2, replace)
*graph export "../eps/q150j.pdf", replace		

// (k) Obtain the adjusted survival curves by hormonal therapy status
//     standardising over the covariate pattern of those  on hormonal therapy
predict s_h0c if hormon==1, meansurv at(hormon 0) timevar(timevar) ci
predict s_h1c if hormon==1, meansurv at(hormon 1) timevar(timevar) ci
twoway 	(line s_h0c timevar, sort) ///
		(line s_h1c timevar, sort) ///
		, xtitle("Years from surgery") ///
		ytitle("S(t)") ///
		ylabel(0(.2)1,angle(h)) ///
		legend(order(1 "No hormonal therapy" 2 "hormonal therapy") ring(0) pos(1) cols(1)) ///
		name(adj3, replace)
*graph export "../eps/q150k.pdf", replace		

// (l) Calculate the difference in standardised survival curves
// note this may take a while
predictnl sdiff = predict(meansurv at(hormon 0) timevar(timevar)) - ///
				predict(meansurv at(hormon 1) timevar(timevar)) ///
				, ci(sdiff_lci sdiff_uci)
						
twoway	(rarea sdiff_lci sdiff_uci timevar, sort pstyle(ci)) ///
		(line sdiff timevar, sort) ///
		, xtitle("Years from surgery") ///
		ytitle("Difference in S(t)") ///
		legend(off)
*graph export "../eps/q150l.pdf", replace		
		
