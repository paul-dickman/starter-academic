*! version 1.4.3.0 13May2020
*! See http://pauldickman.com/software/strs/strs/ for update history and documentation
*
program define strs
	version 9
	st_is 2 analysis
	syntax [if] [in] using/ [iw/], BReaks(numlist ascending) Mergeby(namelist) ///
                  [ BY(varlist) DIAGAGE(varname numeric) DIAGYEAR(varname numeric) ATTAGE(name) ATTYEAR(name) ///
                    SURVprob(name) MAXAGE(int 99) CALYEar POHAR HT POTfu(varname numeric) EDerer1 CILOG CUMINC ///
		            STANDstrata(varname numeric) BRENNER INDWEight(varname numeric) LIst(namelist) KEEP(namelist) ///
					Format(string) noTABles noSHow noCONFIRM /// 
                    SAVE SAVINd(string asis) SAVGRoup(string asis) SAVSTand(string asis) Level(integer $S_level) * ]
/* Relevant sample */
	marksample touse
	if "`diagage'" == "" {
		capture confirm var age
		local v = _rc
		capture unab okvar : age
		if `v'!=0 | "`okvar'" != "age" {
			display as error "{p}Variable age not found. Your dataset must contain a variable"
			display as error "containing age at diagnosis. Default name for this variable is age."
			display as error "An alternative name can be specified using the diagage() option.{p_end}"
			exit 198
		}   
		local diagage age
	}
	if "`diagyear'" == "" {
		capture confirm var yydx
		local v = _rc
		capture unab okvar : yydx
		if `v'!=0 | "`okvar'" != "yydx" {
			display as error "{p}Variable yydx not found. Your dataset must contain a variable"
			display as error "containing year of diagnosis. Default name for this variable is yydx."
			display as error "An alternative name can be specified using the diagyear() option.{p_end}"
			exit 198
		}   
		local diagyear yydx
	}
	markout `touse' `diagage' `diagyear' `by' `standstrata', strok

	if `"`_dta[st_id]'"' == "" {
		display as error /*
		*/ "strs requires that you have previously stset an id() variable"
		exit 198
	}
	capture bysort `_dta[st_id]' : assert _N==1
	if _rc {
		display as error /*
		*/ "strs requires that the data are stset with only one observation per individual"
		exit 198
	}   

/* confirm existence of popmort file (updated 1.4.3.0) */
/* need to allow users to specify popmort.new.dta as popmort.new */
/* confirm command always returns false for web files */
if "`confirm'" == "" {	
	local us = regexr("`using'",".dta","")
	if "`using'" == "`us'"  local using = `"`using'"' + ".dta"
	gettoken web : using, parse("://")
  if ("`web'" != "http") & ("`web'" != "https") confirm file `"`using'"'
}

/* confirm mergeby() variables uniquely define the records in the using file (updated 1.4.3.0) */
	capture isid `mergeby' using `"`using'"'
	if _rc & ("`web'" != "http") & ("`web'" != "https") {
		display as error "`mergeby' do not uniquely specify the records in the using file"
			exit 198
	}
/* New : weights */
	if "`exp'" != "" {
		capture confirm numeric var `exp'
		if _rc {
			display as error "iweight error: weight variable must be numeric"
			exit 198
		}
		else	unab wei: `exp', max(1) name(iweight uncorrected)
		capture assert `wei' > 0
		if _rc {
			display as error "iweight error: negative weights not allowed"
			exit 198
		}
		capture assert `wei' < 1
		if _rc {
			display as error "iweight error: weights must be less than 1"
			exit 198
		}
		if "`standstrata'" == "" {
			display as error "{p 0 4 2}iweight error: must also specify standstrata(varname) to " 
			display as error "standardize survival estimates when specifying weights.{p_end}" 
			exit 198
		}
	}

/*Check standard strata var and weights */
	if "`standstrata'" != ""{
		if "`exp'" =="" {
			display as error "{p 0 4 2}must also specify weights (using iweight=varname) to standardize"
			display as error "survival estimates across strata of `standstrata'{p_end}"
			exit 198
		}
		capture bysort `by' `standstrata' : assert `wei' == `wei'[_n-1] if _n!=1
		if _rc {
			display as error "iweight error: weights are not constant within each level of `standstrata'"
			exit 198
		}
	}

/* New saving instruction */
	tempfile group_est
	if "`options'"!="" & "`options'"!="save(replace)"{
		local options = subinword("`options'", "save(replace)","",.)
		display as error "option `options' not allowed"
		exit 198
	}
	if "`options'" !=""	local save save
	if "`save'" != "" {
		if "`options'"=="" {
			capture {
				confirm new file individ.dta
				confirm new file grouped.dta
			}
			if _rc {
				display as error "file individ.dta or grouped.dta already exists." _n ///
					  "Use save(replace) to replace these files"
				exit 602
			}
		}
		local indfile individ
		local grfile grouped
		local outrind replace
		local outrgro replace
	}
	// savind(filename[, replace]) 
	if "`savind'" != "" {
		gettoken indfile savind : savind, parse(",")
		gettoken comma savind : savind, parse(",") 
		if `"`comma'"' == "," { 
			gettoken outrind savind : savind, parse(" ,")
			gettoken comma savind : savind, parse(" ,")
			if `"`outrind'"' != "replace" | `"`comma'"'!="" { 
				display as error "option savind() invalid"
			exit 198
			}
		}
		else if `"`comma'"' != "" {
			display as error "option savind() invalid"
			exit 198
		}
		else 	confirm new file `"`indfile'.dta"'
	}
	// savgroup(filename[, replace]) 
	if "`savgroup'" != "" {
		gettoken grfile savgroup : savgroup, parse(",")
		gettoken comma savgroup : savgroup, parse(",") 
		if `"`comma'"' == "," { 
			gettoken outrgro savgroup : savgroup, parse(" ,")
			gettoken comma savgroup : savgroup, parse(" ,")
			if `"`outrgro'"' != "replace" | `"`comma'"'!="" { 
				display as error "option savgroup() invalid"
			exit 198
			}
		}
		else if `"`comma'"' != "" {
			display as error "option savgroup() invalid"
			exit 198
		}
		else 	confirm new file `"`grfile'.dta"'
	}
	// savstand(filename[, replace]) 
	if "`savstand'" != "" {
		gettoken standfile savstand : savstand, parse(",")
		gettoken comma savstand : savstand, parse(",") 
		if `"`comma'"' == "," { 
			gettoken outrsta savstand : savstand, parse(" ,")
			gettoken comma savstand : savstand, parse(" ,")
			if `"`outrsta'"' != "replace" | `"`comma'"'!="" { 
				display as error "option savstand() invalid"
			exit 198
			}
		}
		else if `"`comma'"' != "" {
			display as error "option savstand() invalid"
			exit 198
		}
		else 	confirm new file `"`standfile'.dta"'
	}

/* New in 1.2.8: variables to keep in individ data file */
	if "`keep'"!="" {
		if "`save'"=="" & "`indfile'"=="" {
			display as error "option save or savind() required when keep() is specified."
			exit 198
		}
		foreach name of local keep {
			capture confirm var `name'
			if _rc    display as error "WARNING: `name' invalid or ambiguous in keep option" 
			else	  unab ilist: `name'
			local klist "`klist' `ilist'"
		}
		local klist : list uniq klist
	}

/* Check that format is valid */
	if "`format'" == "" local format %6.4f
	if "`format'" != "" {
		if index("`format'",",") local format = subinstr("`format'", "," , "." , 1) /* european numeric format */
		local fmt = substr("`format'",index("`format'",".")-1,3) 
		capture {
			assert substr("`format'",1,1)=="%" & substr("`format'",2,1)!="d" ///
				& substr("`format'",2,1)!="t" & index("`format'","s")==0
			confirm number `fmt'
		}
		if _rc {
			display as error "invalid format. format has been set to default %6.4f"
			local format %6.4f
		}
	}

	if "`attage'"=="" {
		capture confirm new var _age
		if _rc {
		display as error "The variable _age already exists in the patient data file." _n ///
		        "strs creates a a variable containing attained age; the default name is _age. "  _n ///
				"As such, _age cannot exist in the patient data file but *must* exist in the `using' file. " _n ///
				"Note that this variable contains attained age (age during follow-up)" ///
				" and is not the same as age at diagnosis." _n ///
				"It is used by strs to account for the fact that expected survival depends on attained age." _n ///
				"The default name for this new variable is _age, but an alternative can be specified using the attage() option" 
			exit _rc
		}   
		local attage _age
	}
	else {
		capture confirm new variable `attage'
		if _rc {
			display as error "The variable `attage' (specified in the attage option) already exists" ///
       			" in the patient data file." _n ///
      			"This variable cannot exist in the patient data file but must exist in the `using' file."
			exit _rc
		}
	}
	if "`attyear'"=="" {
		capture confirm new var _year
		if _rc {
		display as error "The variable _year already exists in the patient data file." _n ///
		        "strs creates a variable containing attained year; the default name is _year. "  _n ///
				"As such, _year cannot exist in the patient data file but *must* exist in the `using' file. " _n ///
				"Note that this variable contains attained year (year during follow-up)" ///
				" and is not the same as year of diagnosis." _n ///
				"It is used by strs to account for the fact that expected survival depends on attained year." _n ///
				"The default name for this new variable is _year, but an alternative can be specified using the attyear() option" 
			exit _rc
		}   
		local attyear _year
	}
	else {
		capture confirm new variable `attyear'
		if _rc {
			display as error "The variable `attyear' (specified in the attyear option) already exists" ///
      			" in the patient data file." _n ///
      			"This variable cannot exist in the patient data file but must exist in the `using' file."
			exit _rc
		}
	}
	local inmerby = subinword("`mergeby'","`attage'","",1)
	if "`inmerby'" == "`mergeby'"{			// mergeby does not contain a suitable attained age variable 
		display as error "Variable specifying attained age must be specified in mergeby option."
		display as error "It cannot exist in the patient data file."
			exit 198
	}
	local ininmerby = subinword("`inmerby'","`attyear'","",1)
	if "`ininmerby'" == "`inmerby'"{			// mergeby does not contain a suitable attained year variable 
		display as error "{p}Variable specifying attained year must be specified in mergeby option."
		display as error "It cannot exist in the patient data file.{p_end}"
			exit 198
	}
	if "`ininmerby'" ~= "" {
		foreach name of local ininmerby {
			capture confirm variable `name'
			if _rc	{
      				display as error "mergeby option incorrectly specified." _n ///
        			"`name' must exist in the patient data file."
      				exit _rc
			}
		}
