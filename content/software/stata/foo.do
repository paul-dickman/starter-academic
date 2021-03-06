
// read data from web; exclude unknown stage (stage==0)
use https://pauldickman.com/data/melanoma.dta if stage>0, clear

// outcome is cause-specific survival (status==1 is death due to melanoma) 
stset surv_mm, fail(status==1) scale(12) exit(time 120)

// create dummy variables for modelling
generate male=(sex==1)
quietly tab agegrp, generate(agegrp)

sort agegrp
stpm2 male year8594 agegrp2 agegrp3 agegrp4, scale(h) df(5) eform

generate t5=5 in 1

//sort yydx
standsurv, at1(male 0) at2(male 1) timevar(t5)

list _at1 _at2 in 1
  
  



	  
