/*
 * JWizardFrameTest.java
 * NetBeans JUnit based test
 *
 * Created on September 17, 2002, 10:05 PM
 */

package gov.usgs.phast;

import junit.framework.*;
import org.netbeans.junit.*;

/**
 *
 * @author charlton
 */
public class JWizardFrameTest extends NbTestCase {
    
    public JWizardFrameTest(java.lang.String testName) {
        super(testName);
    }
    
    public static void main(java.lang.String[] args) {
        junit.textui.TestRunner.run(suite());
    }
    
    public static Test suite() {
        TestSuite suite = new NbTestSuite(JWizardFrameTest.class);
        
        return suite;
    }
    
    /** Test of vetoableChange method, of class gov.usgs.phast.JWizardFrame. */
    public void testVetoableChange() {
        System.out.println("testVetoableChange");
        
        // Add your test code below by replacing the default call to fail.
        fail("The test case is empty.");
    }
    
    // Add test methods here, they have to start with 'test' name.
    // for example:
    // public void testHello() {}
    
    
    
}
