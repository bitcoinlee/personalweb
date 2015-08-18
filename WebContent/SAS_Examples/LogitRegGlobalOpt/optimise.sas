/******************************************************************/
/******************************************************************/
/***  Code File   : optimise.sas                                 **/
/***  Program Name: Logit Regression With Global Optimization    **/
/**  (R to SAS Conversion)                                       **/
/******************************************************************/
/*** Created: 11/11/2014 	                                 **/
/*** By: Sotiris Papazerveas (SAS)                               **/
/******************************************************************/
/*** Inputs                                                      **/
/*** ------                                                      **/
/*** CurrentDir    : Update The Working Directory                **/
/*** DataCSV       : Update CSV Dataset                          **/
/*** OptimStep     : Set the Optimizing Step                     **/
/*** MaxIterations : Set the Maximum Iterations                  **/
/*** PreFactorVars : Set the Variables in the CSV that           **/
/***                 are before the factors. These will be       **/
/*** 		     Treated as Character Vars.                  **/
/*** GroupByVars   : By these vars the exp of coeff will be      **/
/***		     summarized  				 **/
/*** NumOfFactors  : Set the number of factors                   **/
/*** WinCriteria   : Specify the winning criiteria               **/
/*** Intercept     : Yes/No run model with/without intersept     **/
/*** Standardize    : Yes/No Standardize Factors	         **/
/******************************************************************/
/******************************************************************/ 


