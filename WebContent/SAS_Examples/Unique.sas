/******************************************************************/
/******************************************************************/
/***  Code File   : Unique.sas                                   **/
/***  Program Name: Unique items of an Array                     **/
/******************************************************************/
/*** Created: 10/03/2014 	                                 **/
/*** By: Sotiris Papazerveas                                     **/
/******************************************************************/
/*** Macro Dependencies                                          **/
/*** ------------------                                          **/
/*** %words                                                      **/
/******************************************************************/
/*** Inputs                                                      **/
/*** ------                                                      **/
/*** string        : Input String Array	                         **/
/*** casesens      : Case Sensitivity:      Yes/ No              **/
/*** delim         : Delimiter of array                          **/
/******************************************************************/
/******************************************************************/

%macro Unique(string , casesens=NO , delim=%str( ) )  ;


	%local 
		string
		UniqueWords
		casesens
		delim
		FoundMatch
		sword
		uword
		;

	%if not %length(&casesens) %then %let casesens=no;
	%let casesens=%upcase(%substr(&casesens,1,1));
	
	%do i = 1 %to %words(&string. ,delim=&delim. ) ;
		%let FoundMatch = 0 ;
		%let sword = %scan(&string,&i,&delim.);
		 %do k = 1 %to %words(&UniqueWords. ,delim=&delim. ) ;
			%let uword=%scan(&UniqueWords,&k,&delim.);
			%if "&casesens" EQ "Y" %then %do;
				 %if "&uword" EQ "&sword" %then %do;
				 	%let FoundMatch = 1 ;
					%goto nextitem;
				 %end;
			%end;
			%else %do;
				 %if "%upcase(&uword)" EQ "%upcase(&sword)" %then %do;
				 	%let FoundMatch = 1 ;
					%goto nextitem;
				 %end;
			%end;
		%end ;
		%nextitem:

		%if &FoundMatch = 0 %then %do;
			%if %length(&UniqueWords.) %then %let UniqueWords = &UniqueWords.&delim.&sword;
			%else %let UniqueWords = &sword;
		%end; 
	%end;
	&UniqueWords
	
%mend Unique;