/******************************************************************/
/******************************************************************/
/***  Code File   : SendParallerJobs.sas                         **/
/***  Program Name: A paraller job approach using SYSTASK        **/
/******************************************************************/
/*** Created: 03/21/2015 	                                 **/
/*** By: Sotiris Papazerveas                                     **/
/******************************************************************/
/*** Inputs                                                      **/
/*** ------                                                      **/
/*** MaxNumParallelJobs : Number of maximum running jobs         **/
/*** JobsDs             : JobsDs dataset (fileBody,filename cols)**/
/***                    : See %createJobsDs example macro        **/
/*** SASExe       	: Path of the SAS.exe on your machine    **/
/*** autox              : Path of the autoexec.sas if available  **/
/*** CmdOpts            : Additional CMD commands                **/  
/*** PrintLog           : Print Process to log                   **/  
/************************************************************************************************************************/
/* SAS System Options:                                                                                                  */
/* http://support.sas.com/documentation/cdl/en/allprodslang/63337/HTML/default/viewer.htm#syntaxByType-systemOption.htm */
/************************************************************************************************************************/ 



options nomprint nonotes  ;
 	
/*Create the JobsDs Driver Dataset.*/
/*Should have column filebody with the code of each file 
  and the filename with the name of the sas file*/
%macro createJobsDs ;

	data JobsDs ;

		%do i = 1 %to 30 ;
			fileBody = "%nrstr(%macro test; %put TestRun) &i.; %nrstr(%mend test; %test; %let rc = %sysfunc(sleep(1))); "; 
			filename = "testing_"||put(&i , z3.);
			output;
		%end;

	run;
	
%mend createJobsDs ;
%createJobsDs;


