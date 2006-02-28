/*
 * JWizardPanelTest.java
 *
 * Created on July 24, 2002, 2:37 PM
 */

package gov.usgs.phast;

/**
 * Main container.
 *
 * @author  charlton
 */
public class JWizardFrame extends javax.swing.JFrame implements java.beans.VetoableChangeListener {
    
    public JWizardFrame(String[] args) {
        super("Phast HDF Exporter");
        addWindowListener(new java.awt.event.WindowAdapter() {
            public void windowClosing(java.awt.event.WindowEvent evt) {
                System.exit(0);
            }
        });
        wizard = new JWizardPanel();
        wizard.addVetoableChangeListener(this);
        wizard.setEnabledFinish(false);
        
        page1 = new JPage1();
        if (args.length > 0) {
            java.io.File file = new java.io.File(args[0]);
            if (file.canRead()) {
                try {
                    file.getCanonicalPath();
                    page1.setText(file.getCanonicalPath());
                } catch (java.io.IOException e) {
                    page1.setText(file.getPath());
                }
            }
        }
        wizard.addComponent(page1);
        
        page2 = new JPage2();
        wizard.addComponent(page2);
        
        page3 = new JPage3();
        wizard.addComponent(page3);
        
        getContentPane().add(wizard);
        pack();
    }
    
    
    public static void main(String args[]) {
        // display splash ASAP
        gov.usgs.Splash splash = new gov.usgs.Splash();
        
        if (Boolean.getBoolean("phast.debug")) {
            java.util.Properties props = System.getProperties();
            for (java.util.Enumeration e = props.propertyNames(); e.hasMoreElements(); ) {
                String key = (String)e.nextElement();
                System.out.println(key + "=" + props.getProperty(key));
            }            
        }
        
        try {
            if (System.getProperty("swing.defaultlaf") == null) {
                javax.swing.UIManager.setLookAndFeel(
                javax.swing.UIManager.getSystemLookAndFeelClassName()
                );
            }
        } catch (Exception e) {
            if (Boolean.getBoolean("phast.debug")) {
                e.printStackTrace(System.out);
            }
        }

        JWizardFrame frame = new JWizardFrame(args);
        java.awt.Dimension screenSize = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
        java.awt.Dimension d = frame.getSize();
        frame.getRootPane().setMinimumSize(d);
        frame.setLocation((screenSize.width - d.width) / 2,(screenSize.height - d.height) / 2);
        frame.show();
        splash.dispose();
    }
    
