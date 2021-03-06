
/* from http://www.sas.com/service/techsup/faq/data_step/workwith267.html */

/*test data, ALL character data*/
data chardata;
x='12345';y='0987'; output;
a='3';b='4';output;
run;

/*var names and position*/
proc contents noprint data=chardata out=varname(keep=name npos);
run;

/* sort by pos in the data set, yields vars
   in the order they appear in the data set*/
proc sort;
by npos;
run;

data _null_;
 do i=1 to nobs;
   set varname nobs=nobs end=end;
    call symput('mac'||left(put(i,4.)),name);     /*creates macro variables for name of vars*/
    call symput('num'||left(put(i,4.)),'num'||left(put(i,4.)));   /*creates new macro numeric vars*/
     if end then call symput('end',put(nobs,8.));   /*determines number of variables, 1 per obs*/
 end;         /*assumes none of char vars are larger than 8 bytes*/
run;


/*macro generates the drop and rename, so numeric vars have original names*/
%macro create;
 data numdata(drop= %do i=1 %to &end;&&mac&i %end;
            rename=(%do i=1 %to &end; &&num&i=&&mac&i  %end;));
     %do i=1 %to &end;
        set chardata ;
        /*create numeric macro vars, which resolve to num1-num5*/
        &&num&i=input(&&mac&i,5.);
     %end;
 run;
%mend;

%create;

/*verify that the new data set contains all numeric vars*/
proc contents data=numdata;
run;
