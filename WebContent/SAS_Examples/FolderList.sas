/******************************************************************/
/******************************************************************/
/***  Code File   : FolderList.sas                               **/
/***  Program Name: Lists items in a folder                      **/
/******************************************************************/
/*** Created: 02/07/2013 	                                 **/
/*** By: Sotiris Papazerveas                                     **/
/******************************************************************/
/*** Macro Dependencies                                          **/
/*** ------------------                                          **/
/*** %isDir                                                      **/
/******************************************************************/
/*** Inputs                                                      **/
/*** ------                                                      **/
/*** Path          : Path Location                               **/
/*** Files_only =  : What to report(folders/files/blank)         **/
/*** Filter  =     : Filter items that contain                   **/
/*** Ext =         : Filter items with extention                 **/
/*** Delimiter =   : Deliiter of output array                    **/
/*** Extention =   : Report Exntention (Yes/No)                  **/
/******************************************************************/
/******************************************************************/

%macro FolderList( Path  ,  Files_only = ,  Filter = , Ext = ,  Delimiter=%str( ) , Extention = No  )  ;
		
  %if not %length(&Extention) %then %let Extention=no;	
  %let Extention=%upcase(%substr(&Extention,1,1));
  				
  %local result did dname cnt num_members filename;

  %let result=;

  %if %sysfunc(filename(dname,&Path)) eq 0 %then %do;

    %let did = %sysfunc(dopen(&dname));
    %let num_members = %sysfunc(dnum(&did));

    %do cnt=1 %to &num_members;
      %let filename = %sysfunc(dread(&did,&cnt));
      %if "&filename" ne "" %then %do;

      	
      	/*Filter Check*/
      	%if "&Filter" ne "" %then %do;
           %if not %index(%lowcase(&filename),%lowcase(&Filter)) %then %goto nextitem;  
      	%end;
 
       	 /*Folders Check*/
       	 %else %if %lowcase(&Files_only) = %lowcase(folders) %then %do;
       	       %if not %isDir(Path=&Path/&filename) %then %goto nextitem;  
      	 %end;
 
         %if %index(&filename , %str(.) ) %then %let CurrExt = %scan(&filename , -1, %str(.) ) ;
             
         /*Extention Check*/
       	%if "&Ext" ne "" %then %do;      	  
       	   %if %lowcase(&Ext) ne %lowcase(&CurrExt) %then %goto nextitem;      	  
      	%end;
 
      	/*Files Check*/
      	 %if %lowcase(&Files_only) = %lowcase(files) %then %do;
      	      %if  %isDir(Path=&Path/&filename) %then %goto nextitem;  
      	 %end;
  
      	 /*Report Extention*/
	%if &Extention. = Y 
		or %lowcase(&Files_only) = %lowcase(folders)
		%then %let result = &result%str(&Delimiter)&filename;
	%else %do;
		%if %index(&filename , %str(.) ) %then %let result = &result%str(&Delimiter)%sysfunc(tranwrd( &filename , %str(.)%scan(&filename , -1, %str(.)) , %str()  ));
		%else %let result = &result%str(&Delimiter)&filename;
	%end;

      %end;
      %else %do;
        %put ERROR: (CMN_MAC.FILE_LIST) FILE CANNOT BE READ.;
        %put %sysfunc(sysmsg());
      %end;
      
      %nextitem:
      
    %end;

  %end;
  %else %do;
    %put ERROR: (CMN_MAC.FILE_LIST) PATH DOES NOT EXIST OR CANNOT BE OPENED.;
    %put %sysfunc(sysmsg());
  %end;

  %if "&result" ne "" %then %do;
    %substr(&result,2)
  %end;

%mend FolderList; 
