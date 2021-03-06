+++
date = "1999-03-09"
lastmod = "2019-03-09"
title = "SAS Tips: Using AUTOEXEC.SAS to customise your session"
author = "Paul Dickman"
summary = "The autoexec file contains SAS statements that are executed automatically when you invoke SAS."
shortsummary = "" 
tags = ["SAS","SAStips"]
+++

<p>At startup, SAS looks for a file called AUTOEXEC.SAS. If the file is found, then the
SAS statements in the file will be processed. This is useful for setting global options
and defining data libraries (libnames) at the beginning of a SAS session.</p>
<p>A typical AUTOEXEC.SAS might contain an options statement and several libname
statements. For example:</p>

```sas
libname project 'c:\project';
libname paul    'c:\paul';
libname formlib 'c:\formats';

options nocenter fmtsearch=(formlib project);
```

<p>Note that AUTOEXEC.SAS is processed once, when the SAS application is started, and not
every time SAS commands are submitted.</p>
<p>AUTOEXEC.SAS is not the best place for storing SAS macros. These should be kept in a <a href="/sastips/autocall/">SAS autocall library</a>.</p>
<p>The best place to store AUTOEXEC.SAS is in the SAS root directory (usually
C:\SAS).&nbsp; If you are running SAS from a server, or want to use a name for the file
other than AUTOEXEC.SAS, you can specify the location of AUTOEXEC.SAS in the SAS startup
command. For example:</p>
<pre>G:\SAS\SAS.EXE -AUTOEXEC C:\SAS\MYAUTO.SAS</pre>

## **Index**
- [Index of SAS tips and tricks](/sastips/)

