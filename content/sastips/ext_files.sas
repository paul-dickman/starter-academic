*-----------------------------------------------------------------;
* Send output to external file                                    ;
*-----------------------------------------------------------------;

data t2; /* As t1 but two treatment groups */
  label y='BP (mmHg)' x='Time (hours)' group='Treatment' z='Pain';
  retain seed 3240877;
  do group=1 to 2;
    do x=1 to 10;
      y=x+normal(seed);
      z=-x-normal(seed);
      output;
    end;
  end;
run;

*-- Empty the default graph output catalog;
proc datasets lib=work mt=cat nolist;delete gseg;quit;

filename gsasfile "C:\SLASK\";

goptions reset=all;
goptions device=png display rotate=L gwait=0 targetdevice=png gsfname=gsasfile;
proc gplot data=t2;
  plot y*x / name='HEPP';
  by group;
run;quit;


proc greplay igout=gseg nofs;
  replay _all_;
run;quit;