/* New in 1.2.8: missing values not allowed for variables specified in mergeby option */
		quietly count if `touse'
		local nuse = `r(N)'
		markout `touse' `ininmerby', strok
		quietly count if `touse'
		if `nuse' > `r(N)' {
			display as error "Missing values found in variables specified in mergeby() option." 
			exit 198
		}
	}
	if "`survprob'"=="" {
		capture confirm new var prob
		if _rc {
			display as error "You must specify a variable in the `using' file which" ///
				" contains the general population survival probabilities." _n ///
				"This variable cannot exist in the patient data file, but must exist in" ///
				" the `using' file."
			exit _rc
		}   
		local survprob prob
	}
	else {
		capture confirm new variable `survprob'
		if _rc {
			display as error "The variable `survprob' (specified in the survprob option) already exists" ///
      			" in the patient data file." _n ///
      			"This variable cannot exist in the patient data file but must exist in the `using' file."
			exit _rc
		}
	}

/* Break list must start from 0 */
 	local i = word("`breaks'",1)
 	if `i' != 0 {
 		display as error "The lifetable intervals in the breaks option must start from 0"
 		exit 198
 	}
/* If there are multiple numlists the interval between them must be at least 1 day */
	tokenize `breaks'    
	while "`2'" != "" {
      		local diff = `2' - `1'
		if `diff' < .00274  local breaks : list breaks - 1
      		mac shift
      	}
/*	New in 1.2.8: Add a small quantity to exit times on interval boundaries */
	tokenize `breaks'    
	while "`2'" != "" {
		quietly replace _t = _t + 0.000001 if float(_t) == float(`2')
      		mac shift
      	}

	if "`brenner'" != ""{
		if "`standstrata'" == "" {
			display as error "standstrata(varname) must also be specified when using brenner option"
			exit 198
		}
		if "`exp'" == "" {
			display as error "[iweight=varname] must also be specified when using brenner option"
			exit 198
		}
		if "`ederer1'" != "" {
			display as error "Brenner adjustment not allowed for Ederer I method"
			exit 198
		}
		if "`cuminc'" != "" {
			display as error "Brenner adjustment not allowed for estimates of the cumulative probabilities of death"
			exit 198
		}
		*Check sum of the weights = 1 
		if "`by'"!="" local byby "by `by' : "
		tempvar chkbrw
		quietly bysort `by' `standstrata' : generate `chkbrw' = `wei' if _n==1
		quietly `byby' replace `chkbrw' = sum(`chkbrw')
		capture `byby' assert  round(`chkbrw'[_N],0.01)==1
		if _rc {
			display as error "Using the Brenner adjustment the sum of weigths in the standard population must sum to 1"
			exit 198
		}
	}

	if "`indweight'" != ""{
		if "`standstrata'" != "" | "`brenner'" != "" {
				display as error _n "standstrata or brenner option cannot be specified if you use individual weights"
			exit 198
		}
		if "`potfu'" != "" {
				display as error _n "Survival estimates according to Hakulinen method are not computed if you use individual weights"
			exit 198
		}
		tempvar wei
	}

    if `level'<50 | `level'>99 {
		di in red "level() invalid"
		exit 198
	}
	local level = invnorm((1-`level'/100)/2 + `level'/100)

/* In the case of late entry pmethod is 2 */
	local pmethod =1
	capture assert _t0==0 if _st==1
	if _rc local pmethod = 2 
	if _rc local ht  // hazard transformed is the default method in case of late entry 

/* ht forces strs to use the hazard transformed approach. */
	if `pmethod'== 1 {
		if "`ht'"!="" 	local pmethod = 2 
		if "`ht'"!="" & "`ederer1'" != "" {
			di in red "Ederer I method for expected survival cannot be used when hazard transformed approach is used."
		exit 184
		}
	}

/* Ederer I method with late entry */
	if "`ederer1'" != "" & `pmethod'==2 {
		di in red "Late entry detected. Ederer I method for expected survival cannot be used."
		exit 184
	}
	
/* Allowed Brenner weights in case of Pohar Perme method
	if "`pohar'" != "" & "`brenner'"!="" {
		di in red "brenner and pohar option cannot be both specified."
		exit 184
	}
*/	

	if "`pohar'" != "" & "`calyear'"!="" & `pmethod'==2 {
		di in red "calyear and pohar option cannot be both specified when late entry is detected on the data or ht option is specified."
		exit 184
	}

/* Timescale of potfu must match that of origin */
	if "`potfu'" != "" {
	        capture assert "`_dta[st_orig]'" != "" 
	        if _rc {
	           display as error ///
        	   "To compute Hakulinen estimate strs requires that you have previously stset the origin option. " _n ///
                   " `potfu' must be in the same time scale as `_dta[st_bt]'. See help file for further details."  
                exit 198
        	}   
	}
    st_show `show'
	tempvar hakuse N d_sq
	generate byte `hakuse'=`touse'
	quietly replace `touse' = 0 if _st==0
	preserve

	if `pmethod'==1 {
		display as res _n "No late entry detected - p is estimated using the actuarial method"
		quietly {
/* Brenner weights generated as the ratio between relative proportion of patients in the standard population and in the study population */
			if "`brenner'"!="" {
				if "`by'" != ""		bysort `by' : generate long `N' = _N 
				else			quietly generate long `N' = _N 
				quietly bysort `by' `standstrata' : replace `wei' = `exp'/(_N/ `N')
				local hakstrata `standstrata'
				local standstrata	
			}
			if "`indweight'"!="" {
				generate `wei' = `indweight'
				count if `wei' >=.
				if r(N) > 0 	display as error _n "WARNING: `r(N)' records have missing individual weights. Estimates may be wrong" 
				count if `wei' == 0
				if r(N) > 0 	display as error _n "WARNING: `r(N)' records have 0 individual weights. Estimates may be wrong" 
				count if `wei' < 0
				if r(N) > 0 	display as error _n "WARNING: `r(N)' records have negative individual weights. Estimates may be wrong" 
			}

			/* Specify a list of variables to keep */
			capture confirm var `_dta[st_exexp]'
			if !_rc 	local exitvar "`_dta[st_exexp]'"
			capture confirm number `_dta[st_o]'
			if _rc {	
				keep `_dta[st_id]' `_dta[st_bt]' `_dta[st_bd]' `_dta[st_o]' `_dta[st_orexp]' `exitvar' ///
				   `ininmerby' `by' `diagage' `diagyear' _st _d _t _t0 `wei' `standstrata' `klist' `touse' `indweight'
			}
			else {
				keep `_dta[st_id]' `_dta[st_bt]' `_dta[st_bd]' `exitvar' ///
				   `ininmerby' `by' `diagage' `diagyear' _st _d _t _t0 `wei' `standstrata' `klist' `touse' `indweight'
			}
			keep if `touse'
			
/* By-Standstrata option */
			if "`by'"!="" |	"`standstrata'"!="" local byby "by `by' `standstrata' : "
			stsplit start,at("`breaks'") trim
			keep if _st==1
	/**********************************************************************************
	Generate attained age and attained year for the new records. These variables must
	be integers since we will merge with the popmort file by these variables.  
	**********************************************************************************/
			generate `attage'=int(`diagage'+start)
			replace `attage'=`maxage' if `attage'>`maxage'
			generate `attyear'=int(`diagyear'+start)
	/* Merge in the external rates */
			sort `mergeby'
			merge `mergeby' using "`using'", nokeep nolabel keep(`survprob')
		}
	/* Print a warning message if any records do not match with general population file and exit */
		quietly count if _merge==1
		if r(N) {
	/* Updated v1.2.9 20nov2009 by PWD. More informative error message */
			di in red "`r(N)' records fail to match with the population file (`using'.dta)."
			di in red "That is, there are combinations of the mergeby() variables that do not exist in `using'.dta."
			di in red _newline "This will occur, for example, when patients are followed-up beyond" 
			di in red "the last year for which population mortality data are available." 
			di in red _newline "Records that did not match have been written to _merge_error_.dta)."
			quietly keep if _merge==1
			quietly save _merge_error_.dta, replace
			exit 459 
		}
		quietly {
			keep if _merge==3 /* Keep only if observations exists in both files */
			drop _merge
			addend, br(`breaks')
			local maxti = r(llist)
			generate d=_d	 	/* Indicator for dead in the interval */
			if "`brenner'"!="" | "`indweight'"!=""	generate `d_sq' = _d * `wei'
			/* Generate a censoring indicator (not the same as 'not dead') */
			bysort `_dta[st_id]' (start) : generate w = (d[_N]==0 & _n==_N & (_t-_t0)!=(end-start))

		/* Expand also at the begin of each calendar year */
			if "`calyear'" != "" {
				levelsof `attyear', local(atyear)
				foreach i of local atyear {
					local d = date("1/1/`i'","mdy")
					local splyear "`splyear' `d'"
				}
				local scale "`_dta[st_s]'"
				streset , scale(1) 
				stsplit sply , at(`splyear') after(0)
				replace sply = int(sply/`scale' + 1960)
				replace `attyear' = sply if `attyear'<sply
				streset , scale(`scale')
				drop sply `survprob'
				sort `mergeby'
				merge `mergeby' using "`using'", nokeep nolabel keep(`survprob')
				generate y=(_t - _t0) 	/* Person-time at risk in the interval */
				generate d_star=-ln(`survprob')* y 
				generate p_star = `survprob'^(_t-_t0)
				bysort `_dta[st_id]' (_t0) : replace p_star = `survprob'^(end-_t0) if _n==_N
				if "`pohar'"!="" {
					bysort `_dta[st_id]' (_t0) : generate weipohar = 1/exp(sum(log(p_star)))
* Seppa and Pokhrel 25 jan 2013 - weights at mid-point of the interval
					replace weipohar = weipohar*sqrt(p_star)     		/* CHANGED */
					local weipohar weipohar
				}
				bysort `_dta[st_id]' start (_t0) : replace p_star = exp(sum(log(p_star)))
				local bycal : list by - ininmerby
				collapse (max) d w `wei' `weipohar' `attyear' (sum) y d_star (min) p_star `bycal' `standstrata', ///
					by(`_dta[st_id]' `diagage' `attage' `diagyear' `ininmerby' `klist' start end) 
			}
			if "`calyear'" == "" {
				generate y=(_t - _t0) 	/* Person-time at risk in the interval */
				generate d_star=-ln(`survprob')* y 
				generate p_star=`survprob'^(end-start) 
				drop `survprob'
			}

			if "`pohar'" != "" {
				if  "`calyear'"==""  {
					bysort `_dta[st_id]' (_t0) : generate weipohar = 1/exp(sum(log(p_star)))
* Seppa and Pokhrel 25 jan 2013
					replace weipohar = weipohar*sqrt(p_star)     		/* CHANGED */
				}
				generate lambda = -log(p_star) 
				generate spw1 = ((d+w)*lambda/2 + (1-d-w)*lambda)*weipohar
				generate spw2 = ((d+w)/2 + 1-d-w)*weipohar
				generate spwtt1 = lambda*weipohar
				generate d_poh  = d * weipohar
				generate d_pohsq = d * weipohar^2
				if "`brenner'"!="" | "`indweight'"!=""	replace d_pohsq = d_pohsq * `wei'				
				generate w_poh = w * weipohar
				drop lambda
				rename weipohar n_poh
				local poharest spw1 spw2 spwtt1 d_poh d_pohsq w_poh n_poh
			}
		}	
	}		
	if `pmethod'==2 {
		if "`ht'" =="" {
			display as result _newline "Late entry detected for at least one observation (probably because you are using a"
			display as result "period analysis). The conditional survival proportion (p) is estimated by transforming the"
			display as result "estimated cumulative hazard rather than by the actuarial method (default for cohort analysis)."
			display as result "See http://pauldickman.com/rsmodel/stata_colon/standard_errors.pdf for details."
		}
		if "`ht'" !="" {
			display as result _newline "The conditional survival proportion (p) is estimated by transforming the"
			display as result "estimated cumulative hazard rather than by the actuarial method (default for cohort analysis)."
			display as result "See http://pauldickman.com/rsmodel/stata_colon/standard_errors.pdf for details."
		}
		quietly {
			keep if `hakuse'
/* Brenner weights generated as the ratio between relative proportion of patients in the standard population and in the study population */
			if "`brenner'"!="" {
				tempvar t0
				generate `t0' = _t0==0
				quietly bysort `by' `touse' `t0': generate long `N' = _N   // In case of period analysis it should be considered only diagnoses in the time window (Mark)
				quietly bysort `by' `touse' `t0' `standstrata' : replace `wei' = `exp'/(_N/ `N') if `touse' & `t0'
				quietly bysort `by' `standstrata' `touse' (_t0): replace `wei' = `wei'[1] if `touse'
				local hakstrata `standstrata'
				local standstrata	
			}
			if "`indweight'"!="" {
				generate `wei' = `indweight'
				count if `wei' >=.
				if r(N) > 0 	display as error _n "WARNING: `r(N)' records have missing individual weights. Estimates may be wrong" 
				count if `wei' == 0
				if r(N) > 0 	display as error _n "WARNING: `r(N)' records have 0 individual weights. Estimates may be wrong" 
				count if `wei' < 0
				if r(N) > 0 	display as error _n "WARNING: `r(N)' records have negative individual weights. Estimates may be wrong" 
			}

/* By-Standstrata option */
			if "`by'"!="" |	"`standstrata'"!="" local byby "by `by' `standstrata' : "
			if "`pohar'" != ""{
				tempvar t_entpo
				generate `t_entpo' = _t0
				streset , enter(.)
				keep if _st
			}
/* Specify a list of variables to keep */
			capture confirm var `_dta[st_exexp]'
			if !_rc 	local exitvar "`_dta[st_exexp]'"
			capture confirm number `_dta[st_o]'
			if _rc {	
				keep `_dta[st_id]' `_dta[st_bt]' `_dta[st_bd]' `exitvar' `_dta[st_o]' `_dta[st_orexp]'  /// 
				   `ininmerby' `by' `diagage' `diagyear' _st _d _t _t0 `wei' `standstrata' `klist' `t_entpo' 
			}
			else {
				keep `_dta[st_id]' `_dta[st_bt]' `_dta[st_bd]' `exitvar' ///
				   `ininmerby' `by' `diagage' `diagyear' _st _d _t _t0 `wei' `standstrata' `klist' `t_entpo' 
			}
			stsplit start,at("`breaks'") trim
			keep if _st
			addend, br(`breaks')
			local maxti = r(llist)
			generate `attage'=int(`diagage'+start)
			replace `attage'=`maxage' if `attage'>`maxage'
			generate `attyear'=int(`diagyear'+start)
			sort `mergeby'
			merge `mergeby' using "`using'", nokeep nolabel keep(`survprob')
			count if _merge==1
		}
		if r(N) {
			di in red "`r(N)' records fail to match with the population file (`using'.dta)."
			di in red "That is, there are combinations of the mergeby() variables that do not exist in `using'.dta."
			di in red _newline "This will occur, for example, when patients are followed-up beyond" 
			di in red "the last year for which population mortality data are available." 
			di in red _newline "Records that did not match have been written to _merge_error_.dta)."
			quietly keep if _merge==1
			quietly save _merge_error_.dta, replace
			exit 459 
		}
		quietly {
			keep if _merge==3 /* Keep only if observations exists in both files */
			drop _merge
			generate d = _d
			if "`brenner'"!="" | "`indweight'"!=""	generate `d_sq' = _d * `wei'
			if "`calyear'" != "" { // calyear allowed only if pohar not also specified 
				levelsof `attyear', local(atyear)
				foreach i of local atyear {
					local d = date("1/1/`i'","mdy")
					local splyear "`splyear' `d'"
				}
				local scale "`_dta[st_s]'"
				streset , scale(1) 
				stsplit sply , at(`splyear') after(0)
				replace sply = int(sply/`scale' + 1960)
*				tab `attyear'
				replace `attyear' = sply if `attyear'<sply
*				tab `attyear'
				streset , scale(`scale')
				drop sply `survprob'
				sort `mergeby'
				merge `mergeby' using "`using'", nokeep nolabel keep(`survprob')
				generate p_star = `survprob'^(_t-_t0)
				bysort `_dta[st_id]' (_t0) : replace p_star = `survprob'^(end-_t0) if _n==_N
				generate y=(_t - _t0) 	/* Person-time at risk in the interval */				
				generate d_star=-ln(`survprob')* y 
				bysort `_dta[st_id]' start (_t0) : replace p_star = exp(sum(log(p_star)))
				local bycal : list by - ininmerby
				collapse (max) d `wei' _t `attyear' (sum) d_star y (min) p_star _t0 `bycal' `standstrata', ///
					by(`_dta[st_id]' `diagage' `attage' `diagyear' `ininmerby' `klist' start end) 
			}
			else {
				generate p_star = `survprob'^(end-start)
				if "`pohar'"=="" generate y = _t - _t0
				if "`pohar'"!="" {
					bysort `_dta[st_id]' (_t0) : generate weipohar = 1/exp(sum(log(p_star)))
* Seppa and Pokhrel 25 jan 2013
					replace weipohar = weipohar*sqrt(p_star)     		/* CHANGED */
					keep if end > `t_entpo'
					bysort `_dta[st_id]' (start) : replace _t0=`t_entpo' if _n==1
					generate y = _t - _t0
* y in PP is always 0.5*interval length if individuals die or are censored in the interval
					generate y_poh = end-start 
					bysort `_dta[st_id]' (start) : replace y_poh = min(y_poh, end-_t0) if _n==1       // if a subject enters in the interval
					replace y_poh = 0.5*y_poh if round(float(_t),0.0001) < round(float(end),0.0001)   // if a subject dies or is censored in the interval
					generate d_poh = d * weipohar
					generate d_pohsq = d * weipohar^2
					if "`brenner'"!="" | "`indweight'"!=""	replace d_pohsq = d_pohsq * `wei'				
					generate d_starpoh = -ln(`survprob') * y_poh * weipohar
					replace y_poh = y_poh * weipohar
					local poharest d_poh d_pohsq d_starpoh y_poh
				}
				generate d_star = -ln(`survprob') * y
			}
		}
	}
	quietly {
		generate nu=(d-d_star)/y 
	*/********************************************************************* 
	Save the data set containing the individual subject-band observations.
	***********************************************************************/
		label data "Survival data containing individual subject-band observations"
		label variable `diagage' "Age at diagnosis"
		label variable `attage' "Attained age"
		label variable `diagyear' "Diagnosis year"
		label variable `attyear' "Attained year"
		label variable start "Start time of interval"
		label variable end "End time of interval"
		if `pmethod'==1 {
			label variable w "Indicator for censored"
			if "`pohar'" != ""{
				label variable spw1   "Expected Pohar-weighted events"
				label variable spw2   "Expected Pohar-weighted at risk"
				label variable spwtt1 "Expected Pohar-weighted events without lifetab correction"
				label variable w_poh  "Pohar-weighted censored"
			}
		}
		label variable y "Person-time at risk"
		label variable d "Deaths during the interval"
		label variable d_star "Expected number of deaths"
		label variable nu "Estimated excess mortality rate, (d-d_star)/y"
		label variable p_star "Interval-specific expected survival"
		if "`pohar'" != ""{
			label variable d_poh  "Pohar-weighted events"
			label variable d_pohsq  "Squared Pohar-weighted events"
			if `pmethod' == 2 {
				label variable y_poh  "Pohar-weighted person-time at risk"
				if "`calyear'" == "" drop `t_entpo'
			}
		}
		if "`indfile'" != "" {
    /* Prevent tempvars being saved. version 1.4.2
	   See http://www.statalist.org/forums/forum/general-stata-discussion/general/84940-temporary-names-for-a-scalar-dangerous-advice */
            capture drop `touse'
			quietly save "`indfile'", `outrind'	
		}
	/**********************************************************************************
	Collapse the data (i.e. into life table intervals) and calculate survival.
	**********************************************************************************/
		if `pmethod' == 1 {
			if "`brenner'"=="" & "`indweight'"=="" {
				collapse (sum) d w y d_star `poharest' (count) n=d (mean) p_star `wei' end, by(`by' `standstrata' start)
				generate `d_sq' = d
			}
			else 	collapse (sum) d `d_sq' w y d_star `poharest' (count) n=d (mean) p_star [iw=`wei'], by(`by' start end)
			if "`pohar'" != "" {
* (new in 1.4.2.2) if all individuals die then  d_poh = n_poh and log(1-obsw) = .  
				replace d_poh = d_poh-.000001 if d_poh==n_poh 
				generate obsw   = d_poh/(n_poh-w_poh/2) 
				generate obswtt = d_poh/n_poh 
				generate spw   = spw1/spw2
				generate spwtt = spwtt1/n_poh
*				`byby' generate cns_pp = exp(sum(log(1-(obsw-spw))))
				`byby' generate cns_pp = exp(sum(log(1-obsw)+spw))    // CHANGED - Seppa and Pokhrel 25 jan 2013
/* Variance formula by Karri Seppa 13Jun2013 */
* substituted with the following line	`byby' generate se_cns_pp = cns_pp * sqrt(sum(d_pohsq/(n_poh-w_poh/2)^2))
				`byby' generate se_cns_pp = cns_pp * sqrt(sum(d_pohsq/(n_poh-w_poh/2-d_poh/2)^2))
*				`byby' generate cns_pptt = exp(sum(log(1-(obswtt-spwtt))))
				`byby' generate cns_pptt = exp(sum(log(1-obswtt)+spwtt))
				local cns_pptt cns_pptt
				label variable cns_pptt "Cumulative net survival - without lifetab correction"
				if "`cilog'" =="" {
					generate lo_cns_pp = exp(-exp(log(-log(cns_pp)) - se_cns_pp*`level'/(cns_pp*log(cns_pp))))  
					generate hi_cns_pp = exp(-exp(log(-log(cns_pp)) + se_cns_pp*`level'/(cns_pp * log(cns_pp))))   
					replace lo_cns_pp = cns_pp if cns_pp<=0  | cns_pp>=1 
					replace hi_cns_pp = cns_pp if cns_pp<=0  | cns_pp>=1 
				}
				else {
					g lo_cns_pp = cns_pp*exp(-se_cns_pp*`level'/cns_pp)
					g hi_cns_pp = cns_pp*exp(se_cns_pp*`level'/cns_pp)
				}	
				drop d_poh d_pohsq w_poh n_poh obsw* spw*
			}
			generate n_prime=n-w/2
			generate ns=n_prime-d
			generate nu=(d-d_star)/y 
			local w w
			generate p=1-d/n_prime
		}
		if `pmethod'==2 {
			if "`brenner'"=="" & "`indweight'"=="" {
				collapse (sum) d y d_star `poharest' (count) n=d (mean) p_star `wei', by(`by' `standstrata' start end)
				generate `d_sq' = d
			}
			else 	collapse (sum) d `d_sq' y d_star `poharest' (count) n=d (mean) p_star [iw=`wei'], by(`by' start end)
			generate nu=(d-d_star)/y 
			local w y
			generate p=exp(-(end-start)*d/y)
		}
		generate r=p/p_star

/* Cumulative observed survival */
/* Updated v1.2.5 (16may2007) to correct bug when p=0 (thanks to John Condon and Arun Pokhrel) */
		`byby' generate cp=exp(sum(ln(p))) if p~=0
		 replace cp=0 if p==0
/* Cumulative expected survival */
		`byby' generate cp_e2=exp(sum(ln(p_star)))
/* Cumulative relative survival */
		generate cr_e2=cp/cp_e2
/* Updated v1.3.0 (17jun2010) by PWD */
/* SEs were previously incorrect when late entry */
/* Add code so that SEs are now based on transformation method */
/* See http://www.pauldickman.com/rsmodel/stata_colon/standard_errors.pdf for details */
		if `pmethod'==2 {
/* SE of P based on transforming the cumulative hazard 
	When Brenner or indweight() are used the squared number of events needs for variance 
	When Brenner or indweight() are not specified `d_sq'=d
*/
			generate var_Lambda=(end-start)^2*`d_sq'/y^2  
			generate se_p=p*sqrt(var_Lambda)
/* SE of CP based on transforming the cumulative hazard */
/* See http://www.pauldickman.com/rsmodel/stata_colon/strs_technical_140.pdf */
			`byby' generate var_cLambda=sum( (end-start)^2*`d_sq'/y^2 )
			generate se_cp=cp*sqrt(var_cLambda)
			if "`cuminc'" == "" 	drop var_Lambda var_cLambda
			else {
				generate n_prime = (var_Lambda*d + sqrt((var_Lambda*d)^2 + 4*var_Lambda*d)) / (2*var_Lambda)
				rename var_Lambda se_ptemp
				rename var_cLambda se_temp
			}
			if "`pohar'"!="" {
				`byby' generate cns_pp = exp(sum(log(exp(-(end-start)*(d_poh-d_starpoh)/y_poh))))
				`byby' generate se_cns_pp = cns_pp * sqrt(sum((end-start)^2 * d_pohsq/y_poh^2))
				if "`cilog'" =="" {
					generate lo_cns_pp =  exp(-exp(log(-log(cns_pp)) - se_cns_pp*`level'/(cns_pp*log(cns_pp))))  
					generate hi_cns_pp =  exp(-exp(log(-log(cns_pp)) + se_cns_pp*`level'/(cns_pp*log(cns_pp))))   
					replace lo_cns_pp =  cns_pp if cns_pp<=0  | cns_pp>=1 
					replace hi_cns_pp =  cns_pp if cns_pp<=0  | cns_pp>=1 
				}
				else {
					g lo_cns_pp = cns_pp*exp(-se_cns_pp*`level'/cns_pp)
					g hi_cns_pp = cns_pp*exp(se_cns_pp*`level'/cns_pp)
				}	
*				drop d_poh d_pohsq y_poh d_starpoh
			}
		} 
		if `pmethod'==1 {
/* Standard errors using Greenwood's method */	
			generate se_p=sqrt(p*(1-p)/n_prime)
/* SE of the cumulative survival - See comment above for the use of `d_sq' instead of d */
			 generate se_ptemp = `d_sq'/(n_prime*(n_prime-`d_sq'))  // for cumulative expected survival
			`byby' generate se_temp=sum(`d_sq'/(n_prime*(n_prime-`d_sq')) )
			generate se_cp=cp*sqrt(se_temp)
			if "`cuminc'"==""	drop se_temp se_ptemp	
		}

		generate se_cr_e2 = se_cp/cp_e2 // SE of CR
	/* SE of R */
		generate se_r= se_p/p_star
	/* Calculate confidence intervals on the log-hazard scale and back transform */
	/* First for the interval-specific estimates */
		generate se_lh_p=cond(p!=int(p),sqrt(se_p^2/(p*log(p))^2 ),0)                          
		generate lo_lh_p=cond(p!=int(p),log(-log(p))+`level'*se_lh_p,0)                        
		generate hi_lh_p=cond(p!=int(p),log(-log(p))-`level'*se_lh_p,0)                        
	/* codefor lo_p and hi_p updated version 1.3.2 05nov2010 by PWD */ 
	/* previous code didn't work when p=0; thanks to Thomasz Banasik */
		generate lo_p=cond(missing(p),.,cond(p<=0,0,cond(p==1,1,exp(-exp(lo_lh_p)))))
		generate hi_p=cond(missing(p),.,cond(p<=0,0,cond(p==1,1,exp(-exp(hi_lh_p)))))
		generate lo_r=lo_p/p_star                                         
		generate hi_r=hi_p/p_star                                         
	/* Calculate CIs for the cumulative estimates */
		if "`cilog'"=="" {
			generate se_lh_cp=cond(cp!=int(cp),sqrt(se_cp^2/(cp*log(cp))^2 ),0)     
			generate lo_lh_cp=cond(cp!=int(cp),log(-log(cp))+`level'*se_lh_cp,0)  
			generate hi_lh_cp=cond(cp!=int(cp),log(-log(cp))-`level'*se_lh_cp,0) 
			local lohicp se_lh_cp lo_lh_cp hi_lh_cp
		/* code for lo_cp and hi_cp updated version 1.3.2 05nov2010 by PWD */ 
		/* previous code didn't work when cp=0; thanks to Thomasz Banasik */
			generate lo_cp=cond(missing(cp),.,cond(cp<=0,0,cond(cp==1,1,exp(-exp(lo_lh_cp)))))
			generate hi_cp=cond(missing(cp),.,cond(cp<=0,0,cond(cp==1,1,exp(-exp(hi_lh_cp)))))
		}
		else {
			generate lo_cp=cond(missing(cp),.,cond(cp<=0,0, cp*exp(-se_cp*`level'/cp)))
			generate hi_cp=cond(missing(cp),.,cond(cp<=0,0, cp*exp(se_cp*`level'/cp)))
		}
		generate lo_cr_e2=lo_cp/cp_e2                    
		generate hi_cr_e2=hi_cp/cp_e2
	/* SEER*Stat approach to compute CI for CRS 
		generate lo_cr_e2 = cr_e2^exp(`level'  * abs(se_cr_e2 /(cr_e2 *log(cr_e2))))  
		generate hi_cr_e2 = cr_e2^exp(-`level' * abs(se_cr_e2 /(cr_e2 *log(cr_e2)))) 
		replace lo_cr_e2 = cr_e2 if cr_e2<=0 | cr_e2>=1
		replace hi_cr_e2 = cr_e2 if cr_e2<=0 | cr_e2>=1 
	*/
	/* Calculate Cumulative Incidence - Cronin K et al Stat in Med 2000, 19: 1729-1740 */
		if "`cuminc'" != ""{
			cum_inc `level' `cilog' `by' `standstrata'
			capture assert p_dc>=0
			if _rc local less "less than 0"
			drop se_temp se_ptemp	
			local c_inc	"p_dc p_do ci_dc ci_do hi_ci_do lo_ci_do hi_ci_dc lo_ci_dc F"
			local cumlist   "start end n d cp F cr_e2 ci_dc lo_ci_dc hi_ci_dc ci_do lo_ci_do hi_ci_do"
			local cum_stan   "F ci_dc lo_ci_dc hi_ci_dc ci_do lo_ci_do hi_ci_do se_ci_do se_ci_dc"
		}
		drop se_lh_p lo_lh_p hi_lh_p `lohicp' `d_sq'
		label variable start "Start of interval"
		label variable end "End of interval"
		label variable n "Alive at start"
		label variable y "Person-time at risk"
		if `pmethod' == 1 {
			label variable w "Withdrawals during the interval"
			label variable n_prime "Effective number at risk"
			label variable ns "Number of survivors"
		}
		label variable d "Deaths during the interval"
		label variable r "Interval-specific relative survival"
		label variable d_star "Expected number of deaths"
		label variable nu "Estimated excess mortality rate, (d-d_star)/y"
		label variable p_star "Interval-specific expected survival"
		label variable p "Interval-specific observed survival"
		label variable cp "Cumulative observed survival"
		label variable cr_e2 "Cumulative relative survival (Ederer II)"
		label variable cp_e2 "Cumulative expected survival (Ederer II)"
		label variable se_p "Standard error of P"
		label variable se_r "Standard error of R"
		label variable se_cr_e2 "Standard error of CR (Ederer II)"
		label variable se_cp "Standard error of CP"
		label variable lo_p "Lower 95% CI for P"
		label variable hi_p "Upper 95% CI for P"
		label variable lo_r "Lower 95% CI for R"
		label variable hi_r "Upper 95% CI for R"
		label variable lo_cp "Lower 95% CI for CP"
		label variable hi_cp "Upper 95% CI for CP"
		label variable lo_cr_e2 "Lower 95% CI for CR (Ederer II)"
		label variable hi_cr_e2 "Upper 95% CI for CR (Ederer II)"
		if "`standstrata'"!=""  label var `wei' "Weight"
/********************************************************************* 
Save the data set containing the collapsed data.
***********************************************************************/
		label data "Collapsed (or grouped) survival data"
		format start end %6.0g
		format n d %6.0f
		format y d_star %7.1f
		if `pmethod'==1 {
			format w %6.0f
			format n_prime %7.1f
			local pml ns w n_prime
		}
		format p p_star r cp cp_e2 cr_e2 se_p se_r se_cr_e2 se_cp lo_p hi_p lo_r hi_r /// 
			lo_cp hi_cp lo_cr_e2 hi_cr_e2 `c_inc' `format'
		sort `by' `standstrata' start
		local cr  cp_e2 cr_e2 lo_cr_e2 hi_cr_e2  
		local cr2 cp_e2 cr_e2 se_cr_e2 lo_cr_e2 hi_cr_e2
		local cr_stand cp cr_e2 se_cr_e2 
		if "`pohar'"!="" {
			format cns_pp `cns_pptt' lo_cns_pp hi_cns_pp se_cns_pp `format' 
			label variable cns_pp "Cumulative net survival (Pohar Perme et al)"
			label variable se_cns_pp "Standard error of CNS (Pohar Perme et al)"
			local cpohar cns_pp se_cns_pp lo_cns_pp hi_cns_pp `cns_pptt'
			label variable lo_cns_pp "Lower 95% CI for CNS (Pohar Perme et al)"
			label variable hi_cns_pp "Upper 95% CI for CNS (Pohar Perme et al)"
			local cr cns_pp lo_cns_pp hi_cns_pp   
			local cr_stand `cr_stand' cns_pp se_cns_pp 
		}
		order start end n d d_star `pml' y p se_p lo_p hi_p p_star /// 
			r se_r lo_r hi_r cp se_cp lo_cp hi_cp `cpohar' `cr2' `crh'
		save "`group_est'"
		if "`brenner'" != "" & "`standfile'" != "" {
			label data "Age-standardized survival data using the Brenner and Hakulinen approach"
			note: According to Brenner and Hakulinen approach weights have been assigned at each individual. Therefore the saved data contain a weighted life table. 
			save "`standfile'", `outrsta'
		}
		if "`indweight'" != "" {
			label data "Weighted survival data."
			note: Weights specified in `indweight' have been assigned at each individual. Therefore the saved data contain a weighted life table. 
		}
		else label data "Collapsed (or grouped) survival data"
		if "`brenner'" == "" & "`grfile'" != "" save "`grfile'", `outrgro'
	}

/* Ederer I estimates */
if "`ederer1'" != "" {
         restore,preserve
	 quietly keep if `touse' 
	 quietly keep `_dta[st_id]' `ininmerby' `by' `diagage' `diagyear' _st _d _t _t0 `wei' `standstrata'
         quietly {
                 replace _t = `maxti'
                 stsplit start,at("`breaks'") trim
                 keep if _st==1
                 rename _t end
                 generate `attage'=int(`diagage'+start)
                 replace `attage'=`maxage' if `attage'>`maxage'
                 generate `attyear'=int(`diagyear'+start)
                 sort `mergeby'
                 merge `mergeby' using "`using'", nolabel keep(`survprob')
                 // To fill the surv probabilities where they are unavailable. Note that _merge==1 are kept
                 bysort `ininmerby' `attage' (`attyear') : replace `survprob' = `survprob'[_n-1] if `survprob'>=.   
                 drop if _merge==2 
                 drop _merge
                 generate p_star=`survprob'^(end-start)
                 bysort `_dta[st_id]' (start) : generate double p_e1 = exp(sum(log(p_star))) 
		/* Brenner approach unallowed */
		collapse cp_e1=p_e1, by(`by' `standstrata' start) 
		sort `by' `standstrata' start
                merge `by' `standstrata' start using "`group_est'"
                drop _merge
                generate cr_e1 = cp/cp_e1
				generate lo_cr_e1=lo_cp/cp_e1
                generate hi_cr_e1=hi_cp/cp_e1
                label variable start "Start of interval"
                label variable cp_e1 "Cumulative expected survival (Ederer I)"
                label variable cr_e1 "Cumulative relative survival (Ederer I)"
                label variable lo_cr_e1 "Lower 95% CI for CR (Ederer I)"
                label variable hi_cr_e1 "Upper 95% CI for CR (Ederer I)"
                format cp_e1 cr_e1 lo_cr_e1 hi_cr_e1 `format'
                if "`pohar'"=="" local cr cp_e1 cr_e1 lo_cr_e1 hi_cr_e1  
                local cr1 cp_e1 cr_e1 lo_cr_e1 hi_cr_e1
		local cr_stand `cr_stand' cr_e1 
		sort `by' `standstrata' start
                order start end n d d_star `pml' y p se_p lo_p hi_p p_star /// 
			r se_r lo_r hi_r cp se_cp lo_cp hi_cp `cr1' `cr2' `crh'
		save "`group_est'",replace
		if "`grfile'" != "" {
			if "`indweight'" != "" {
				label data "Weighted survival data."
				note: Weights specified in `indweight' have been assigned at each individual. Therefore the saved data contain a weighted life table. 
			}
			else label data "Collapsed (or grouped) survival data"
			save "`grfile'", replace
		}
     }
}

/* Calculate Hakulinen estimates if potfu() option is specified */
if "`potfu'" != "" {
	restore,preserve
	quietly {
		keep if `hakuse'
		if "`brenner'"!="" {
			if "`by'" != ""	quietly bysort `by' : generate long `N' = _N 
			else	quietly generate long `N' = _N 
			bysort `by' `hakstrata' : replace `wei' = `exp'/(_N/ `N') 
		}
		if "`_dta[st_ev]'"=="" 	replace `_dta[st_bt]'=`potfu' if `_dta[st_bd]'!=0 & `_dta[st_bd]'<.
		else {
			foreach i of numlist `_dta[st_ev]' {
				replace `_dta[st_bt]'=`potfu' if `_dta[st_bd]'==`i'
			}
		}
		stset
		if `pmethod'==2 {
			tempvar t_ent
			generate `t_ent' = _t0
			streset, enter(.)
		}
		keep if _st
		
		/* Specify a list of variables to keep */
		keep `_dta[st_id]' `ininmerby' `by' `diagage' `diagyear' _st _d _t _t0 `wei' `standstrata' `t_ent'
		stsplit start,at("`breaks'") trim
		keep if _st
		addend, br(`breaks')
		generate `attage'=int(`diagage'+start)
		replace `attage'=`maxage' if `attage'>`maxage'
		generate `attyear'=int(`diagyear'+start)
		sort `mergeby'
		merge `mergeby' using "`using'", nokeep nolabel keep(`survprob')
		count if _merge==1
		if r(N) {
			di in red "`r(N)' records fail to match with general population file when estimating" ///
			_n " Hakulinen expected survival (records who do not match are saved" ///
			   " to _mergehak_error_.dta)."
			keep if _merge==1
			save _mergehak_error_.dta, replace
			exit 459 
		}
		keep if _merge==3 /* Keep only if observations exists in both files */
		drop _merge
		generate p_star=`survprob'^(end-start)
		bysort `_dta[st_id]' (start) : ///
			generate double l_hak = cond(_n>1,exp(sum(log(p_star[_n-1]))),1)

	/* New : Hakulinen estimates if late entry occurs */
		if `pmethod'==2 {
			keep if end > `t_ent'
			bysort `_dta[st_id]' (start) : replace _t0 = `t_ent' if _n==1 
			generate double y=(_t - _t0) 	/* Person-time at risk in the interval */
			generate d = l_hak*(1-sqrt(p_star)) * (y!=(end-start)) + l_hak*(1-p_star) * (y==(end-start))
/* If lost */		bysort `_dta[st_id]' (start) : replace d = l_hak*(1-p_star^.25) ///
					if (end-`t_ent')!=(_t-`t_ent') & _n==1 & `t_ent'>0 
			generate w_hak = l_hak * sqrt(p_star) * (y!=(end-start))
/* If lost */		bysort `_dta[st_id]' (start) : replace w_hak = l_hak*p_star^.25*1.5 ///
					if (end-`t_ent')!=(_t-`t_ent') & _n==1 & `t_ent'>0 
			if "`brenner'"=="" collapse (sum) l_hak w_hak d, by(`by' `standstrata' start)
			else  collapse (sum) l_hak w_hak d [iw=`wei'], by(`by' start)
			generate g = 1 - d / (l_hak - 0.5*w_hak)
			drop d l_hak w_hak
		}

		else {
			generate y=(_t - _t0) 	/* Person-time at risk in the interval */
			generate w_hak = l_hak*sqrt(p_star) * (y!=(end-start))
			generate delta = l_hak*(1-sqrt(p_star)) * (y!=(end-start)) 
			generate l_plus = l_hak * p_star* (y==(end-start))
			if "`brenner'"=="" collapse (sum) l_hak l_plus w_hak delta, by(`by' `standstrata' start)
			else  collapse (sum) l_hak l_plus w_hak delta [iw=`wei'], by(`by' start)
			generate f = w_hak+delta
			generate g=0.25*(l_hak-0.5*f)^(-2)* ///
				(-0.5*delta+sqrt(0.25*delta^2+4*(l_hak-0.5*f)* ///
					(l_plus+0.5*w_hak)))^2
			drop l_hak l_plus w_hak delta f
		}

		`byby' generate cp_hak = exp(sum(ln(g)))
		sort `by' `standstrata' start
		merge `by' `standstrata' start using "`group_est'"
		keep if _merge==3
		drop _merge
		generate cr_hak = cp/cp_hak
		generate se_cr_hak = se_cp/cp_hak // Dickman more transparent approach
		generate lo_cr_h=lo_cp/cp_hak                    
		generate hi_cr_h=hi_cp/cp_hak
/* SEER*Stat approach to compute CI for CRS 
		generate lo_cr_h = cr_hak^exp(`level'  * abs(se_cr_hak /(cr_hak * log(cr_hak))))
		generate hi_cr_h = cr_hak^exp(-`level' * abs(se_cr_hak /(cr_hak * log(cr_hak))))
		replace lo_cr_h = cr_hak if cr_hak<=0 | cr_hak>=1
		replace hi_cr_h = cr_hak if cr_hak<=0 | cr_hak>=1
*/
		label variable g "Interval expected survival (Hakulinen)"
		label variable cp_hak "Cumulative expected survival (Hakulinen)"
		label variable cr_hak "Cumulative relative survival (Hakulinen)"
		label variable se_cr_hak "Standard error of CR (Hakulinen)"
		label variable lo_cr_h "Lower 95% CI for CR (Hakulinen)"
		label variable hi_cr_h "Upper 95% CI for CR (Hakulinen)"
		label variable start "Start of interval"
		label variable end "End of interval"
		format cp_hak cr_hak lo_cr_h hi_cr_h g `format'
		format start end %6.0g
		if "`pohar'"=="" local cr cp_hak cr_hak lo_cr_h hi_cr_h 
		local crh cp_hak cr_hak se_cr_hak lo_cr_h hi_cr_h 
		local cr_stand `cr_stand' cr_hak se_cr_hak 
		order start end n d d_star `pml' y p se_p lo_p hi_p p_star /// 
			r se_r lo_r hi_r cp se_cp lo_cp hi_cp `crh' `cr1' `cr2'
		if "`brenner'" != "" & "`standfile'" != "" {
			label data "Age-standardized survival data using the Brenner and Hakulinen approach"
			note: According to Brenner and Hakulinen approach weights have been assigned at each individual. Therefore the saved data contain a weighted life table. 
			quietly save "`standfile'", replace
		}
		if "`brenner'" == "" & "`grfile'" != "" {
			label data "Collapsed (or grouped) survival data"
			quietly save "`grfile'", replace
		}
	}	
}

/* Show tables */
if "`tables'" == "" {
	sort `by' `standstrata' start
	if "`brenner'"!="" {
		display as res _n "Adjusted survival estimates weighting individual observations as proposed" ///
			" by Brenner."
	}
	if "`list'"==""{
		if "`cuminc'"==""	`byby' list start end n d `w' p p_star r cp `cr', table noobs
		else {
			`byby' list `cumlist', table noobs
			if "`less'" != "" {
				di in smcl as txt "{p}Note that some estimate of the interval-specific probability of " ///
					"cancer death is less than 0.{p_end}"
			}
		}
	}
	else {
		foreach name of local list {
			capture confirm var `name'
			if _rc    display as error "WARNING: `name' invalid or ambiguous in list option" 
			else	  unab ilist: `name'
			local tolist "`tolist' `ilist'"
		}
		local tolist : list uniq tolist
		local st_end "start end"
		if "`by'" != "" local tolist : list tolist - by
* 3rd Paul Lambert's suggestion
		local flist : list tolist - st_end
		if "`flist'" == "`tolist'" 	`byby' list start end `tolist', table noobs
		else 				`byby' list `tolist', table noobs
	}
}	
/* Weighted average of survival estimate */
if "`standstrata'"!="" {
/* AIRTUM Analysis April 2011 - When hybrid or period approach is applied to rare tumours it may happen
that survival estimates are indeterminate in the first or intermediate intervals.
In this case standardized survival cannot be estimated after the interval where the survival is indeterminate. */
	if `pmethod'==2 {
		su end,meanonly
		capture bysort `by' `standstrata' (start) : assert float(end[1])==float(`r(min)')
		if _rc {
			quietly bysort `by' `standstrata' (start) : drop if float(end[1])!=float(`r(min)')
			di in smcl as txt "{p}Note that in some `by' group adjusted estimates cannot be computed " ///
				"because the survival estimates does not start from the first interval.{p_end}"
		}
		quietly bysort `by' `standstrata' (start): generate byte chkseq = 1 if float(start)!=end[_n-1] & _n!=1
		quietly bysort `by' `standstrata' (start): replace chkseq = sum(chkseq)
		drop if chkseq>0
	}
/*  11 may 2011 - Age-standardized survival estimates cannot be computed from the interval where -n- becomes 0 in an age group, 
     typically age>75. But we should distinguish two situations:
    1) the survival probability decreases to 0, i.e. all cases present at the start of the interval die within the interval.
       In the following intervals -n- is 0, but the survival is still 0 (not indeterminate). Therefore, the standardized survival 
       can be calculated.  
   2) -n- becomes 0 because of withdrawals (and not for deaths) in the previous interval.
      In this case the survival is indeterminate and the standardized survival cannot be calculated. */
	quietly {
		count if cp==0
		if `r(N)'>0 {
			fillin `by' `standstrata' end
			count if _fillin==1
			if `r(N)' > 0 {
				bysort `by' `standstrata' (end) : replace `wei'=`wei'[_n-1] if `wei'==.
				foreach var of varlist `cr_stand' {
					bysort `by' `standstrata' (end) : replace `var'=`var'[_n-1] if cr_e2[_n-1]==0  // Thanks to Ivan Rashid
				}
				drop if cr_e2==.
				bysort `by' `standstrata' (end) : replace start=end[_n-1] if start==.
			}
			drop _fillin
		}
	}
* Erase intervals where some standstrata are missing
	quietly inspect `standstrata'
	quietly bysort `by' start: drop if _N!=`r(N_unique)'
* Check if in some standstrata cumulative relative survival exceeds 1 or estimates in previous intervals
	capture assert p<=p_star
	local chr = _rc
/* Confidence Intervals for Standardized Estimates according to the formula used in Eurocare IV.
   Thanks to Roberta De Angelis 25 mar 2011
   SE_CRstandardized =  [Summ_k (w_k * SE_k)^2]^1/2  =  [Summ_k w_k*(w_k * SE_k^2)]^1/2	*/
	capture confirm var cr_e2
	if !_rc		quietly replace se_cr_e2  = `wei'*se_cr_e2^2  // 
	capture confirm var cr_hak
	if !_rc 	quietly replace se_cr_hak = `wei'*se_cr_hak^2
	capture confirm var cns_pp
	if !_rc 	quietly replace se_cns_pp = `wei'*se_cns_pp^2
/* Extending the same approach to standardized cumulative incidence estimates */
	if "`cuminc'" != "" {
		quietly replace se_ci_do  = `wei'*se_ci_do^2
		quietly replace se_ci_dc  = `wei'*se_ci_dc^2
	}	
	collapse `cr_stand' `cum_stan' [iw=`wei'], by(`by' start end)
	capture confirm var cr_e2
	if !_rc {
		quietly replace se_cr_e2 = sqrt(se_cr_e2)
		if "`cilog'"=="" {
		/* New in 1.3.8: Added condition so that CI is missing when cr_e2>1 */ 
			generate lo_cr_e2 = cond(cr_e2<=1,cr_e2^exp(`level'  * abs(se_cr_e2 /(cr_e2 *log(cr_e2)))),.)  
			generate hi_cr_e2 = cond(cr_e2<=1,cr_e2^exp(-`level' * abs(se_cr_e2 /(cr_e2 *log(cr_e2)))),.) 
		}
		else {
			gen lo_cr_e2 = cr_e2*exp(-`level'*se_cr_e2 /cr_e2)  
			gen hi_cr_e2 = cr_e2*exp(`level'*se_cr_e2 /cr_e2)				
		}
		label var cr_e2 "Standardized CR (Ederer II)"
		label var lo_cr_e2 "Lower 95% CI for standardized CR (Ederer II)"
		label var hi_cr_e2 "Higher 95% CI for standardized CR (Ederer II)"
		label var se_cr_e2 "Standard error of standardized CR (Ederer II)"
		local cr_stand cp cr_e2 lo_cr_e2 hi_cr_e2
		format lo_cr_e2 hi_cr_e2 `format' 

	}
	capture confirm var cns_pp
	if !_rc {
		quietly replace se_cns_pp = sqrt(se_cns_pp)
    /* New in 1.3.8: Added condition so that CI is missing when cns_pp>1 */ 
		if "`cilog'"=="" {
			generate lo_cns_pp = cond(cns_pp<=1,cns_pp^exp(`level'  * abs(se_cns_pp /(cns_pp *log(cns_pp)))),.)
			generate hi_cns_pp = cond(cns_pp<=1,cns_pp^exp(-`level' * abs(se_cns_pp /(cns_pp *log(cns_pp)))),.)
		}
		else {
			gen lo_cns_pp = cns_pp*exp(-`level'*se_cns_pp /cns_pp)  
			gen hi_cns_pp = cns_pp*exp(`level'*se_cns_pp /cns_pp)				
		}
		label var cns_pp "Standardized CNS (Pohar Perme et al)"
		label var lo_cns_pp "Lower 95% CI for standardized CNS (Pohar Perme et al)"
		label var hi_cns_pp "Higher 95% CI for standardized CNS (Pohar Perme et al)"
		label var se_cns_pp "Standard error of standardized CNS (Pohar Perme et al)"
		local cr_stand `cr_stand' cns_pp lo_cns_pp hi_cns_pp
		format lo_cns_pp hi_cns_pp `format'
	}
	capture confirm var cr_e1
	if !_rc local cr_stand `cr_stand' cr_e1
	capture confirm var cr_hak
	if !_rc {
		quietly replace se_cr_hak = sqrt(se_cr_hak)
    /* New in 1.3.8: Added condition so that CI is missing when cr_hak>1 */ 
		generate lo_cr_h = cond(cr_hak<=1,cr_hak^exp(`level'  * abs(se_cr_hak /(cr_hak *log(cr_hak)))),.)  
		generate hi_cr_h = cond(cr_hak<=1,cr_hak^exp(-`level' * abs(se_cr_hak /(cr_hak *log(cr_hak)))),.)
		label var cr_hak "Standardized CR (Hakulinen)"
		label var lo_cr_h "Lower 95% CI for standardized CR (Hakulinen)"
		label var hi_cr_h "Higher 95% CI for standardized CR (Hakulinen)"
		label var se_cr_hak "Standard error of standardized CR (Hakulinen)"
		local cr_stand `cr_stand' cr_hak lo_cr_h hi_cr_h
		format lo_cr_h hi_cr_h `format'
	}
	if "`cuminc'" != "" {
		quietly replace se_ci_do  = sqrt(se_ci_do)
		quietly replace se_ci_dc  = sqrt(se_ci_dc)
		replace hi_ci_dc      =	ci_dc^exp(`level'*se_ci_dc/(ci_dc*log(ci_dc)))   
		replace lo_ci_dc      =	ci_dc^exp(-`level'*se_ci_dc/(ci_dc*log(ci_dc))) 
		replace hi_ci_do      =	ci_do^exp(`level'*se_ci_do/(ci_do*log(ci_do)))  
		replace lo_ci_do      =	ci_do^exp(-`level'*se_ci_do/(ci_do*log(ci_do))) 
		label var hi_ci_dc "Upper 95% CI for standardized ci_dc"
		label var lo_ci_dc "Lower 95% CI for standardized ci_dc"
		label var hi_ci_do "Upper 95% CI for standardized ci_do"
		label var lo_ci_do "Lower 95% CI for standardized ci_do"
		label var se_ci_dc "Standard Error of standardized ci_dc"
		label var se_ci_do "Standard Error of standardized ci_do"
	}	
	if "`tables'" == "" {
		if "`by'"!=""	local byby : list byby - standstrata
		else local byby 
		if "`cuminc'" == "" {
			di in smcl as res _n "{p}Adjusted survival estimates weighting stratum-specific survival in each group" ///
				" of `standstrata' by `exp' weights.{p_end}"
*NEW 24 jan 2012
			if "`list'"!="" {
				local cr_stand `cr_stand' se_cr_e2 se_cr_hak se_cns_pp
				local cr_stand : list cr_stand & flist
			}
			`byby' list start end `cr_stand', table noobs
			if `chr'>0 { 
				di in smcl as txt "Note: The cumulative relative/net survival exceeds 1 or is greater " ///
				_newline          "      than the estimate in the previous interval for at least one " ///
				_newline          "      level of `standstrata'. The CI is set to missing." _newline 
			}
		}
		else {
			di in smcl as res _n "{p}Adjusted cumulative probability of death estimates weighting stratum-specific cumulative probability" ///
				" of death in each group of `standstrata' by `exp' weights.{p_end}"
			`byby' list start end cp `cum_stan', table noobs
		}
	}
*Save standardised estimates
	if "`standfile'" != "" {
		label data "Age-standardized survival data"
		save "`standfile'", `outrsta'
	}
}

if "`indfile'" != "" {
	quietly use "`indfile'", clear
	cap drop `d_sq'
	cap confirm var `wei'
	if !_rc {
		rename `wei' _indweight
		label var _indweight "Individual weight"
		quietly save "`indfile'", replace	
	}
}
end

program define addend, rclass
	version 8.0
	syntax, BReaks(numlist ascending)
	tokenize `breaks'
* Forced end to be float from version 1.4.2.1
	generate float end=.
*New
while "`2'" != "" {
      		replace end=`2' if round(float(start),0.0001)==round(float(`1'),0.0001)
      		mac shift
      	}
	ret scalar llist = `1'
end

program define cum_inc, sortpreserve
	version 8
	gettoken level by : 0
	gettoken first : by
	if "`first'"=="cilog" { 
		gettoken cilog by : by
	}
	gettoken first : by
	if "`first'"!="" {
		local byby "by `by' (end) : "
		sort `by' end
	}
	tempvar grp isgrp
	`byby' generate `grp' = 1 if _n==1
	replace `grp'  = sum(`grp')
	generate byte `isgrp' = .
	`byby' generate  p_dc  = exp(sum(log(p)) - log(p)) * (1-p/p_star) * (1-0.5*(1-p_star))   		// Cronin : gxc
	`byby' generate  p_do	= exp(sum(log(p)) - log(p)) * (1 - p_star) * (1-0.5*(1-p/p_star))  		// Cronin : gxo
	`byby' generate  ci_dc	= sum(p_dc)									// Cronin : Gxc 
	`byby' generate  ci_do	= sum(p_do)									// Cronin : Gxo
	label var p_dc  "Interval-specific prob of cancer death in presence of competing risks"
	label var p_do  "Interval-specific prob of other-cause death in presence of competing risks"
	label var ci_dc "Cum. incidence of death due to cancer in presence of competing risks"
	label var ci_do "Cum. incidence of death due to other causes in presence of competing risks"
	`byby' generate se_p_dc = sqrt(p_dc^2 * (cond(se_temp[_n-1]<., se_temp[_n-1],0)  + (p/(p_star-p))^2 * se_ptemp ))  // vargxc 
	`byby' generate se_p_do = sqrt(p_do^2 * (cond(se_temp[_n-1]<., se_temp[_n-1],0)  + (p/(p_star+p))^2 * se_ptemp ))  // vargxo
	label var se_p_dc  "Standard error of P_DC"
	label var se_p_do  "Standard error of P_DO"

	* Variance of cumulative probability of death - Cronin's paper p. 1733 
	generate hi_ci_dc = .
	generate lo_ci_dc = .
	generate hi_ci_do = .
	generate lo_ci_do = .
	generate se_ci_do = .
	generate se_ci_dc = .	
/* Version 1.2.9 -levelsof- instead of levels7 */
	levelsof `grp', local(bygroup)
	foreach l of local bygroup {	
		count if `grp'==`l' 
		local n = `r(N)'
		replace `isgrp' = `grp'!=`l'
		sort `isgrp' end
		matrix COV_CPDC = J(`n',`n',0)
		forval i = 2/`n' {
			forval u = 2/`i'{
				mat COV_CPDC[`u'-1,`i'] = cp[`i'-1] * cond(cp[`u'-2]!=.,cp[`u'-2],1) /// 
					* (1 - .5*(1-p_star[`u'-1]))*(1 - .5*(1-p_star[`i'])) ///
					* (1-r[`u'-1]) * (1-r[`i']) ///
					* ( - ((1-p[`u'-1])/((p_star[`u'-1]-p[`u'-1])*n_prime[`u'-1])) /// 
					+ (se_temp[`u'-1] - se_ptemp[`u'-1] ) )  
			}
		}
		svmat COV_CPDC, names(t)
		drop t1
		forval i = 3/`n' {
			local u = `i' - 1
			replace t`i' = t`i'+ t`u'  
		}
		forval i = 2/`n' {
			replace t`i' = sum(t`i')
		}
		
		replace se_ci_dc = sum(se_p_dc^2) if `grp'==`l'
		forval i = 2/`n' {
			replace se_ci_dc = sqrt(se_ci_dc + 2*t`i'[_N]) if _n == `i' & `grp'==`l'
			drop t`i'
		}
		replace se_ci_dc = sqrt(se_ci_dc) if _n==1 & `grp'==`l'
		matrix COV_CPDO = J(`n',`n',0)
		forval i = 2/`n' {
			forval u = 2/`i'{
				mat COV_CPDO[`u'-1,`i'] = cp[`i'-1] * cond(cp[`u'-2]!=.,cp[`u'-2],1) /// 
					* (1 - p_star[`u'-1])*(1 - p_star[`i']) ///
					* (1-.5*(1-r[`u'-1])) * (1-.5*(1-r[`i'])) ///
					* ( (1-p[`u'-1])/((p_star[`u'-1]+p[`u'-1])*n_prime[`u'-1]) /// 
					+ (se_temp[`u'-1] - se_ptemp[`u'-1]) )  
			}
		}
		svmat COV_CPDO, names(t)
		drop t1
		forval i = 3/`n' {
			local u = `i' - 1
			replace t`i' = t`i'+ t`u'  
		}
		forval i = 2/`n' {
			replace t`i' = sum(t`i')
		}
		replace se_ci_do = sum(se_p_do^2) if `grp'==`l'
		forval i = 2/`n' {
			replace se_ci_do = sqrt(se_ci_do + 2*t`i'[_N]) if _n == `i' & `grp'==`l'
			drop t`i'
		}
		replace se_ci_do = sqrt(se_ci_do) if _n==1 & `grp'==`l'
* log(-log) confidence bounds - JB Choudhury, Stat in Med 2002; 21: 1129 
		if "`cilog'" == "" {
			replace hi_ci_dc = 	ci_dc^exp(`level'*se_ci_dc/(ci_dc*log(ci_dc)))  if `grp'==`l'  
			replace lo_ci_dc = 	ci_dc^exp(-`level'*se_ci_dc/(ci_dc*log(ci_dc))) if `grp'==`l' 
			replace hi_ci_do = 	ci_do^exp(`level'*se_ci_do/(ci_do*log(ci_do)))  if `grp'==`l' 
			replace lo_ci_do = 	ci_do^exp(-`level'*se_ci_do/(ci_do*log(ci_do))) if `grp'==`l' 
		}
		else {
			generate lo_cp=cond(missing(cp),.,cond(cp<=0,0, cp*exp(-se_cp*`level'/cp)))
			replace hi_ci_dc = 	ci_dc*exp(`level'*se_ci_dc/ci_dc)  if `grp'==`l'  
			replace lo_ci_dc = 	ci_dc*exp(-`level'*se_ci_dc/ci_dc) if `grp'==`l' 
			replace hi_ci_do = 	ci_do*exp(`level'*se_ci_do/ci_do)  if `grp'==`l' 
			replace lo_ci_do = 	ci_do*exp(-`level'*se_ci_do/ci_do) if `grp'==`l' 
		}
*		drop se_ci_do se_ci_dc
	}
	generate F = 1 - cp
	label var hi_ci_dc "Upper 95% CI for ci_dc"
	label var lo_ci_dc "Lower 95% CI for ci_dc"
	label var hi_ci_do "Upper 95% CI for ci_do"
	label var lo_ci_do "Lower 95% CI for ci_do"
	label var se_ci_dc "Standard Error for ci_dc"
	label var se_ci_do "Standard Error for ci_do"
	label var F "F=1-cp, Cumulative incidence of death due to any cause"
end
