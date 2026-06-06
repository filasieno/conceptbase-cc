// (c) Manfred Jeusfeld, license CC0 (public domain)
// compile: javac -classpath c:\conceptbase\lib\classes\cb.jar TinyClient.java
// run: java -classpath c:\conceptbase\lib\classes\cb.jar;. TinyClient

import i5.cb.api.*;

public class TinyClient {

  private static LocalCBclient cbClient = null;

  public static void main(String argv[])  {
      String sAnswer;
      cbClient=new LocalCBclient();
      sAnswer = cbClient.connect("cbserver.acme.org",4001,"TinyClient",null);
      sAnswer = cbClient.tells("Employee in Class end");
      sAnswer = cbClient.asks("get_object[Employee/objname]");
      System.out.println(sAnswer);
      sAnswer = cbClient.disconnect();
  }
}

