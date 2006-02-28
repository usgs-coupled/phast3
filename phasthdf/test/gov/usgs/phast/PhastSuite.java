/*
 * PhastSuite.java
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
public class PhastSuite extends NbTestCase {
    
    public PhastSuite(java.lang.String testName) {
        super(testName);
    }
    
    public static void main(java.lang.String[] args) {
        junit.textui.TestRunner.run(suite());
    }
    
    public static Test suite() {
        //--JUNIT:
        //This block was automatically generated and can be regenerated again.
        //Do NOT change lines enclosed by the --JUNIT: and :JUNIT-- tags.
        
        TestSuite suite = new NbTestSuite("PhastSuite");
        suite.addTest(gov.usgs.phast.JCheckListTest.suite());
        suite.addTest(gov.usgs.phast.JPage1Test.suite());
        suite.addTest(gov.usgs.phast.JPage2Test.suite());
        suite.addTest(gov.usgs.phast.JPage2TabTest.suite());
        suite.addTest(gov.usgs.phast.JPage3Test.suite());
        suite.addTest(gov.usgs.phast.JPhastHDFTest.suite());
        suite.addTest(gov.usgs.phast.JWizardFrameTest.suite());
        suite.addTest(gov.usgs.phast.JWizardPanelTest.suite());
        suite.addTest(gov.usgs.phast.ModalProgressMonitorTest.suite());
        suite.addTest(gov.usgs.phast.PhastH5FileTest.suite());
        //:JUNIT--
        //This value MUST ALWAYS be returned from this function.
        return suite;
    }
    
    // Add test methods here, they have to start with 'test' name.
    // for example:
    // public void testHello() {}
    
    
    
}
