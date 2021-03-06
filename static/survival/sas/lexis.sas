/**************************************************************************
Author: Bendix Carstensen, 1999-2002
Update: Paul Dickman, BxC, November 2003
Bug-fix: BxC, December 2007:
         If the origin= argument had missing values erroneous output would
         be generated (too much risk time). Now remedied so that
         observations with missing values of origin are excluded.
This macro is in: http://www.biostat.ku.dk/~bxc/Lexis/Lexis.sas
Example program:  http://www.biostat.ku.dk/~bxc/Lexis/xLexis.sas 
***************************************************************************/

%macro Lexis ( data = ,       /* Data set with original data,             */
                              /*    defaults to _last_                    */
                out = ,       /* Where to put the result,                 */
                              /*    defaults to &data.                    */
              entry = entry,  /* Variable holding the entry date          */
               exit = exit,   /* Variable holding the exit date           */
               fail = fail,   /* Variable holding the exit status         */
                              /* If any of the entry, exit or fail        */
                              /*    variables are missing the person is   */
                              /*    discarded from the computations.      */
             breaks = ,       /* Specification of the cutpoints on        */
                              /*    the transformed scale.                */
                              /*    Syntax as for a do statement.         */
                              /*    The ONLY Mandatory argument.          */
               cens = 0,      /* Code for censoring (may be a variable)   */
              scale = 1,      /* Factor to transform from the scale       */
                              /*    of entry and exit to the scale        */
                              /*    where breaks and risk are given       */
             origin = 0,      /* Origin of the transformed scale          */
               risk = risk,   /* Variable recieving the risk time         */
              lrisk = lrisk,  /* Variable recieving the log(risk time)    */
               left = left,   /* Variable recieving left  endpoint of int */
              other = ,       /* Other dataset statements to be used such */
                              /*     as: %str( format var ddmmyy10. ; )   */
                              /*     or: %str( label risk ="P-years" ; )  */
               disc = discrd, /* Dataset holding discarded observations   */
           /*-------------------------------------------------------------*/
           /* Variables for making life-tables and other housekeeping:    */
           /* These will only appear in the output dataset if given here  */
           /* The existence of these arguments are tested in the macro so */
           /* they cannot have names that are also logical operators such */
           /* as: or, and, eq, ne, le, lt, gt.                            */
           /*-------------------------------------------------------------*/
              right = ,       /* Variable recieving right endpoint of int */
               lint = ,       /* Variable recieving interval length       */
            os_left = ,       /* Variable recieving left  endpoint of int */
           os_right = ,       /* Variable recieving right endpoint of int */
            os_lint = ,       /* Variable recieving interval length       */
                              /*    - the latter three on original scale  */
               cint = ,       /* Variable recieving censoring indicator   */
                              /*    for the current input record          */
               nint =         /* Variable recieving index of follow-up    */
                              /*       interval;                          */
              );

%if &breaks.= %then %put ERROR: breaks MUST be specified. ;
%if &data.  = %then %let data = &syslast. ;
%if &out.   = %then %do ;
                    %let out=&data. ;
                    %put
NOTE: Output dataset not specified, input dataset %upcase(&data.) will be overwritten. ;
                  %end ;

data &disc. &out. ;
  set &data. ;
  if ( nmiss ( &entry., &exit., &fail., &origin. ) gt 0 ) 
     then do ; output &disc. ;
               goto next ;
          end ;
  * Labelling of variables ;
  label &entry.  = 'Entry into interval' ;
  label &exit.   = 'Exit from interval' ;
  label &fail.   = 'Failure indicator for interval' ;
  label &risk.   = 'Risktime in interval' ;
  label &lrisk.  = 'Natural log of risktime in interval' ;
  label &left.   = 'Left endpoint of interval (transformed scale)' ;
%if    &right.^= %then  label &right. = 'Right endpoint of interval (transformed scale)' ; ;
%if     &lint.^= %then  label &lint. = 'Interval width (transformed scale)' ; ;
%if  &os_left.^= %then  label &os_left. = 'Left endpoint of interval (original scale)' ; ;
%if &os_right.^= %then  label &os_right. = 'Right endpoint of interval (original scale)' ; ; 
%if  &os_lint.^= %then  label &os_lint. = 'Interval width (original scale)' ; ;
%if     &cint.^= %then  label &cint. = 'Indicator for censoring during the interval' ; ;
%if     &nint.^= %then  label &nint. = 'Sequential index for follow-up interval' ; ;
  &other. ;
  drop _entry_ _exit_ _fail_
       _origin_ _break_
       _cur_r _cur_l _int_r _int_l
       _first_ _cint_ _nint_;

/*
Temporary variables in this macro:

  _entry_  holds entry date on the transformed timescale
  _exit_   holds exit  date on the transformed timescale
  _fail_   holds exit  status
  _break_  current cut-point
  _origin_ origin of the time scale
  _cur_l   left  endpoint of current risk interval
  _cur_r   right endpoint of current risk interval
  _int_l   left  endpoint of current break interval
  _int_r   right endpoint of current break interval
  _first_  indicator for processing of the first break interval
  _cint_   indicator for censoring during the interval
  _nint_   sequential index of interval
   
If a variable with any of these names appear in the input dataset it will
not be present in the output dataset.
*/

  _origin_ = &origin. ;
  _entry_  = ( &entry. - _origin_ ) / &scale. ;
  _exit_   = ( &exit.  - _origin_ ) / &scale. ;
  _fail_   = &fail. ;
  _cur_l   = _entry_ ;
  _first_  = 1 ;

  do _break_ = &breaks. ;
     if _first_ then do ;
        _nint_=-1;
        _cur_l = max ( _break_, _entry_ ) ;
        _int_l = _break_ ;
     end ;
     _nint_ + 1;
     _first_ = 0 ;
     _int_r = _break_ ;
     _cur_r = min ( _exit_, _break_ ) ;
     if _cur_r gt _cur_l then do ;
/*
Endpoints of risk interval are put back on original scale.
If any of left or right are specified the corresponding endpoint
of the break-interval are output.
*/
        &entry.  = _cur_l * &scale. + _origin_ ;
        &exit.   = _cur_r * &scale. + _origin_ ;
        &risk.   = _cur_r - _cur_l ;
        &lrisk.  = log ( &risk. ) ;
        &fail.   = _fail_ * ( _exit_ eq _cur_r ) +
                   &cens. * ( _exit_ gt _cur_r ) ;
        _cint_   = not( _fail_ ) * ( _exit_ eq _cur_r ) ;            
        %if     &left.^= %then &left.     = _int_l ; ;
        %if    &right.^= %then &right.    = _int_r ; ;
        %if     &lint.^= %then &lint.     = _int_r - _int_l ; ;
        %if  &os_left.^= %then &os_left.  = _int_l * &scale. + _origin_ ; ;
        %if &os_right.^= %then &os_right. = _int_r * &scale. + _origin_ ; ; 
        %if  &os_lint.^= %then &os_lint.  = ( _int_r - _int_l ) * &scale. ; ;
        %if     &cint.^= %then &cint.     = _cint_ ; ;
        %if     &nint.^= %then &nint.     = _nint_ ; ;
        output &out. ;
     end ;
     _cur_l = max ( _entry_, _break_ ) ;
     _int_l = _break_ ;
  end ;
  next: ;
run ;

%mend Lexis ;
