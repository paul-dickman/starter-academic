/*****************************************************************
Posted to SAS-L on 1999/08/25 by shiling <shiling@math.wayne.edu>
******************************************************************/

data t1;
  retain a b c d e f g '00000000';
run;

proc sql;
  select  compress(name) ,
          compress('_v'||put(varnum,5.))||'=' || compress(name),
          compress(put(count(name),5.)) as cnt
    into: varname seperated by ' ' ,
        : ren1 seperated by ' ' ,
        : nvar
    from dictionary.columns
  where libname="WORK" and memname='T1'
;
quit;

data t2(rename=(&ren1));
  set t1;
  array charvar(&nvar) &varname;
  array _v(&nvar);
    do i = 1 to dim(charvar);
       _v(i)=input(charvar(i),best.);
    end;
   keep _v1-_v&nvar;
run;
