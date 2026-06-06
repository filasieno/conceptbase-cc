


/* example on how to use the String-valued API to interact with a CBserver */
/* Manfred Jeusfeld, 2017-03-24 (2019-02-05)                               */


// (C) Manfred Jeusfeld, license CC0 (public domain)
// compile: javac -classpath c:\conceptbase\lib\classes\cb.jar SimpleClient.java
// run: java -classpath c:\conceptbase\lib\classes\cb.jar;. SimpleClient


import i5.cb.api.*;


public class SimpleClient {

	private static LocalCBclient cbClient = null;

	
	public static void main(String argv[])  {
          
          String sAnswer;

          // create the API object cbClient to communicate with a CBserver
          cbClient=new LocalCBclient();

          // connect to the CBserver running at the specified domain/portnumber
          // "SimpleClient" is used as toolname to identify the client with the CBserver
          // the last argument is a String for the username; using null means that
          // the login name of the computer user is taken
          sAnswer = cbClient.connect("cbserver.iit.his.se",4001,"SimpleClient",null);
             System.out.println("\nconnect: " +  sAnswer);

          // create a database module Work
          sAnswer = cbClient.mkdir("Work");
             System.out.println("\nmkdir Work " +  sAnswer);

          // switch to this database module Work
          sAnswer = cbClient.cd("Work");
             System.out.println("\ncd Work " +  sAnswer);
          
          // check in which module we currently are
          sAnswer = cbClient.pwd();
             System.out.println("\npwd: " +  sAnswer);

          // define a class Employee
          sAnswer = cbClient.tells("Employee in Class with attribute empno: Integer; name: String end");
             System.out.println("\ntells Employee: " +  sAnswer);

          // attempt to define an instance bill of Employee; shall fail because b123 is not an Integer
          sAnswer = cbClient.tells("bill in Employee with empno billsempno: b123 end");
             System.out.println("\ntells bill (error): " +  sAnswer);

          // define an instance bill of Employee
          sAnswer = cbClient.tells("bill in Employee with empno billsempno: 123 end");
             System.out.println("\ntells bill (ok): " +  sAnswer);

          // untell the attribute billsempno from bill
          sAnswer = cbClient.untells("bill  with empno billsempno: 123 end");
             System.out.println("\nuntells bill: " +  sAnswer);

          // define a String attribute of bill, note the escaped quotes
          sAnswer = cbClient.tells("bill in Employee with name billsname: \"William\" end");
             System.out.println("\ntells bill (ok): " +  sAnswer);

          // retrieve the frame of bill
          sAnswer = cbClient.asks("get_object[bill/objname]");
             System.out.println("\nasks get_object[bill]: " +  sAnswer);

          // define another two employees
          sAnswer = cbClient.tells("mary in Employee end\n anne in Employee end");
             System.out.println("\ntells mary, anne: " +  sAnswer);

          // define a query
          String q = "UnnamedEmployee in QueryClass isA Employee with"
                   + " constraint c: $ not exists n/String (this name n) $ end";
          sAnswer = cbClient.tells(q);
             System.out.println("\ntells UnnamedEmployee: " +  sAnswer);

          // ask the query
          sAnswer = cbClient.asks("UnnamedEmployee","LABEL");
             System.out.println("\nUnnamedEmployee: " +  sAnswer);


          // disconnect from the CBserver
          cbClient.disconnect();
	}
	
		
}