%macro SendParallerJobs ( 
			MaxNumParallelJobs = 15 ,
			JobDs = JobsDs ,
			SASExe = %str(%sysget(SASROOT)\sas.exe) ,
			autox = %str(%sysfunc(getoption(autoexec))) ,
			CmdOpts = %str( -nonotes -nomprint  ) ,
			PrintLog = y
		) ;

	%local    
		encode
		WorkLibPath
		CreatePath
		FilePath
		NumJobs
		prevOpt
		;

 	%let encode = %str(%sysfunc(getoption(encoding))); 
	%let WorkLibPath = %sysfunc(pathname(work));
	%let CreatePath	= %sysfunc(dcreate( MultiThread , &WorkLibPath. )) ;	 
	%let FilePath = &WorkLibPath.\MultiThread ;
	%let prevOpt = 
			%sysfunc(getoption(NOquotelenmax) )
			%sysfunc(getoption(NOserror) ) 
			%sysfunc(getoption(NOmacrogen) ) 
			%sysfunc(getoption(mprint) ) 
			%sysfunc(getoption(notes) ) 
		;

	options mvarsize=max NOquotelenmax NOserror NOmacrogen nomprint nonotes;


	data _null_ ;
		length SASpgmPath $2000. macrCall $32000 ;
		set &JobDs. ;
		SASpgmPath = "&FilePath.\" ||strip(filename)||".sas" ;
		file dummy filevar=SASpgmPath LRECL=32000 ;
		
		macrCall =  strip(fileBody)   ;
		put macrCall  ;
	run ;
 

	proc sql noprint;
		select distinct  strip(filename)
		into :FName_1 - :FName_9999
		from &JobDs.
		;

		%let NumJobs = &SQLobs ;
	quit;


	%macro words(str,delim=%str( ) )  ;
	  %local  str delim i ;	
	  %let i = 1 ;
	  %do %while(%length(%qscan(&str,&i,&delim)) GT 0);
	    %let i = %eval(&i + 1);
	  %end;
	  %eval(&i.-1)
	%mend words ;

	%macro RemoveWords(string,targetwords) ;
	  %local i j result match  tword sword;
	  %do i = 1 %to %words(&string)  ;
	    %let match = 0 ;
	    %let sword = %scan(&string,&i,%str( ));
	    %do j = 1 %to %words(&targetwords) ;
	      %let tword=%scan(&targetwords,&j,%str( ));
		%if "%upcase(&tword)" EQ "%upcase(&sword)" %then %do;
		  %let match = 1;
		  %let j = %words(&targetwords) ;
		%end;
	    %end;
	    %if not &match %then %let result = &result &sword;
	  %end;
	  %if %length(&result) %then %let result=%sysfunc(compbl(&result));
	  &result
	%mend RemoveWords;
 

	SYSTASK KILL _ALL_ ;
	**---------------------------------------**;
	** Main Job Submission and tracking loop **;
	**---------------------------------------**;
	%let CompletedJobs = ;
	%let RunningJobs = ;
	%do job = 1 %to &NumJobs. ;

		%local 
			start&job. 
			finish&job. 
			CheckLogLines&job. 
		;

		%let CurrFn = %str(&FilePath.\&FName_&&job..) ;
		
		data _null_ ;
			length sascmd $10000. ;
			sascmd = "'&SASExe.' " ||
			%if "&autox." ne "" %then %do;
				"-autoexec '&autox.' "||
			%end;
			"-noterminal  -sysin '&CurrFn..sas' -log '&CurrFn..log' -print '&CurrFn..lst' &CmdOpts. "  ;
			call symput('sascmd', strip(sascmd ));
		run;

		systask command "&sascmd." taskname=job&job. status=jobRC&job. ;

		%if %sysfunc(compress(%upcase(&PrintLog.),Y,k)) eq Y %then 
			%put Start Job : &job.  ;

		%let start&job. = %sysfunc(datetime()) ;
		%let RunningJobs = &RunningJobs. &job. ;
		%let CurrentTime = %sysfunc(datetime()) ;


		%WAIT:

		%if %words(&RunningJobs.) >= &MaxNumParallelJobs. and &job < &Numjobs. %then %do ;

			waitfor _ANY_ %do i = 1 %to %words(&RunningJobs.) ; job%scan(&RunningJobs.,&i.,%str( )) %end ;;
			%let Jobs2Remove = ;

			%do i = 1 %to %words(&RunningJobs.) ;
				%let task = %scan(&RunningJobs.,&i.,%str( ));
				%if %length(&&jobRC&task.) %then %do ;
					%let CompletedJobs = &CompletedJobs. &task. ;
					%let Jobs2Remove = &Jobs2Remove. &task. ;
					%let Finish&task. = %sysfunc(datetime()) ;
					
					%if %sysfunc(compress(%upcase(&PrintLog.),Y,k)) eq Y %then
						%put Job completed: &task. with OS Return Code: &&jobRC&task. Total Processing Time - %sysfunc(putn( &&Finish&task. - &&start&task. , time12.3)) ;
					
				%end;
			%end;

			%let RunningJobs = %removeWords(&RunningJobs., &Jobs2Remove.) ;
			%put Num of Finished Jobs : %words(&Jobs2Remove.) ;
		%end;
		%else %if &job = &Numjobs. %then %do ;
			waitfor _ALL_ %do i = 1 %to %words(&RunningJobs.) ; job%scan(&RunningJobs.,&i.,%str( )) %end ;;

			%do i = 1 %to %words(&RunningJobs.) ;
				%let task = %scan(&RunningJobs.,&i.,%str( ));
				%let Finish&task. = %sysfunc(datetime()) ;
				%let CompletedJobs = &CompletedJobs. &task. ;
			%end;
			%let RunningJobs = ;

		%end;


		%** Dont submit any new jobs until under the new limit **;
		%if %eval(%words(&RunningJobs.) >= &MaxNumParallelJobs.) %then %do ;
			%if %sysfunc(compress(%upcase(&PrintLog.),Y,k)) eq Y %then %do;
				%put RunningJobs=&RunningJobs. ;
				%put MaxNumParallelJobs=&MaxNumParallelJobs. ;
				%put Entered section to be redirected to WAIT ;
			%end;
			%goto WAIT ;
		%end ;


	%end;

	%if %sysfunc(compress(%upcase(&PrintLog.),Y,k)) eq Y %then %do;
		%put ***----------------------------------------------------------*** ;
		%put Currently there are %words(&RunningJobs.) jobs executing ;
		%put %words(&CompletedJobs.) jobs completed of &NumJobs. ;
		%put ***----------------------------------------------------------*** ;
	%end;

	%let rc = %sysfunc(sleep(1)) ;	

	options &prevOpt. ;

%mend SendParallerJobs;
%SendParallerJobs;
