#-----------Read Input Arguments - 1 character 2 numeric
args <- commandArgs(trailingOnly = TRUE)
arg1 <- as.character(args[1])  
arg2 <- as.numeric(args[2]) 
arg3 <- as.character(args[3]) 

#-----------HelloWorld function
HelloWorld <- function(txt1 , txt2){
   cat( paste('Hello', txt1, '\nYou chosed to load data from' , txt2,'\nEnjoy your mixed model'));
}
HelloWorld(arg1, arg3);
cat("\n\n")

#-----------Get Filepath of the file in the scripts folder.
getFilePath <- function(file , folder){

    cmd.args <- commandArgs()
    m <- regexpr("(?<=^--file=).+", cmd.args, perl=TRUE)
    script.dir <- dirname(regmatches(cmd.args, m))
    if(length(script.dir) == 0) stop("can't get script dir: please call the script with Rscript")
    if(length(script.dir) > 1) stop("can't get script dir: more than one '--file' argument detected")
    
     if(!missing(folder)) {
     	dir.create(file.path(script.dir, folder) , showWarnings = FALSE)
    	file <- paste(folder , "/" , file , sep = "")
    }   
    return(paste(script.dir , "/" , file , sep = ""))
}


exportCSV <- function(DataSet, OutCSV ){
	cat( paste( "\n>>Exporting" ,  OutCSV , sep = " ") )
	write.csv(DataSet, file = OutCSV ,  fileEncoding = "UTF-8")
}

if(arg3=="mysql"){
	cat("\n---Connecting to papazerveas.zapto.org---\n")
	#-----------MySQL Connection
	#install.packages("RMySQL",dep=TRUE) 
	library(RMySQL)
	mydb = dbConnect(MySQL(), user='test', password='test', dbname='rz', host='papazerveas.zapto.org')
	#dbListTables(mydb)
	#dbListFields(mydb, 'addresses')
	query <-"select District,City,latitude,longtitude from addresses limit 1,2000"
	rs = dbSendQuery(mydb, query) 
	df = fetch(rs, n=-1)
}else{
	
	df <- getFilePath("addresses.csv" , "Data") 
	cat( paste( "\n---Loading data from" ,  df ,  "---\n" , sep = " ") )
	df <- read.csv( df ,header=T)
}

#-----------mixed model example

#head(df)
library(nlme)
lmm1<-lme(fixed=latitude~District,random=~1|City,data=df) #fixed effect District,  random effect intercept by City
#summary(lmm1)


cat("\n---Model Run. >> Exporting Output---")
exportCSV(coefficients(lmm1)  , getFilePath("coefficients.csv" , "Coeff") )  


exportCSV(fixef(lmm1)  , getFilePath("Fixed_Effects.csv" , "Coeff") )  

exportCSV(ranef(lmm1) , getFilePath("Random_Effects.csv" , "Coeff") )  

Fit <- cbind(residuals(lmm1),fitted(lmm1) , df[, "latitude"])
colnames(Fit) <- c("residuals", "fitted", "Actual"  )
exportCSV(Fit , getFilePath("Fit.csv") )  




#-----------linear model
#fit <- lm(latitude ~ longtitude , data=mydata)
#fit1 <- lm(latitude ~ 0 + longtitude , data=mydata) #noint
#coefficients(fit)  
#coefficients(fit1)  

#----------Model Validation
#summary(fit) 
#coefficients(fit) # model coefficients
#confint(fit, level=0.95) # CIs for model parameters 
#fitted(fit) # predicted values
#residuals(fit) # residuals
#anova(fit) # anova table 
#vcov(fit) # covariance matrix for model parameters 
#influence(fit) # regression diagnostics
#anova(fit, fit1) #compare models


#-----------system call of the bat
#system("_PATH_\\R_shell_script.bat")
