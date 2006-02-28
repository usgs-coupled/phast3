/*
 * FormatTest.java
 * JUnit based test
 *
 * Created on August 22, 2002, 4:37 PM
 */

package corejava;

import junit.framework.*;
import java.io.*;
import org.netbeans.junit.*;

/**
 *
 * @author charlton
 */
public class FormatTest extends NbTestCase {
    
    public FormatTest(java.lang.String testName) {
        super(testName);
    }
    
    public static void main(java.lang.String[] args) {
        junit.textui.TestRunner.run(suite());
    }
    
    /** Test of atof method, of class corejava.Format. */
    public void testAtof() {
        System.out.println("testAtof");
        
        String s1 = "  -2309.12E-15";
        double x1 = corejava.Format.atof(s1);
        corejava.Format e = new corejava.Format("%e");
        assertTrue(e.form(x1).equals("-2.309120e-012"));
        
        String s2 = "7.8912654773e210";
        double x2 = corejava.Format.atof(s2);
        assertTrue(e.form(x2).equals("7.891265e+210"));
    }
    
    /** Test of atoi method, of class corejava.Format. */
    public void testAtoi() {
        System.out.println("testAtoi");
        String s = "  -9885 pigs";      /* Test of atoi */
        int i = corejava.Format.atoi(s);
        assertTrue(i == -9885);        
        corejava.Format dFormat = new corejava.Format("%d");
        assertTrue(dFormat.form(i).equals("-9885"));
    }
    
    /** Test of atol method, of class corejava.Format. */
    public void testAtol() {
        System.out.println("testAtol");
        
        String s = "98854 dollars";
        long l = corejava.Format.atol(s);
        assertTrue(l == 98854l);
        corejava.Format dFormat = new corejava.Format("%d");
        assertTrue(dFormat.form(l).equals("98854"));
    }
    
    /** Test of form method, of class corejava.Format. */
    public void testForm() {
        System.out.println("testForm");
        
        corejava.Format format12_4e = new corejava.Format("%12.4e");
        String str = format12_4e.form(-0.0299997);
        assertTrue(str.equals("-3.0000e-002"));
    }
    
    /** Test of print method, of class corejava.Format. */
    public void testPrint() {
        System.out.println("testPrint");
        
        java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
        java.io.PrintStream ps = new java.io.PrintStream(baos);
        corejava.Format.print(ps, "%12.4e", -0.0299997);
        assertTrue(baos.toString().equals("-3.0000e-002"));        
    }
    
    public static Test suite() {
        TestSuite suite = new NbTestSuite(FormatTest.class);
        
        return suite;
    }
    
    // Add test methods here, they have to start with 'test' name.
    // for example:
    // public void testHello() {}
    
    
}
