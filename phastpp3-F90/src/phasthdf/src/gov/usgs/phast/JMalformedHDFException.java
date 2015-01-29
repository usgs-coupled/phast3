/*
 * JMalformedHDFException.java
 *
 * Created on July 25, 2002, 6:39 PM
 */

package gov.usgs.phast;

/**
 *
 * @author  charlton
 */
public class JMalformedHDFException extends java.lang.Exception {
    
    /**
     * Creates a new instance of <code>JMalformedHDFException</code> without detail message.
     */
    public JMalformedHDFException() {
    }
    
    
    /**
     * Constructs an instance of <code>JMalformedHDFException</code> with the specified detail message.
     * @param msg the detail message.
     */
    public JMalformedHDFException(String msg) {
        super(msg);
    }
}