    public void vetoableChange(java.beans.PropertyChangeEvent propertyChangeEvent) throws java.beans.PropertyVetoException {
        if (propertyChangeEvent.getSource().equals(wizard)) {
            
            
            // page changing
            if (propertyChangeEvent.getPropertyName().equals(JWizardPanel.PAGE_CHANGING_PROPERTY)) {
                Object oldObj = propertyChangeEvent.getOldValue();
                Object newObj = propertyChangeEvent.getNewValue();
                
                // Page 1 ==> Page 2
                if (oldObj.equals(page1)) {
                    String str = page1.getText();
                    String file_name = ((str == null) ? "" : str.trim());
                    
                    if (file_name == null || file_name.length() == 0) {
                        javax.swing.JOptionPane.showMessageDialog(this,
                        "Please enter a complete path and filename",
                        "Phast HDF Exporter",
                        javax.swing.JOptionPane.ERROR_MESSAGE);
                        throw new java.beans.PropertyVetoException("No file name",
                        propertyChangeEvent);
                    }
                    
                    java.io.File file = new java.io.File(file_name);
                    if (!file.exists()) {
                        javax.swing.JOptionPane.showMessageDialog(this,
                        "Cannot find " + file_name + ".\n" +
                        "Please choose another file.",
                        "Phast HDF Exporter",
                        javax.swing.JOptionPane.ERROR_MESSAGE);
                        throw new java.beans.PropertyVetoException("Bad file name",
                        propertyChangeEvent);
                    }
                    if (!file.isFile()) {
                        javax.swing.JOptionPane.showMessageDialog(this,
                        "Please enter a complete path and filename",
                        "Phast HDF Exporter",
                        javax.swing.JOptionPane.ERROR_MESSAGE);
                        throw new java.beans.PropertyVetoException("Bad file name",
                        propertyChangeEvent);
                    }
                    if (!PhastH5File.isThisTypeStatic(file_name)) {
                        javax.swing.JOptionPane.showMessageDialog(this,
                        "Unrecognized HDF format.\n Please choose another file.",
                        "Phast HDF Exporter",
                        javax.swing.JOptionPane.ERROR_MESSAGE);
                        throw new java.beans.PropertyVetoException("Bad file name",
                        propertyChangeEvent);
                    }
                    try {
                        hdf = new PhastH5File(file_name);
                        page2.setPhastH5File(hdf);
                        page3.setText(hdf.getFilePath().concat(".sel"));
                        wizard.setEnabledFinish(true);
                    }
                    catch (java.lang.Exception e) {
                        System.err.println(e.getLocalizedMessage());
                    }
                }
                
                // Page 2 ==> Page 1
                if (oldObj.equals(page2) && newObj.equals(page1)) {
                    wizard.setEnabledFinish(false);
                }
                
                // Page 2 ==> Page 3
                if (oldObj.equals(page2) && newObj.equals(page3)) {
                    // for now any selection including none is acceptable
                }
            }
            
            // Finished pressed
            if (propertyChangeEvent.getPropertyName().equals(JWizardPanel.FINISH_PRESSED_PROPERTY)) {
                
                String str = page3.getText();
                String file_name = ((str == null) ? "" : str.trim());
                
                if (file_name == null || file_name.length() == 0) {
                    javax.swing.JOptionPane.showMessageDialog(this,
                    "Please enter a complete path and filename",
                    "Phast HDF Exporter",
                    javax.swing.JOptionPane.ERROR_MESSAGE);
                    throw new java.beans.PropertyVetoException("No file name",
                    propertyChangeEvent);
                }              
                java.io.File dest = new java.io.File(file_name);
                if (dest.exists()) {
                    try {
                        java.io.File src = new java.io.File(page1.getText());
                        if (dest.getCanonicalPath().equals(src.getCanonicalPath())) {
                            javax.swing.JOptionPane.showMessageDialog(this,
                            "Output file cannot be the same as the input file.",
                            "Phast HDF Exporter",
                            javax.swing.JOptionPane.ERROR_MESSAGE);
                            return;
                        }
                    }
                    catch (java.io.IOException e) {
                        if (Boolean.getBoolean("phast.debug")) {
                            e.printStackTrace(System.out);
                        }
                    }
                    if (javax.swing.JOptionPane.YES_OPTION !=
                    javax.swing.JOptionPane.showConfirmDialog(this,
                    dest.getAbsolutePath() + " already exists.  Do you want to replace it?",
                    "Phast HDF Exporter",
                    javax.swing.JOptionPane.YES_NO_OPTION,
                    javax.swing.JOptionPane.QUESTION_MESSAGE)) {
                        return;
                    }
                }
                
                wizard.setEnabledFinish(false);
                hdf.setSelectedX(page2.getSelectedX());
                hdf.setSelectedY(page2.getSelectedY());
                hdf.setSelectedZ(page2.getSelectedZ());
                hdf.setSelectedTimes(page2.getSelectedTimes());
                hdf.setSelectedScalars(page2.getSelectedScalars());
                hdf.setSelectedVectors(page2.getSelectedVectors());
                
                final sample.SwingWorker worker = new sample.SwingWorker() {
                    public Object construct() {
                        try {
                            java.io.FileOutputStream output =
                            new java.io.FileOutputStream(page3.getText());
                            IProgressMonitor progressMonitor =
                            new ModalProgressMonitor(JWizardFrame.this, null, null, 0, 100);
                            hdf.writeSelected(output, progressMonitor);
                            if (!progressMonitor.isCanceled()) {
                                System.exit(0);
                            }
                        } catch (java.io.FileNotFoundException e) {
                            javax.swing.JOptionPane.showMessageDialog(JWizardFrame.this,
                            e.getLocalizedMessage(),
                            "Phast HDF Exporter",
                            javax.swing.JOptionPane.ERROR_MESSAGE);
                        } catch (java.lang.OutOfMemoryError e) {
                            try {
                                javax.swing.JOptionPane.showMessageDialog(JWizardFrame.this,
                                "Unable to complete, out of memory",
                                "Phast HDF Exporter",
                                javax.swing.JOptionPane.ERROR_MESSAGE);
                                System.err.println(e.getLocalizedMessage());
                            }
                            finally {
                                System.err.println("Phast HDF Exporter: Out of memory.");
                                System.exit(-1);
                            }                            
                        } catch (java.lang.Throwable e) {
                            javax.swing.JOptionPane.showMessageDialog(JWizardFrame.this,
                            e.getLocalizedMessage(),
                            "Phast HDF Exporter",
                            javax.swing.JOptionPane.ERROR_MESSAGE);                            
                        } finally {
                            wizard.setEnabledFinish(true);
                        }
                        return null;
                    }
                };
                worker.start();  //required for SwingWorker 3
            }
        }
    }
    
    private JWizardPanel wizard;
    private PhastH5File hdf;
    private JPage1 page1;
    private JPage2 page2;
    private JPage3 page3;
}
