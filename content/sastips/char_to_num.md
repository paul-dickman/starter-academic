+++
date = "1999-03-09"
lastmod = "2019-03-09"
title = "SAS Tips: Converting variable types from character to numeric (and vice versa)"
author = "Paul Dickman"
summary = "Converting variable types from character to numeric (and vice versa)"
shortsummary = "" 
tags = ["SAS","SAStips"]
+++
 
## Should data be stored in a variable of type character or numeric?
    
Obviously, if a variable contains non-numeric information (e.g., names) then it should be
saved as a SAS character variable. If the variable contains real numeric data which will
be used in numeric calculations, such as weight or height, then it should be stored in a
numeric variable.

If a variable contains integer data which will not necessarily be used in any
calculations, such as ID number, it is preferable to save it as a variable of type numeric
rather than a variable of type character, even if you have no intention of performing
algebraic calculations using the variable. For a nominal variable, such as gender, it is
preferable to store this as a numeric variable with an appropriate format rather than a
character variable with, for example, values `M` and `F`.

It is preferable to use numeric variables whenever possible since this eliminates the
need to consider leading and trailing blanks when making comparisons. For example, if
numeric data are stored in a character variable of length 4, then the value `2bbb` (where `b` represents a space (blank)) is considered to be greater than `1865`. 
    
Similarly, the character constant `bbb2` is not the same as `2bbb`. As such, the
following expression

<pre>if id='   2' then delete;</pre>

may not have the desired result (id is a character variable of length 4). It is, of
course, possible to use the following code

<pre>if id=2 then delete;</pre>

where we are instructing SAS to compare the value of a character variable to a numeric
constant. When presented with this code, SAS first converts the value of id from
character to numeric and then compares the resulting value to the numeric constant 2. This
is known as an implicit type conversion, and causes the following note in the log:

<pre>NOTE: Character values have been converted to numeric values at the 
       places given by: (Line):(Column).</pre>

Using implicit type conversions is poor programming practice and should be avoided
(some would say at all costs).

## Which type uses the least storage space?

If the data are integer and contain more than three digits, they can be stored using less
space (length) in a numeric variable than a character variable. The minimum length for
numeric variables (where length refers to the number of bytes allocated by SAS for storing
the variable) under SAS/Windows is 3, so variables containing less than 3 digits can be
stored using less space as character variables (where the minimum length is 1).

Swedish civil registration numbers, for example, which contain 10 digits, can be stored
in a numeric variable of length 6, whereas 10 bytes would be required if it was stored as
a character variable (see my notes on the <a href="/sastips/length/">LENGTH statement</a>).

## Converting variable types from character to numeric

Numeric data are sometimes imported into variables of type character and it may be
desirable to convert these to variables of type numeric. Note that it is not possible to
directly change the type of a variable. It is only possible to write the variable to a new
variable containing the same data, although with a different type. By renaming and
dropping variables, it is possible to produce a new variable with the same name as the
original, although with a different type.

A naive approach is to multiply the character variable by 1, causing SAS to perform an
implicit type conversion. For example, if charvar is a character variable then the code

<pre>numvar=charvar*1;</pre>

will result in the creation of a new variable, numvar, which will be of type numeric.
SAS performs an implicit character to numeric conversion and gives a note to this effect
in the log. This method is considered poor programming practice and should be avoided. A
preferable method is to use the INPUT function. For example:

<pre>numvar=input(charvar,4.0);</pre>

The following SAS code demonstrates character to numeric and numeric to character
conversion.

```sas    
data temp;
length char4 $ 4;
input numeric char4;

/* convert character to numeric */
new_num=input(char4,best4.);

/* convert numeric to character */
new_char=put(numeric,4.0);

cards;
789 1234
009 0009
1 9999
;;

proc print;
run;
```

If the character variable char4 in the above example contains missing values of
non-numeric data then the value of new_num will be missing. When char4 contains
non-numeric data, an 'invalid argument' note will be written to the log. This note can be
suppressed using the ?? format modifier as in the code below

<pre>new_num=input(char4, ?? best4.);</pre>

[Click here](../char_to_num.sas) to download some sample code illustrating
this.

The INPUT statement is also the best method for converting a character string
representing a date (e.g. `990719`) to a SAS date variable (see the example <a href="/sastips/age_dx/">here</a>).

<p>The INPUT statement is also more efficient than the implicit conversion method with
respect to CPU time.</p>
<p><strong>Creating a variable with the same name as the original but with a different
type</strong><br>
Note that it is not possible to directly change the type of a variable. You must create a
new variable of the desired type. However, a technique is shown below whereby drop and
rename statements are used so that the new dataset contains a variable of the same name
but with a different type.</p>

```sas
data temp;
length id $ 4;
input id;
cards;
1234
0009
9999
;;
run;

data new(drop=x);
set temp(rename=(id=x));
id=input(x,best4.);
run;

proc print data=new;
run;
```
<p><a href="../all_char_to_numeric2.sas">Click here</a> to download some SAS
    code for efficiently converting the type of a large number of variables from
    character to numeric.</p>
<p><strong>Be careful with data containing decimals points!</strong><br>
    Care needs to be taken when specifying the informat used with the input function,
    especially when your data contain decimal points. Consider the following example (which
    can be downloaded <a href="../char_to_num_informat.sas">here</a>):</p>

```sas
data test;
length x $ 6;
input x;
y61=input(x,6.1);
best61=input(x,best6.1);
y60=input(x,6.0);
best60=input(x,best6.0);
cards;
.001
0.01
10
100
10.0
1E3
1.52E3
;
```
This produces the following data:

```sas
OBS     X          Y61    BEST61      Y60   BEST60
 1    .001       0.001     0.001     0.00     0.00
 2    0.01       0.010     0.010     0.01     0.01
 3    10         1.000     1.000    10.00    10.00
 4    100       10.000    10.000   100.00   100.00
 5    10.0      10.000    10.000    10.00    10.00
 6    1E3      100.000   100.000  1000.00  1000.00
 7    1.52E3  1520.000  1520.000  1520.00  1520.00
```
<p>When reading data using the w.d informat where a value for d is specified, SAS will
divide the input by 10^d if the input does not contain a decimal point. If the input does
contain a decimal point then it is left unchanged.<br>
<br>
[As an aside, I cannot locate any reference to a BESTw.d informat in the SAS documentation
(version 6 language reference 1st ed. or online documentation for 6.12/windows), yet SAS
processes the above code without errors.]<br>
</p>

## For further information:

SAS Language, Reference, v6 ed. 1, pp. 556-7 (INPUT function)<br>
SAS Language, Reference, v6 ed. 1, pp. 584-5 (PUT function)<br>
Combining and Modifying SAS data sets, pp. 148-154</p>
<p><a href="../all_char_to_numeric2.sas">SAS code</a> for converting the type
of many variables.&nbsp;</p>

## A macro for converting all variables in a data set

A macro from SAS Institute for converting all variables in a SAS data set from type
character to numeric [<a href="../all_char_to_numeric.sas">click here to download</a>].</p>

## **Index**
- [Index of SAS tips and tricks](/sastips/)