%macro Logit_With_Coeff_Optimization ( 
					CurrentDir 		= ,
					DataCSV			= Sample_Tested , 
					OptimStep 		= 0.01,
					MaxIterations		= 100 ,
					PreFactorVars    	= raceId rank,
					WinCriteria		= rank eq "1" ,
					GroupByVars		= raceId ,
					NumOfFactors		= 10 ,
					Intercept		= Yes ,
					Standardize		= No
					);
	
	/*Keep at the log only the needed info.*/
	%let MASTER_START_TIME = %sysfunc(datetime()) ;
	%let MprintOpt = %sysfunc(getoption(mprint) ) ;
	%let NotesOpt = %sysfunc(getoption(notes) ) ;
	%let SourceOpt = %sysfunc(getoption(source) ) ;
	options Nosource nomprint nonotes errors=0;
	
	/*Creates Log directory and pastes the log files*/
	%let CreatePath	= %sysfunc(dcreate( Logs ,  &CurrentDir. )) ;
	%let _CurrentDateTime   = Standardize_&Standardize._Intercept_&Intercept._%sysfunc(compress(%sysfunc(putn(%sysfunc(date()) , yymmdd10.))_%sysfunc(putn(%sysfunc(time()) , tod5. )) , ":-", s )) ;
	%let SASUser = &SYSUSERID ;

	proc printto 
		log =   "&CurrentDir.\Logs\&_CurrentDateTime._&SASUser..log"
		print = "&CurrentDir.\Logs\&_CurrentDateTime._&SASUser..lst"
		new 
		;
	run;	
	
	%let PreFactorNumericVarNum = %sysfunc(countw(&PreFactorVars.));
	%let GroupByVarNum = %sysfunc(countw(&GroupByVars.));
	
	
	/*Import the comma seperated data*/
	 data Df_Data (compress = binary);
	       infile "&CurrentDir.\&DataCSV..csv"
	       delimiter = ',' 
	       MISSOVER DSD lrecl=32767 
	       firstobs=2 
	       ;
	       input
		   %do i = 1 %to &PreFactorNumericVarNum.;
			%scan(&PreFactorVars. , &i) : $64.
		   %end;		   
		   %do i = 1 %to &NumOfFactors ;
			 factor&i. :best32.
		   %end;
		;
		 %do i = 1 %to &NumOfFactors ; 
			if factor&i. = . then delete;
		 %end;		
	run;


		%if %sysfunc(compress(%upcase(&Standardize.),Y,k)) eq Y %then %put Standardize Factors is Enabled;
		%else %put Standardize Factors is Disabled;	
		%if %sysfunc(compress(%upcase(&Intercept.),Y,k)) eq Y %then %put Intercept is Enabled;
		%else %put Intercept is Disabled;
	
	proc sql noprint undo_policy=none;
	
		
			
		/*Standardize Factors*/
			create table Df_Data (compress = binary) as
			select distinct

				%do i = 1 %to &PreFactorNumericVarNum. ;
					%scan(&PreFactorVars. , &i) ,
				%end;

				 %do i = 1 %to &NumOfFactors ;

				 	%if %sysfunc(compress(%upcase(&Standardize.),Y,k)) eq Y %then %do;
					case when std( factor&i.) = 0 
						then - factor&i.
						else ( factor&i. - mean( factor&i.) ) / std( factor&i.) end as
					%end;
					 factor&i. ,
				 %end;
				case when &WinCriteria. then 1 else 0 end as frank
			from 
				Df_Data
			;
		%end;
		
		/*Select Factors with Variation*/
		select distinct
			"" %do i = 1 %to &NumOfFactors ;
			 	||" "||case when std( factor&i.) > 0 then "factor&i." else "" end  
			 %end; ,
			"" %do i = 1 %to &NumOfFactors ;
			 	||" "||case when std( factor&i.) = 0 then "factor&i." else "" end  
			 %end;
			into :CoeffWithVar, :CoeffWithNoVar
		from 
			Df_Data
			;
	quit;

	/*Run logistic regression with Logit link function - Export coefficients at Model_Betas dataset*/
	proc logistic 
		data	= Df_Data
		descending 
		outest 	= Model_Betas 
		noprint
		;
		model  frank = &CoeffWithVar.	
		/ 
		%if %sysfunc(compress(%upcase(&Intercept.),Y,k)) ne Y %then %do;
			noint  
		%end;
		link=logit 
		;
	run;


	%if %sysfunc(compress(%upcase(&Intercept.),Y,k)) ne Y %then %let Vars = &CoeffWithVar. ;
	%else %let Vars = Intercept &CoeffWithVar. ;
	%let VarsNum = %sysfunc(countw(&Vars)) ;

	/*Divide Coefficients with Total Sum*/
	data beta0 (drop = TotalF) ;
	set Model_Betas (keep = &Vars.);
		
		TotalF = 0  %do i = 1 %to &VarsNum.; 
				+ %scan(&Vars , &i) 
				%end; ;
		
		 %do i = 1 %to &VarsNum.; 
			%let CurrVar = %scan(&Vars , &i) ;
			&CurrVar = &CurrVar / TotalF ;
		 %end;

	run;
		
	/*Global Optimization Function*/
	%macro Global_Optimization_Function(
						BetaTable1 = beta0,
						BetaTable2 = , 
						output 	   = , 
						iter	   = , 
						Variables  = &Vars
						);
	
			%local 
				i 
				NumVariables 
				;	
			%let NumVariables = %sysfunc(countw(&Variables)) ;

			proc sql noprint ;

				select 	sum(sum_all1), sum(sum_all2) into :sum_all1 , :sum_all2
				from
				( select 
					log(sum(exp( 0
							%do i = 1 %to &NumVariables. ;
								%let CurrVar = %scan(&Variables , &i) ;
								+
								%if %upcase(&CurrVar) ne INTERCEPT %then %str( &CurrVar. *);
									 (select distinct &CurrVar. from &BetaTable1. )
							%end;
						)))	as Sum_All1,
					%if %length(&BetaTable2.) %then %do;
						log(sum(exp(0
								%do i = 1 %to &NumVariables. ;
									%let CurrVar = %scan(&Variables , &i) ;
									+
									%if %upcase(&CurrVar) ne INTERCEPT %then %str( &CurrVar. *);
										 (select distinct &CurrVar. from &BetaTable2. )
								%end;
							)))
					%end;
					%else %str(0); 	as Sum_All2
				from Df_Data
				group by 
				%do i = 1 %to &GroupByVarNum.;
					%scan(&GroupByVars. , &i) 
					%if &i ne &GroupByVarNum. %then %str(,);
				%end;				
				);

			select 	sum(sum_win1), sum(sum_win2) into :sum_win1 , :sum_win2
				from
				( select 
					sum(0
							%do i = 1 %to &NumVariables. ;
								%let CurrVar = %scan(&Variables , &i) ;
								+
								%if %upcase(&CurrVar) ne INTERCEPT %then %str( &CurrVar. *);
									 (select distinct &CurrVar. from &BetaTable1. )
							%end;
						)	as sum_win1,
					%if %length(&BetaTable2.) %then %do;
						sum(0
								%do i = 1 %to &NumVariables. ;
									%let CurrVar = %scan(&Variables , &i) ;
									+
									%if %upcase(&CurrVar) ne INTERCEPT %then %str( &CurrVar. *);
										 (select distinct &CurrVar. from &BetaTable2. )
								%end;
							)
					%end;
					%else %str(0); 	as sum_win2
				from Df_Data (where = (&WinCriteria.))
				group by 
				%do i = 1 %to &GroupByVarNum. ;
					%scan(&GroupByVars. , &i) 
					%if &i ne &GroupByVarNum. %then %str(,);
				%end;					
				);
			quit;

			%if %length(&BetaTable2.) %then %do;
				data &output. ;
					x =  %sysevalf(&sum_win2 - &sum_all2 - &sum_win1 + &sum_all1 ) ;
					iter = &iter ;
					output;
				run;
			%end;
			%else %do;
				%let ProcTime = %sysfunc(datetime()) - &MASTER_START_TIME. ;
				%put %sysfunc(putn(&j , z2.))th update pos: %sysfunc(putn(&iter, z2.)) - Max Delta: &max_val *** GOF Value: %sysfunc(putn(%sysevalf(&sum_win1 - &sum_all1 ), 10.5)) *** Lapsed: %sysfunc(putn(&ProcTime., time12.3));
			%end;
			
	%mend Global_Optimization_Function;

	/*Get optimized coefficients*/
	proc sql noprint;
		select distinct
			 compbl("" %do V = 1 %to &VarsNum. ;
				%if &V > 1 %then %do; ||"!@" %end;
				%let CurrVar = %scan(&Vars. , &V);
				||"&CurrVar.: "||put(&CurrVar., best32.)
			%end;	)
			into : ModeledCoeffs
		from Model_betas
		;

	quit;
	
	%put;
	%put Factor Descriptives: ;
	%put %sysfunc(repeat(-, 30 )) ;
	%put Zero Variation Factors: %sysfunc(compbl(&CoeffWithNoVar.)) ;
	%put;
	%put Modeled Coefficients ;
	%put %sysfunc(repeat(-, 30 )) ;
	%do OC = 1 %to  %sysfunc(countw( &ModeledCoeffs , !@));
		%put %scan(&ModeledCoeffs , &OC , !@) ;
	%end;
	%put %sysfunc(repeat(-, 30 )) ;
	%put;
	%put Start of Iterations with OptimStep: &OptimStep ;
	%put %sysfunc(repeat(*, 90 )) ;
	
	/*Iterate to MaxIterations*/
	%do j = 1 %to &MaxIterations.;

		 %do i = 1 %to &VarsNum. ;
		 
		 	/*Update Betas respectively*/
			data Beta1;
				set Beta0;
				%do V = 1 %to &VarsNum. ;
					%let CurrVar = %scan(&Vars. , &V);
					%if &i = &V %then %do;
						&CurrVar. = &CurrVar. + %sysevalf( %eval(&VarsNum.-1) * &OptimStep. );
					%end;
					%else %do;
						&CurrVar. = &CurrVar. - &OptimStep. ;
					%end;	
				%end;
			run;
			/*Run GOF with the updated betas - Output respective Delta at Out&i dataset */
			 %Global_Optimization_Function(
							BetaTable2 	= Beta1 , 
							output 	   	= Out&i, 
							iter		= &i 
							)
		 %end;	

		/*Gather all deltas */
		data out_delta ;
		set 
			%do k = 1 %to &VarsNum. ; 
				Out&k 
			%end;
		;
		run;
		
		/*Get maximum delta*/
		proc sql noprint;
			select distinct max(x) into : max_val
			from out_delta
			;
		quit;	

		proc datasets lib=work nolist;
			delete 
				%do k = 1 %to &VarsNum. ; 
					Out&k 
				%end;		
			;
			quit;
		run;	
		
		/*If maximum delta is negative then Finish the process*/
		%if %index(&max_val , -) %then %goto EarlyExit;
		
		/*Else keep iterating*/
		%else %do;
		
			/*Get maximum position*/
			proc sql noprint;
				select distinct iter into : iter
				from out_delta having x = max(x)
				;
			quit;		
			
			/*Update beta0 respectively*/
			data beta0;
			set beta0 ;
			  	%do V = 1 %to &VarsNum. ;
					%let CurrVar = %scan(&Vars. , &V);
					%if &iter = &V %then %do;
						&CurrVar. = &CurrVar. + %sysevalf(%eval(&VarsNum.-1) * &OptimStep. ) ;
					%end;
					%else %do;
						&CurrVar. = &CurrVar. -  &OptimStep. ;
					%end;	
				%end;
			run;
		 
		 /*Print GOF for beta0*/
		 %Global_Optimization_Function(iter = &iter)
		%end;	
	%end;

	%EarlyExit:

	/*Get optimized coefficients*/
	proc sql noprint;
		select distinct
			 compbl("" %do V = 1 %to &VarsNum. ;
				%if &V > 1 %then %do; ||"!@" %end;
				%let CurrVar = %scan(&Vars. , &V);
				||"&CurrVar.: "||put(&CurrVar., best32.)
			%end;	)
			into : OptimizedCoeffs
		from beta0
		;

	quit;

	/*Print results.*/
	%put %sysfunc(repeat(*, 90 )) ;
	%put;
	%put %sysfunc(putn(&j , z2.))th degrade *** Max Delta: &max_val *** Total Processing Time - %sysfunc(putn(%sysfunc(datetime()) - &MASTER_START_TIME., time12.3)) ;
	%put ;
	%put Optimized Coefficients ;
	%put %sysfunc(repeat(-, 30 )) ;
	%do OC = 1 %to  %sysfunc(countw( &OptimizedCoeffs , !@));
		%put %scan(&OptimizedCoeffs , &OC , !@) ;
	%end;
	%put %sysfunc(repeat(-, 30 )) ;


		proc datasets lib=work nolist;
			delete 
					Beta0 Beta1 Df_data Model_betas Out_delta
			;
			quit;
		run;	
	
	/*Restore system options*/
	proc printto;run;
	options &NotesOpt. &SourceOpt. &MprintOpt. ;
	

%mend Logit_With_Coeff_Optimization;
/*%Logit_With_Coeff_Optimization();

Examples of calling the function - With and without Intercept.*/

*%Logit_With_Coeff_Optimization ( 
					Intercept		= Yes ,
					Standardize		= No
					);

%Logit_With_Coeff_Optimization ( 
					Intercept		= Yes ,
					Standardize		= Yes
					);

/*
%Logit_With_Coeff_Optimization ( 
					Intercept		= No ,
					Standardize		= Yes
					);

%Logit_With_Coeff_Optimization ( 
					Intercept		= No ,
					Standardize		= No
					);
