/*
 * JPage1Test.java
 * NetBeans JUnit based test
 *
 * Created on September 17, 2002, 10:05 PM
 */

package gov.usgs.phast;

import junit.framework.*;

/**
 *
 * @author charlton
 */
public class JPage1Test extends TestCase {

    public JPage1Test(java.lang.String testName) {
        super(testName);
    }

    public static void main(java.lang.String[] args) {
        junit.textui.TestRunner.run(suite());
    }

    public static Test suite() {
        TestSuite suite = new TestSuite(JPage1Test.class);

        return suite;
    }

    /** Test of vetoableChange method, of class gov.usgs.phast.JPage1. */
    public void testVetoableChange() {
        System.out.println("testVetoableChange");

        // Add your test code below by replacing the default call to fail.
        Assert.fail("The test case is empty.");
    }

    /** Test of getText method, of class gov.usgs.phast.JPage1. */
    public void testGetText() {
        System.out.println("testGetText");

        // Add your test code below by replacing the default call to fail.
        Assert.fail("The test case is empty.");
    }

    /** Test of setText method, of class gov.usgs.phast.JPage1. */
    public void testSetText() {
        System.out.println("testSetText");

        // Add your test code below by replacing the default call to fail.
        Assert.fail("The test case is empty.");
    }

    // Add test methods here, they have to start with 'test' name.
    // for example:
    // public void testHello() {}



}
