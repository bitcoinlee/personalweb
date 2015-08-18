/******************************************************************/
/******************************************************************/
/***  Code File   : words.sas                                    **/
/***  Program Name: Count array items                            **/
/***  %sysfunc(countw()) alternative                             **/
/******************************************************************/
/******************************************************************/
/*** Inputs                                                      **/
/*** ------                                                      **/
/*** str           : Input String Array	                         **/
/*** delim         : Delimiter of array                          **/
/******************************************************************/
/******************************************************************/

%macro words(str,delim=%str( ) )  ;
  %local  str delim i ;	
  %let i = 1 ;
  %do %while(%length(%qscan(&str,&i,&delim)) GT 0);
    %let i = %eval(&i + 1);
  %end;
  %eval(&i.-1)
%mend words ;