/******************************************************************/
/*** Created: 03/02/2015                                         **/
/*** By: Sotiris Papazerveas                                     **/
/******************************************************************/
/* Multiple Linear Regression                                    **/
/* OLS estimation                                                **/
/******************************************************************/


package javaToSAS;

public class OLSRegression {


    public static double[][] multiplyMatrix (double[][] B , double[][] A) {

        int B_ColLength = B[0].length;
        int A_RowLength = A.length;

        if(B_ColLength != A_RowLength) {
        	System.out.println("A_RowLength = " + A_RowLength + ", B_ColLength = " + B_ColLength  );
        	System.out.println("A_RowLength and  B_ColLength must be equal"  );
        	return new double[0][0] ;
        }
        int B_RowLength = B.length;
        int A_ColLength = A[0].length;

        double[][] mResult = new double[B_RowLength][A_ColLength];
        for(int i = 0; i < B_RowLength; i++) {         // rows from B
            for(int j = 0; j < A_ColLength; j++) {     // columns from A
                for(int k = 0; k < B_ColLength; k++) { // columns from B
                    mResult[i][j] += B[i][k] * A[k][j];
                }
            }
        }
        return mResult;
    }

    public static double[][] transposeMatrix(double [][] m){
        double[][] temp = new double[m[0].length][m.length];
        for (int i = 0; i < m.length; i++)
            for (int j = 0; j < m[0].length; j++)
                temp[j][i] = m[i][j];
        return temp;
    }


	public static double[][] addmeantoMatrix(double[][] m) {
		double[][] temp = new double[m.length][m[0].length + 1];
		for (int i = 0; i < m.length; i++) {
			temp[i][0] = 1;
			for (int j = 0; j < m[0].length; j++) {
				temp[i][j + 1] = m[i][j];
			}
		}
		return temp;
	}


    public static double[][] inverseMatrix(double[][]in){ //Gauss - Jordan Inverse Matrix
		int st_vrs=in.length, st_stolp=in[0].length;
		double[][]out=new double[st_vrs][st_stolp];
		double[][]old=new double[st_vrs][st_stolp*2];
		double[][]newmat=new double[st_vrs][st_stolp*2];


		for (int v=0;v<st_vrs;v++){//ones vector
			for (int s=0;s<st_stolp*2;s++){
				if (s-v==st_vrs)
					old[v][s]=1;
				if(s<st_stolp)
					old[v][s]=in[v][s];
			}
		}
		//zeros below the diagonal
		for (int v=0;v<st_vrs;v++){
			for (int v1=0;v1<st_vrs;v1++){
				for (int s=0;s<st_stolp*2;s++){
					if (v==v1)
						newmat[v][s]=old[v][s]/old[v][v];
					else
						newmat[v1][s]=old[v1][s];
				}
			}
			old=transcriptMatrix(newmat);
			for (int v1=v+1;v1<st_vrs;v1++){
				for (int s=0;s<st_stolp*2;s++){
					newmat[v1][s]=old[v1][s]-old[v][s]*old[v1][v];
				}
			}
			old=transcriptMatrix(newmat);
		}
		//zeros above the diagonal
		for (int s=st_stolp-1;s>0;s--){
			for (int v=s-1;v>=0;v--){
				for (int s1=0;s1<st_stolp*2;s1++){
					newmat[v][s1]=old[v][s1]-old[s][s1]*old[v][s];
				}
			}
			old=transcriptMatrix(newmat);
		}
		for (int v=0;v<st_vrs;v++){//rigt part of matrix is invers
			for (int s=st_stolp;s<st_stolp*2;s++){
				out[v][s-st_stolp]=newmat[v][s];
			}
		}
		return out;
	}

    public static double[][] transcriptMatrix(double[][] in){
		double[][]out=new double[in.length][in[0].length];
		for(int i=0;i<in.length;i++){
			for (int j=0;j<in[0].length;j++){
				out[i][j]=in[i][j];
			}
		}
		return out;
	}

    public static String toString(double[][] m) {
        String result = "";
        for(int i = 0; i < m.length; i++) {
            for(int j = 0; j < m[i].length; j++) {
                result += String.format("%11.8f", m[i][j]);
            }
            result += "\n";
        }
        return result;
    }


