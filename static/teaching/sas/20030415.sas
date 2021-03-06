***** SAS seminar 2003-04-15 *******;

libname seminar 'H:\sas seminarium\';

data seminar.diet_raw2;
  set seminar.diet_raw;
	bmonth=MONTH(DOB);
	bday=DAY(DOB);
	byear=YEAR(DOB);
run;

/* start using the dataset seminar.diet_raw2 */


/* CHAPTER 3: WORKING WITH YOUR DATA */

* 3.1 Creating and redefining variables;
data diet;
  set seminar.diet_raw2;
  
  	x=10;      /* all observations will have the same value  10, x is a
				numerical variable  */
  	z='tio';   /* all observations will have the same value tio, z is a 
				character variable*/
  	height_m=height/100;   /* standard operators +,-,*,/,**(=exponentia-
							tion) */
  						 /* creating a variable for the height measured 
							in meters */
   
  	bmi=weight/height_m**2; /* new variable defined from existing 
							variables */

run;
proc print data=diet(obs=20);
	var x z height height_m bmi;
run;


* 3.2 and 3.3 Using SAS functions / Selected SAS functions;
data diet; 
  set diet;
  
  	weightavg=mean(weight1, weight2);  * mean of weight measurements 1,2;
  	ln_weight=log(weightavg);             * takes natural logarithm of 
											weight. Note: LOG10(weight) 
											is logarithm to the base 10 ;
  	weight_rounded=round(weightavg,.1);   * weight with one decimal. 
											Note: SAS gives the integer 
  										  	when no round-off-unit is 
											specified, ;
run;
proc print data=diet (obs=20);
  var weight1 weight2 weightavg ln_weight weight_rounded;
run;


* 3.7 Working with SAS-dates ;
data diet;
 set diet;
	birthdate=MDY(bmonth,bday,byear);
	todaysdate=today();
	format todaysdate date8.;
run;
proc print data=diet (obs=20);
	var bmonth bday byear birthdate todaysdate;
run;


* 3.4/3.5 IF-THEN statements, DO-loop, Grouping observations;
data diet;
  set diet;

	*creating variable HIGHSES: high socio-economic status;
	if job='banker' then highses=1;
  		else if job='conductor' or job='driver' then highses=0;
  		else highses=.; *for all observations that don't fall into one 
						of the specified conditions, if any;
  
	if id in (36, 157) then chd=.;   	/*if you want to make specific 
										changes in certain observations. 
										This is equal to writing if id=36
										or id=157 then chd=.;  */
	if id in (36, 157) then do;		/* if you want to make several 
									changes: use a DO-END statement */
    	chd=.;
   		age=.;
        bmi=.;
    end;

	if age>65 and job='banker' then ret_banker=1;
	if age<15 or age>65 then unemployed=1;	

	*for subset analyses: Unemployed cases;
	if (age<15 or age>65) and chd=1 then unemp_chd=1; *USE parentheses!;
  
	if 0<=bmi<20 then bmicat=1;
  		else if 20<=bmi<25 then bmicat=2;
  		else if 25<=bmi then bmicat=3;
  		else bmicat=.;
run;
proc print data=diet (obs=20);
	var bmi bmicat job highses;
run ;


* 3.6 Subsetting your data;
* subsetting-IF <=> permanent subsetting ;

* two ways to subset a data set;
* Keeping obs;
data diet_retired;
  set diet;
  	if age>65; *subsetting IF;
run;

* Removing obs;
data diet_retired;
  set diet;
  	if age<=65 then delete; * DELETE statement;
run;


/* CHAPTER 4: Sorting, Printing and Summarizing you data */

/* the statements LABEL, TITLE and FOOTNOTE */
proc contents data=diet;
	Title 'Variable list for dataset DIET';
	FOOTNOTE 'SAS seminar April 15, 2003';
	label hieng ='Energy intake per day. High=1, Low=0';
run;
goptions reset=title;


/* 4.3 Sorting your data with PROC SORT 
   4.4 Printing your data with PROC PRINT */
Proc sort data=diet out=diet_sorted;
	by bmicat job ;
run;
proc print data=diet_sorted (obs=20);
   by bmicat;
   sum hieng;    /* prints the sums of the variables in the statement */	
   var chd age hieng weight ;
run;


/* creating your own formats */
proc format; 
	value agegrp
		0-18='young'
		26-65='adult'
		65-HIGH='old'
		OTHER='missing or error'
		;
	value bmicat	
		1='low'	
		2='medium'	
		3='high'
		;
	value status
		1='case'
		0='control'
		other='unknown'
		;
run; 
proc print data=diet_sorted (obs=20);
   var chd age hieng weight bmicat;
   format bmicat bmicat. chd status. age agegrp.; 
   /* assigns a format to each variable */
run;

/* summarizing your data using PROC MEANS */
proc means data=diet median mean stddev min max maxdec=1;
	class hieng;
	var weight height energy;
run;
proc means data=diet NOPRINT;
	class hieng job;
	var weight height energy;
	OUTPUT OUT=diet_statistics mean(weight height)=wght_average hgt_average 
						   	   max(weight height)=wght_max hgt_max
						       min(weight height)=wght_min hgt_min;
run;
proc print data=diet_statistics;
run;


/* 4.11 counting your data with PROC FREQ */
proc freq data=diet;
	tables bmicat*chd / missing ;
run;
proc freq data=diet;
	tables bmicat*chd / missing list;
run;
proc freq data=diet;
	tables age*chd /missing; /*continuous data can be used if assigned a format 
					that creates categories */
	format age agegrp.;
run;