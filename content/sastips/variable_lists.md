+++
date = "1999-03-09"
lastmod = "2019-03-09"
title = "SAS Tips: using SAS variable lists"
author = "Paul Dickman"
summary = "SAS supports three types of abbreviated variable lists, numbered range lists (specified using one dash), name range lists (specified using two dashes), and special name lists."
shortsummary = "" 
tags = ["SAS","SAStips"]
+++

When a series of variables is being referred to, the use of an
abbreviated variable list can save a great deal of time. SAS supports
three types of abbreviated variable lists, numbered range lists (specified
using one dash), name range lists (specified using two dashes), and
special name lists.

<b>1. Numbered range lists

</b><font face="Courier New">VAR1-VAR5</font> is equivalent to <font face="Courier New">VAR1
VAR2 VAR3 VAR4 VAR5. </font>If you use this type of variable list then all
variables must exist.

<b>2. Name range lists

</b><font face="Courier New">X--A </font>refers to all variables between <font face="Courier New">X</font>
and <font face="Courier New">A</font> inclusive, according to the order of
the variables in the PDV (program data vector). That is, according to the
SAS internal variable order.

<font face="Courier New">X-numeric-A </font>refers to all numeric
variables between <font face="Courier New">X</font> and <font face="Courier New">A
</font>inclusive and <font face="Courier New">X-character-A </font>refers
to all character variables between X and A inclusive.

The SAS internal sort order is the order in which SAS encountered the
variables in the data step which created the SAS data set. If the SAS data
set was created by, for example, reading a text file, the internal order
will be the order in which the variables were read in. This makes it easy
to access, for example, the variables representing a series of questions
in a questionnaire.&nbsp;

The internal order of the variables can be determined using the
POSITION option on PROC CONTENTS.

```sas
proc contents data=hit.cases position;

run;
```

This will result in one list of variables in alphabetical order
(the default ordering for PROC CONTENTS) and a second list according to
the internal order.

Variables in the VAR windows (type, for example, <font face="Courier New">var
hit.cases</font> in the command line) will, by default, be ordered by the
internal order.

<b>3. Special SAS name lists</b>

These include all variables of a particular type. For example `_CHARACTER_`,
`_NUMERIC_`, and `_ALL_`.

<b>Examples of usage</b>

```sas
drop x--a;
proc means;
var _numeric_;
run;

proc print;
var pnr name week1-week12;
run;

proc freq;
var pnr--age;
run;
```
<b>Reference</b>

SAS Language, version 6, first edition, pages 111-113.

## **Index**
- [Index of SAS tips and tricks](/sastips/)


