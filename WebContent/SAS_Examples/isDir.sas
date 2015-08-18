/******************************************************************/
/******************************************************************/
/***  Code File   : isDir.sas                                    **/
/***  Program Name: Checks if path is directory                  **/
/******************************************************************/
/*** Created: 02/07/2013 	                                 **/
/*** By: Sotiris Papazerveas                                     **/
/******************************************************************/
/*** Inputs                                                      **/
/*** ------                                                      **/
/*** Path          : Path Location                               **/
/*** Quiet =       : Write sysmsg to log boolean (0/1)           **/
/******************************************************************/
/******************************************************************/

%macro isDir(Path=,Quiet=1) ;

  %local result dname;

  %let result = 0;

  %if %sysfunc(filename(dname,&Path)) eq 0 %then %do;
    %if %sysfunc(dopen(&dname)) %then %do;
      %let result = 1;
    %end;
    %else %if not &Quiet %then %do;
      %put ERROR: ISDIR: %sysfunc(sysmsg());
    %end;
  %end;
  %else %if not &Quiet %then %do;
    %put ERROR: ISDIR: %sysfunc(sysmsg());
  %end;

  &result

%mend isDir;