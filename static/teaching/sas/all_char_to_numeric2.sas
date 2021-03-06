* This is a routine that will convert all character;
* data in file T1 to numeric, and then store the result;
* with the original variable names in a dataset called T2.;
* Original author unknown, modified by Dave P (FKAPrince@aol.com);

* Generate some test data;
data T1;
  retain a b c d e f g '00000000' numvar 4 numx1-numx5 8;
run;

proc contents data=T1;	 * Print out contents for reference;
run;

proc sql noprint;

  * The next few lines...;
  * create a list of all variables of type char and put it in the macro variable 'varname';
  * create a list of temporary numeric variables and put it in the macro variable 'numname';
  * create a string that will be used to rename work variables, with entries like "_v2 = age";
  *   and put this string in macro variable 'ren1';
  * note dataset name must be in ALL CAPS;

  select  compress(name) ,
          compress('_v'||put(varnum,5.)) ,
          compress('_v'||put(varnum,5.))||'=' || compress(name)
    into: varname separated by ' ' ,
        : numname separated by ' ' ,
        : ren1 separated by ' '
    from dictionary.columns
  where libname="WORK" and memname='T1' and type= 'char';

  * put the number of variables of type char into a macro variable called 'nvar';

  select compress(put(count(name),5.)) as cnt into : nvar
    from dictionary.columns
  where libname="WORK" and memname='T1' and type='char';
quit;

data t2(rename=(&ren1));			* renaming temporary _vx variables back to original names;
  set t1;
  array charvar &varname;			* create an array to hold names of all char variables;
  array tempvar &numname;			* create an array to hold names of temporary numeric vars;

  do count = 1 to &nvar;			* for each character variable...;
    tempvar[count] = input(charvar[count],best.);* let the temporary variable be a numeric conversion of the original;
  end;
  drop count &varname;				* drop the character originals;
run;

proc contents data=T2;
run;