    public double[][] Betas ;
    public double[][] YHat ;
    public double[][] Residuals ;
    public double SSres ;
    public double SStot ;
    public double SSreg ;
    public double Rsquared ;

    public OLSRegression(double[][] Y , double[][] X , boolean Intercept){
    	if(Intercept)  X = addmeantoMatrix(X) ;

        double[][] XXtr = inverseMatrix( multiplyMatrix(   transposeMatrix(X) ,  X  ) );
        double[][] XtrY =  multiplyMatrix(   transposeMatrix(X)  , Y ) ;
        double[][] meanY =  meanMat(Y) ;

        Betas = multiplyMatrix( XXtr ,XtrY ) ;
        YHat = multiplyMatrix( X ,Betas ) ;
        Residuals = minusMatrix( Y ,YHat ) ;
        SSres = sumofsquares(Y , YHat);
        SStot = sumofsquares(Y ,   meanY);
        SSreg = sumofsquares(YHat , meanY);
        Rsquared = 1 - SSres / SStot ;
    }


    public static double[][] meanMat (double[][] A  ) {
    	double sum = 0 ;
    	int A_RowLength = A.length;
    	int A_ColLength = A[0].length;
    	 double[][] mResult = new double[A_RowLength][A_ColLength];

    	 for(int i = 0; i < A_RowLength; i++) {
    		 sum +=   A[i][0] / A_RowLength   ;
    	 }

    	 for(int i = 0; i < A_RowLength; i++) {
    		 mResult[i][0] = sum ;
    	 }

    	return mResult;
    }

    public static double sumofsquares (double[][] B , double[][] A) {
    	double sum = 0 ;

        int B_ColLength = B[0].length;
        int A_RowLength = A.length;
        int B_RowLength = B.length;
        int A_ColLength = A[0].length;
        if(B_ColLength != A_ColLength || A_RowLength != B_RowLength ) {
        	System.out.println("Dimentions must be equal"  );
        	return sum;
        }

        for(int i = 0; i < A_RowLength; i++) {         // rows from B
            for(int j = 0; j < A_ColLength; j++) {     // columns from A
            	sum += (B[i][j] - A[i][j]) * (B[i][j] - A[i][j]);
            }
        }

		return sum;
    }

 public static double[][] minusMatrix (double[][] B , double[][] A) {
        int B_ColLength = B[0].length;
        int A_RowLength = A.length;
        int B_RowLength = B.length;
        int A_ColLength = A[0].length;
        if(B_ColLength != A_ColLength || A_RowLength != B_RowLength ) {
        	System.out.println("Dimentions must be equal"  );
        	return new double[0][0] ;
        }

        double[][] mResult = new double[B_RowLength][A_ColLength];
        for(int i = 0; i < A_RowLength; i++) {         // rows from B
            for(int j = 0; j < A_ColLength; j++) {     // columns from A
            	 mResult[i][j] = B[i][j] - A[i][j];
            }
        }
        return mResult;
    }


    public static void main(String[] args) {

        double[][] Y = new double[][] {
        		{ 15, 18, 17, 16, 17, 14, 10, 21, 17, 11, 13, 18, 16, 15, 14, 13, 16, 13, 11, 6, 12 , 18, 12, 16, 15}
        };
        Y = transposeMatrix(Y) ;
        double[][] X = new double[][] {
        	/*X1*/	{ 11, 7, 12, 13, 14, 15, 5, 14, 14, 10, 8, 16, 15, 14, 10, 9, 11, 9, 7, 10, 9, 10, 10, 16, 10} ,
        	/*X2*/	{38, 42, 38, 36, 40, 32, 20, 44, 34, 28, 24, 30, 26, 24, 26, 18, 30, 26, 18, 10, 12, 32, 18, 20, 18},
        	/*X3*/	{ 10, 16, 18, 15, 15, 11, 13, 18, 12, 16, 10, 16, 15, 12, 12, 14, 16, 13, 11, 17, 8, 18, 14, 15, 12}
        };
        X  = transposeMatrix(X) ;


        OLSRegression OLS = new OLSRegression(Y , X, true);

        System.out.println("#Betas\n" + toString( transposeMatrix(OLS.Betas) ));
        System.out.println("#YHat\n" + toString( OLS.YHat ));
        System.out.println("#Residuals\n" + toString( OLS.Residuals ));

        System.out.println("#Rsquared\n" +   OLS.Rsquared  );
    }

}
