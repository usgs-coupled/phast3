/*
 * Class.java
 *
 * Created on August 8, 2002, 8:18 PM
 */

package gov.usgs.phast;

import java.awt.Component;
import javax.swing.JLabel;
import javax.swing.JOptionPane;

/**
 *
 * @author  charlton
 */
public class ModalProgressMonitor extends Object implements gov.usgs.phast.IProgressMonitor {

    private int                       max;
    private int                       min;
    private String                    note;
    private javax.swing.JDialog       dialog;
    private javax.swing.JProgressBar  bar;
    private java.awt.Component        parent;
    private javax.swing.JOptionPane   pane;
    private javax.swing.JLabel        noteLabel;
    private Object                    message;
    private boolean                   canceled;
    private long                      T0;
    private long                      millisToPopup = 750;

    public ModalProgressMonitor(Component parentComponent, Object message, String note, int min, int max) {
        this.min    = min;
        this.max    = max;
        this.parent = parentComponent;
        this.note   = note;
        this.T0     = System.currentTimeMillis();
    }

    public boolean isCanceled() {
        return canceled;
    }

    public void setMaximum(int m) {
        max = m;
    }

    public void setMinimum(int m) {
        min = min;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public void setProgress(int nv) {
        if (nv >= max) {
            if (dialog != null) {
                bar.setValue(bar.getMaximum());
                dialog.setVisible(false);
                dialog.dispose();
                dialog = null;
                canceled = false;
                return;
            }
        }
        if ((dialog == null) && ((System.currentTimeMillis() - T0) >= millisToPopup)) {
            bar = new javax.swing.JProgressBar(min, max);
            bar.setValue(nv);
            if (note != null) noteLabel = new JLabel(note);
            pane = new JOptionPane(new Object[] {message, noteLabel, bar}, JOptionPane.INFORMATION_MESSAGE, JOptionPane.DEFAULT_OPTION, null, new Object[] {"Cancel"}, null);
            dialog = pane.createDialog(parent, javax.swing.UIManager.getString("ProgressMonitor.progressText"));
            final sample.SwingWorker worker = new sample.SwingWorker() {
                public Object construct() {
                    dialog.setVisible(true);
                    dialog.setVisible(false);
                    dialog.dispose();
                    dialog = null;
                    canceled = true;
                    return null;
                }
            };
            worker.start();  // required for SwingWorker 3
        }
        else if (dialog != null) {
            bar.setValue(nv);
        }
    }
}
