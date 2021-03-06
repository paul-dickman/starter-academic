use http://pauldickman.com/data/colon, clear
drop agegrp

stset exit, origin(dx) fail(status==1 2) scale(365.24) id(id)

// Add weights from ICSS standard population 1 
egen agegr = cut(age), at(0 45(10)75 100) icodes
label define agegr 0 "15-44" 1 "45-54" 2 "55-64" 3 "65-74" 4 "75+" 
label values agegr agegr
recode agegr 0=0.07 1=0.12 2=0.23 3=0.29 4=0.29, generate(ICSSwt)

tab agegr

// Crude (unstandardised) net survival 
strs using http://pauldickman.com/data/popmort, ///
  mergeby(_year sex _age) breaks(0(1)10) noshow pohar

// Age-standardised net survival (traditional direct standardisation)
strs using http://pauldickman.com/data/popmort [iw=ICSSwt], ///
  mergeby(_year sex _age) breaks(0(1)10) noshow pohar ///
  standstrata(agegr) 

// Age-standardised net survival using Brenner weights 
strs using http://pauldickman.com/data/popmort [iw=ICSSwt], ///
  mergeby(_year sex _age) breaks(0(1)10) noshow pohar ///
  standstrata(agegr) brenner
  
 