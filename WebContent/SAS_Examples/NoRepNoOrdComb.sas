/******************************************************************/
/******************************************************************/
/***  Code File   : NoRepNoOrdComb.sas                           **/
/***  Program Name: No Repetition No Order Combination Algorithm **/
/******************************************************************/
/*** Created: 06/26/2014 	                                 **/
/*** By: Sotiris Papazerveas                                     **/
/******************************************************************/
/*** Macro Dependencies                                          **/
/*** ------------------                                          **/
/*** %words                                                      **/
/*** %unique                                                     **/
/******************************************************************/
/*** Inputs                                                      **/
/*** ------                                                      **/
/*** Arrin         : Input String Array	(space separated)        **/
/*** r       	   : the number of items to choose               **/
/*** InCombDLM     : Delimiter inside the combination item       **/
/*** CrossCombDLM  : Delimiter between combination               **/
/*********************************************************************************/
/* Initial Algorithm idea from:                                                 **/
/* http://stackoverflow.com/questions/7198154/combination-algorithm-in-excel-vba */
/*********************************************************************************/ 



%macro UnComb(Arrin, r , InCombDLM = %str( ), CrossCombDLM =%str(-) )  ;

	%local 
		pool
		TempVal
		idx 
		i
		j
		result
		Arrin
		n
		InCombDLM
		TempIdx
		r
		CrossCombDLM
		;
	
	%let pool = %unique(&Arrin);
	%let n = %words(&pool);
	%if &r > &n %then %do;
		%put ERROR: Maximum number for r is &n. ;
		%let result = %str();
		%goto exit;
	%end;
	%do i = 1 %to &r;
		%let idx =&idx &i;
	%end;
	%do %while (&i > 0);
		%do j = 1 %to &r;
			%if %length(&result) %then %do;
				%if &j = 1 %then %let result=&result.%scan(&pool , %scan(&idx , &j));
				%else  %let result=&result.&InCombDLM.%scan(&pool , %scan(&idx , &j));
			%end;
			%else %let result=%scan(&pool , %scan(&idx , &j));
		%end;	
		%let result=&result.&CrossCombDLM.;
		
		/*Locate the non-max index position*/
		%let i = &r ;
		%do %while ( %scan(&idx , &i) = %eval(&n - &r + &i));
			%let i = %eval(&i - 1);
			 /*All indexes have reached their max, so we're done*/
			%If &i = 0 %Then  %goto exit;
		%end;
		
		/*Increase the non-max index position*/
		%let TempIdx = %str();
		%do j = 1 %to &r;
			%if &j=&i %then %let TempVal = %eval(%scan(&idx , &j) + 1) ;
			%else %let TempVal =%scan(&idx , &j) ;
			%let TempIdx = &TempIdx. &TempVal. ;
		%end;	
		
		/*populate the following indexes accordingly*/
		%let idx =&TempIdx ;
		%let TempIdx = %str();
		%do j = 1 %to %eval(&i );
			%let TempIdx = &TempIdx. %scan(&idx , &j) ;
		%end;
		%do j = %eval(&i + 1) %to &r;
			%if %words( &TempIdx. ) = &r %then %goto exitfor;
			%let TempIdx =&TempIdx. %eval(%scan(&idx , &i) + &j - &i) ;
		%end;
		%exitfor:
		%let idx =&TempIdx ;
	%end;
	%exit:
	%substr(&result , 1 , %length(&result) - 1)

%mend UnComb;
/*
%put %words(%UnComb(ena dio tria ena tessera pente eksi efta okto ennea deka , 3) , delim = %str(-));
*/
