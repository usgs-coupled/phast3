/*
 * CorejavaSuite.java
 * NetBeans JUnit based test
 *
 * Created on September 17, 2002, 10:04 PM
 */

package corejava;

import junit.framework.*;
import org.netbeans.junit.*;

/**
 *
 * @author charlton
 */
public class CorejavaSuite extends NbTestCase {
    
    public CorejavaSuite(java.lang.String testName) {
        super(testName);
    }
    
    public static void main(java.lang.String[] args) {
        junit.textui.TestRunner.run(suite());
    }
    
    public static Test suite() {
        //--JUNIT:
        //This block was automatically generated and can be regenerated again.
        //Do NOT change lines enclosed by the --JUNIT: and :JUNIT-- tags.
        
        TestSuite suite = new NbTestSuite("CorejavaSuite");
        suite.addTest(corejava.FormatTest.suite());
        //:JUNIT--
        //This value MUST ALWAYS be returned from this function.
        return suite;
    }
    
    // Add test methods here, they have to start with 'test' name.
    // for example:
    // public void testHello() {}
    
    
    
}
