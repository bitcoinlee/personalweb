/******************************************************************/
/*** Created: 02/25/2015                                         **/
/*** By: Sotiris Papazerveas                                     **/
/*********************************************************************************/
/* Initial Algorithm idea from:                                                 **/
/* http://stackoverflow.com/questions/7198154/combination-algorithm-in-excel-vba */
/*********************************************************************************/

package javaToSAS;

import java.util.ArrayList;
import java.util.HashSet;



public class Permutations {

	static ArrayList<String> ArrayIn = new ArrayList<String>();
	ArrayList<String> Permlist =new ArrayList<String>();

	public void addItem(String Item) {
		ArrayIn.add(Item);
	}

	public void calcPerm(int r ){
		Permlist = Perms(ArrayIn ,  r);
	}

	public void removeDups(){
		ArrayIn = removeDuplicates(ArrayIn);
	}

	public String listPerm(double r , String dlm) {


		if (dlm == "-"){
			System.out.println("Please choose another delimiter."
					+ "\n'-' is not acceptable as it is used between combinations.");
			return("");
		}

		removeDups();
		calcPerm((int) r);

		String printCombinations = "";
		for (int i=0;i<numPerm();i++){
			String TempItem= Permlist.get(i);

			if(printCombinations.length()>0){
				printCombinations = printCombinations + dlm + TempItem;
			}else{
				printCombinations =  TempItem;
			}
		}
		return(printCombinations);
	}

	public int numPerm(){
		return Permlist.size();
	}

	public static ArrayList<String> removeDuplicates(ArrayList<String> list) {
		ArrayList<String> result = new ArrayList<>();
		HashSet<String> set = new HashSet<>(); // Record encountered Strings in HashSet.
		for (String item : list) {
			if (!set.contains(item)) { // If String is not in set, add it to the list and the set.
				result.add(item);
				set.add(item);
			}
		}
		return result;
	}

	public static ArrayList<String> removeDuplicates() {
		return removeDuplicates(ArrayIn);
	}



	public  ArrayList<String> Perms( int r, boolean removedups) {
		if(removedups){
			return  Perms(removeDuplicates(ArrayIn) ,  r);
		}else{
			return  Perms(ArrayIn,  r);
		}
	}

	public  ArrayList<String> Perms( int r) {
		return  Perms(removeDuplicates(ArrayIn),  r);
	}

	public  ArrayList<String> Perms( ArrayList<String> pool,  int r) {

		ArrayList<Integer> idx = new ArrayList<Integer>();
		ArrayList<String> permlist = new ArrayList<String>();

		int n = pool.size();
		if(n< r){
		    System.out.println("Maximum r input is: " + n );
		    return  new ArrayList<String>();
		}

		for (int i=0;i<r;i++){
			idx.add(i);
		}

		int i = r;
		String printCombinations = "" ;

		while(i>0){
			for (int j=1;j<=r;j++){
				if(printCombinations.length()>0){
					if(j==1){
						//printCombinations = printCombinations + "\n" + pool.get(idx.get(j-1));
						printCombinations = pool.get(idx.get(j-1));
					}else{
						printCombinations = printCombinations + "-" + pool.get(idx.get(j-1));
					}
				}else{
					printCombinations = pool.get(idx.get(j-1));
				}
			}

			permlist.add(printCombinations);

			i = r;
			while(idx.get(i-1) == (n - r + i - 1)){
				i-- ;
				if(i==0){
					return permlist;
				}
			}

			int TempInt = idx.get(i-1) + 1 ;
			idx.set(i-1,TempInt);
			for (int j=i+1;j<=r;j++){
				idx.set(j-1,idx.get(i-1) + (j - i));
			}
		}

		return permlist;
	}




	public static void main(String[] args) {

		Permutations p = new Permutations();
		p.addItem("Ena");
		p.addItem("Dio");
		p.addItem("Tria");
		p.addItem("Tria");
		p.addItem("Dio");

		System.out.println(p.listPerm(2 , ","));
		System.out.println(p.numPerm());



	}

}
