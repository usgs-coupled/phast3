/*
 * IProgressMonitor.java
 *
 * Created on August 8, 2002, 7:55 PM
 */

package gov.usgs.phast;

/**
 *
 * @author  charlton
 */
public interface IProgressMonitor {

    public void setProgress(int nv);

    public void setMinimum(int m);

    public void setMaximum(int m);

    public boolean isCanceled();

    public void setNote(String note);
    
}
