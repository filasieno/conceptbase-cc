// (c) Manfred Jeusfeld, license CC0 (public domain)

// Windows:
// compile: javac -classpath c:\conceptbase\lib\classes\cb.jar TinyClient3.java
// run: java -DCB_HOME="c:\conceptbase" -classpath c:\conceptbase\lib\classes\cb.jar;. TinyClient3

// Linux:
// compile: javac -classpath $CB_HOME/lib/classes/cb.jar TinyClient3.java
// run: java -DCB_HOME="$CB_HOME" -classpath $CB_HOME/lib/classes/cb.jar:. TinyClient3


// Variant of TinyClient that starts/connects a local CBserver on the fly
// This requires either Linux or Windows 10 with a Linux sub-system
import i5.cb.api.*;

public class TinyClient3 {

  private static LocalCBclient cbClient = null;

  public static void main(String argv[])  {
      String answer;
      cbClient=new LocalCBclient();
      answer = cbClient.connect();  // shall start&connect a CBserver on localhost with port 4001
      System.out.println("connect="+answer);
      answer = cbClient.tells("Employee in Class end");
      answer = cbClient.asks("get_object[Employee/objname]");
      System.out.println(answer);
      answer = cbClient.disconnect();
  }
}

