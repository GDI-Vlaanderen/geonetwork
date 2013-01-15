package org.fao.geonet.util;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Simple runnable class to do small tests.
 */
public class Tester {

    public static void main(String[] args) {
        try {
            Tester t = new Tester();
            t.test();
        }
        catch(Throwable x) {
            System.err.println("Error: " + x.getMessage());
            x.printStackTrace();
        }
    }

    private void test() throws Exception{
        System.out.println("start test");

        String s = "Fri Sep 22 07:57:15 CEST 2006 ";
        s = "Fry Sep 22 07:57:15 CEST 2009";

        if(s.startsWith("Fry")) {
            s = s.replace("Fry", "Fri");
        }
        //s = "2006-09-22 07:57:15";
        DateFormat df = new SimpleDateFormat("EEE MMM dd HH:mm:ss zzz yyyy");
        df = new SimpleDateFormat("EEE MMM d HH:mm:ss z yyyy");
        //df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date result = df.parse(s);


        System.out.println("end test");
    }


}
