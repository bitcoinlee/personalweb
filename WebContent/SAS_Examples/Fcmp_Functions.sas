/******************************************************************/
/******************************************************************/
/***  Code File   : Fcmp_Functions.sas                           **/
/***  Program Name: Loads Custom FCMP Functions                  **/
/***  The functions can be used at both Proc SQL and data steps  **/
/******************************************************************/
/*** Last Updated: 22/02/2015 	                                 **/
/*** By: Sotiris Papazerveas                                     **/
/******************************************************************/
/*** Function List                                               **/
/*** ------------------                                          **/
/*** Excel_date(SAS_date) - Converts SAS to EXCEL date           **/
/*** Week_end_Dt(date)    - Converts Date to Week Ending Sunday  **/
/*** Last_Modified(file)  - Gets last modified attribute of file **/
/*** FileSize(file)       - Gets File Size of file               **/
/*** Created(file)        - Gets Created attribute of file       **/
/*** isDir(paht)          - Checks if path is directory          **/
/******************************************************************/
/*** Inputs                                                      **/
/*** ------                                                      **/
/*** FCMP_LibPath  : Library Path. Blank = Work                  **/
/******************************************************************/
/******************************************************************/
%macro Load_Fcmp_Functions (FCMP_LibPath =) ;


	%if not %length(&FCMP_LibPath.) %then %let FCMP_LibPath = %sysfunc(pathname(work)) ;

	libname fcmplib "&FCMP_LibPath.";
	proc fcmp outlib= fcmplib.Fcmp_Functions.lstmdf; 
 
 	function Excel_date(SAS_date) ; 
		Excel_dt = SAS_date +21916; 
 		return(Excel_dt); 
 	endsub ; 
 	
	function Week_end_Dt(date);
		end_of_week_date = intnx("week.2", date, 0, "end");
		return(end_of_week_date);
	endsub;
	
	 function Last_Modified(filename $ )  ;
		rc= filename('abc',filename) ;
		fid= fopen('abc' ) ;
		Mdf_Result= input( finfo( fid,'Last Modified') , datetime.) ;   
		fidc= fclose( fid) ;
		return( Mdf_Result ); 
	 endsub; 
	 
	 function Created(filename $ )  ; 
		rc= filename('abc',filename) ;
		fid= fopen('abc' ) ;
		Mdf_Result= input( finfo( fid,'Create Time') , datetime.) ;
		fidc= fclose( fid) ;
		return( Mdf_Result );
	 endsub; 	
	 
	 function FileSize(filename $ )  ;
		rc= filename('abc',filename) ;
		fid= fopen('abc' ) ;
		Mdf_Result= input( finfo( fid,'File Size (bytes)') , 32.) ;
		fidc= fclose( fid) ;
		return( Mdf_Result );
	 endsub; 
	 
	 function isDir(Path $ )  ; 
	 	if length(Path) = 0 then IsDirResult = 0 ;
	 	else if compress(Path) = "." then IsDirResult = 0 ;
	 	else do;
			rc= filename('abc',Path) ;
			did = dopen('abc' ) ;
			if did then IsDirResult = 1;
			else IsDirResult = 0 ;
			rc = dclose(did );
		end;
		return( IsDirResult );
	 endsub; 	 
	 
	run;
	
	options cmplib = fcmplib.Fcmp_Functions; 
	
	%put ;
	%put NOTE: %sysfunc(repeat(-, 60 )) ;
	%put NOTE: --- Fcmp_Functions  successfully loaded to &FCMP_LibPath.   ;
	%put NOTE: %sysfunc(repeat(-, 60 )) ;
	%put ;

%mend Load_Fcmp_Functions ;
