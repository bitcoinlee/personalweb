OPTIONS SET=CLASSPATH "_PATH_\javaToSAS.jar";

data Combinations;
 
	declare javaobj j("javaToSAS/Permutations");
	length comb $2000;
	length numComb 8;

	j.callVoidMethod("addItem", "ena" );
	j.callVoidMethod("addItem", "dio" );
	j.callVoidMethod("addItem", "tria" );
	j.callVoidMethod("addItem", "tria" );
	j.callVoidMethod("addItem", "dio" );

	do i = 1 to 5;
		j.callVoidMethod("addItem", put(i ,z3.) );
	end;

	j.callstringmethod('listPerm', 1 , "," , comb);

	do i = 1 to countw(comb , ",");
		j.callstringmethod('listPerm', i , "," , comb);
		j.callIntMethod('numPerm', numComb);
		output;
	end;
	drop i ;
run;



data _null_;
	set sashelp.class end=last;
	
	if _n_=1 then declare javaobj j("javaToSAS/Classroom");
	
	/*List students of sashelp.class*/
	j.callVoidMethod("addStudent", name, sex, age, height, weight);
	
	if last then do;
		j.callVoidMethod("listAllStudents");
		
		/*Pop-up frame from MS-SQL query*/
		j.callVoidMethod("SqlCon", "HOST",  "USER", "PASS", "DATABASE", "select top 5000 * from TABLE");
	end; 
run;
