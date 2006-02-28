/*
 * JPage2Tab.java
 *
 * Created on July 24, 2002, 8:57 PM
 */

package gov.usgs.phast;

/**
 *
 * @author  charlton
 */
public class JPage2Tab extends javax.swing.JPanel {
    
    /** Creates new form JPage2Tab */
    public JPage2Tab() {
        initComponents();
        
        /* if jdk 1.4        
        java.awt.GridBagConstraints gridBagConstraints;
        
        // start spinner
        jstartSpinner = new javax.swing.JSpinner();
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 0;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
        gridBagConstraints.weighty = 1.0;
        jHyperSlabPanel.add(jstartSpinner, gridBagConstraints);
        
        // stride spinner
        jstrideSpinner = new javax.swing.JSpinner();        
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 1;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
        gridBagConstraints.weighty = 1.0;
        jHyperSlabPanel.add(jstrideSpinner, gridBagConstraints);

        // count spinner
        jcountSpinner = new javax.swing.JSpinner();        
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 3;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
        gridBagConstraints.weighty = 1.0;
        jHyperSlabPanel.add(jcountSpinner, gridBagConstraints);
        
        org.openide.awt.SpinButton test = new org.openide.awt.SpinButton();
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 4;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
        // gridBagConstraints.weighty = 1.0;
        jHyperSlabPanel.add(test, gridBagConstraints);        
        
        jCheckBox1.setSelected(false);
        
        jstartSpinner.setValue(new Integer(0));
        jstartSpinner.setEnabled(jCheckBox1.isSelected());        
        jstartSpinner.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                int start = ((Integer)jstartSpinner.getValue()).intValue();
                int stride = ((Integer)jstrideSpinner.getValue()).intValue();
                setHyperSlab(start, stride, Integer.MAX_VALUE);
            }
        });        
        
        jstrideSpinner.setValue(new Integer(1));
        jstrideSpinner.setEnabled(jCheckBox1.isSelected());      
        jstrideSpinner.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                int start = ((Integer)jstartSpinner.getValue()).intValue();
                int stride = ((Integer)jstrideSpinner.getValue()).intValue();
                setHyperSlab(start, stride, Integer.MAX_VALUE);
            }
        });
        
        jcountSpinner.setEnabled(jCheckBox1.isSelected());      
        jcountSpinner.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                int start = ((Integer)jstartSpinner.getValue()).intValue();
                int stride = ((Integer)jstrideSpinner.getValue()).intValue();
                int count = ((Integer)jcountSpinner.getValue()).intValue();
                setHyperSlab(start, stride, count);
            }
        });        
        */
    }
    
    public void setHyperSlab(int start, int stride, int count) {        
        final int size = jCheckList1.getModel().getSize();        
        int maxcount = 0;
        for (int i = start; i < size; i += stride) {
            ++maxcount;
        }
        int test = ((size - start) + ((size - start) % stride)) / stride;
        int length = Math.min(maxcount, count);
        
        /* if jdk 1.4     
        jcountSpinner.setModel(new javax.swing.SpinnerNumberModel(length, 0, maxcount, 1));        
        */
        ((javax.swing.DefaultComboBoxModel)jcountComboBox.getModel()).removeAllElements();
        for (int i = 0; i <= maxcount; ++i) {
            ((javax.swing.DefaultComboBoxModel)jcountComboBox.getModel()).addElement(new Integer(i));
        }
        jcountComboBox.setSelectedIndex(length);        
        
        jCheckList1.clearSelection();
        if (length > 0) {
            int[] selectedIndices = new int[length];
            int j = 0;
            for (int i = start; j < length; i += stride, ++j) {
                selectedIndices[j] = i;
            }
            jCheckList1.setSelectedIndices(selectedIndices);
        }  
    }
    
    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    private void initComponents() {//GEN-BEGIN:initComponents
        java.awt.GridBagConstraints gridBagConstraints;

        jScrollPane1 = new javax.swing.JScrollPane();
        jCheckList1 = new gov.usgs.phast.JCheckList();
        jPanel2 = new javax.swing.JPanel();
        jSelectAllButton = new javax.swing.JButton();
        jSelectNoneButton = new javax.swing.JButton();
        jHyperSlabPanel = new javax.swing.JPanel();
        jcheckButton = new javax.swing.JButton();
        juncheckButton = new javax.swing.JButton();
        jtoggleButton = new javax.swing.JButton();
        jLabel1 = new javax.swing.JLabel();
        jLabel2 = new javax.swing.JLabel();
        jLabel3 = new javax.swing.JLabel();
        jstartComboBox = new javax.swing.JComboBox();
        jstrideComboBox = new javax.swing.JComboBox();
        jcountComboBox = new javax.swing.JComboBox();
        jPanel1 = new javax.swing.JPanel();

        setLayout(new java.awt.GridBagLayout());

        jScrollPane1.setViewportView(jCheckList1);

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridheight = 2;
        gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
        gridBagConstraints.weightx = 1.0;
        gridBagConstraints.weighty = 1.0;
        gridBagConstraints.insets = new java.awt.Insets(5, 5, 5, 5);
        add(jScrollPane1, gridBagConstraints);

        jPanel2.setLayout(new java.awt.GridBagLayout());

        jSelectAllButton.setFont(new java.awt.Font("Dialog", 0, 11));
        jSelectAllButton.setText("Select All");
        jSelectAllButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jSelectAllButtonActionPerformed(evt);
            }
        });

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 0;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
        jPanel2.add(jSelectAllButton, gridBagConstraints);

        jSelectNoneButton.setFont(new java.awt.Font("Dialog", 0, 11));
        jSelectNoneButton.setText("Select None");
        jSelectNoneButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jSelectNoneButtonActionPerformed(evt);
            }
        });

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 1;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.insets = new java.awt.Insets(2, 2, 2, 2);
        jPanel2.add(jSelectNoneButton, gridBagConstraints);

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 1;
        gridBagConstraints.gridy = 0;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.weightx = 0.5;
        gridBagConstraints.insets = new java.awt.Insets(5, 5, 2, 5);
        add(jPanel2, gridBagConstraints);

        jHyperSlabPanel.setLayout(new java.awt.GridBagLayout());

        jHyperSlabPanel.setBorder(new javax.swing.border.TitledBorder("Hyperslab selection"));
        ((javax.swing.border.TitledBorder)jHyperSlabPanel.getBorder()).setTitleFont(new java.awt.Font("Dialog", 0, 11));
        jcheckButton.setFont(new java.awt.Font("Dialog", 0, 11));
        jcheckButton.setText("Select");
        jcheckButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jcheckButtonActionPerformed(evt);
            }
        });

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 3;
        gridBagConstraints.gridwidth = 2;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTH;
        gridBagConstraints.weightx = 1.0;
        gridBagConstraints.insets = new java.awt.Insets(3, 3, 3, 3);
        jHyperSlabPanel.add(jcheckButton, gridBagConstraints);

        juncheckButton.setFont(new java.awt.Font("Dialog", 0, 11));
        juncheckButton.setText("Unselect");
        juncheckButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                juncheckButtonActionPerformed(evt);
            }
        });

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 2;
        gridBagConstraints.gridy = 3;
        gridBagConstraints.gridwidth = 2;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTH;
        gridBagConstraints.weightx = 1.0;
        gridBagConstraints.insets = new java.awt.Insets(3, 3, 3, 3);
        jHyperSlabPanel.add(juncheckButton, gridBagConstraints);

        jtoggleButton.setFont(new java.awt.Font("Dialog", 0, 11));
        jtoggleButton.setText("Toggle");
        jtoggleButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jtoggleButtonActionPerformed(evt);
            }
        });

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 4;
        gridBagConstraints.gridy = 3;
        gridBagConstraints.gridwidth = 2;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.anchor = java.awt.GridBagConstraints.NORTH;
        gridBagConstraints.weightx = 1.0;
        gridBagConstraints.insets = new java.awt.Insets(3, 3, 3, 3);
        jHyperSlabPanel.add(jtoggleButton, gridBagConstraints);

        jLabel1.setFont(new java.awt.Font("Dialog", 0, 11));
        jLabel1.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
        jLabel1.setText("Start");
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 0;
        gridBagConstraints.gridwidth = 3;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.weightx = 1.0;
        gridBagConstraints.insets = new java.awt.Insets(0, 0, 0, 5);
        jHyperSlabPanel.add(jLabel1, gridBagConstraints);

        jLabel2.setFont(new java.awt.Font("Dialog", 0, 11));
        jLabel2.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
        jLabel2.setText("Stride");
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 1;
        gridBagConstraints.gridwidth = 3;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.insets = new java.awt.Insets(0, 0, 0, 5);
        jHyperSlabPanel.add(jLabel2, gridBagConstraints);

        jLabel3.setFont(new java.awt.Font("Dialog", 0, 11));
        jLabel3.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
        jLabel3.setText("Count");
        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 2;
        gridBagConstraints.gridwidth = 3;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.insets = new java.awt.Insets(0, 0, 0, 5);
        jHyperSlabPanel.add(jLabel3, gridBagConstraints);

        jstartComboBox.setFont(new java.awt.Font("Dialog", 0, 11));
        jstartComboBox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jstartComboBoxActionPerformed(evt);
            }
        });

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 3;
        gridBagConstraints.gridy = 0;
        gridBagConstraints.gridwidth = 2;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
        gridBagConstraints.insets = new java.awt.Insets(3, 3, 3, 3);
        jHyperSlabPanel.add(jstartComboBox, gridBagConstraints);

        jstrideComboBox.setFont(new java.awt.Font("Dialog", 0, 11));
        jstrideComboBox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jstrideComboBoxActionPerformed(evt);
            }
        });

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 3;
        gridBagConstraints.gridy = 1;
        gridBagConstraints.gridwidth = 2;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
        gridBagConstraints.insets = new java.awt.Insets(3, 3, 3, 3);
        jHyperSlabPanel.add(jstrideComboBox, gridBagConstraints);

        jcountComboBox.setFont(new java.awt.Font("Dialog", 0, 11));
        jcountComboBox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jcountComboBoxActionPerformed(evt);
            }
        });

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 3;
        gridBagConstraints.gridy = 2;
        gridBagConstraints.gridwidth = 2;
        gridBagConstraints.fill = java.awt.GridBagConstraints.HORIZONTAL;
        gridBagConstraints.anchor = java.awt.GridBagConstraints.WEST;
        gridBagConstraints.insets = new java.awt.Insets(3, 3, 3, 3);
        jHyperSlabPanel.add(jcountComboBox, gridBagConstraints);

        jPanel1.setLayout(null);

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 0;
        gridBagConstraints.gridy = 4;
        gridBagConstraints.gridwidth = 6;
        gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
        gridBagConstraints.weighty = 1.0;
        jHyperSlabPanel.add(jPanel1, gridBagConstraints);

        gridBagConstraints = new java.awt.GridBagConstraints();
        gridBagConstraints.gridx = 1;
        gridBagConstraints.gridy = 1;
        gridBagConstraints.fill = java.awt.GridBagConstraints.BOTH;
        gridBagConstraints.weighty = 1.0;
        gridBagConstraints.insets = new java.awt.Insets(2, 5, 5, 5);
        add(jHyperSlabPanel, gridBagConstraints);

    }//GEN-END:initComponents

    private void jtoggleButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jtoggleButtonActionPerformed
        int start  = ((Integer) jstartComboBox.getModel().getSelectedItem()).intValue();
        int stride = ((Integer) jstrideComboBox.getModel().getSelectedItem()).intValue();
        int count  = ((Integer) jcountComboBox.getModel().getSelectedItem()).intValue();
        setHyperSlab(start, stride, count);        
        for(int i = 0; i < jCheckList1.getModel().getSize(); i++) {
            if (jCheckList1.isSelectedIndex(i)) {
                jCheckList1.setSelected(i, !jCheckList1.isSelected(i));
            }
        }
    }//GEN-LAST:event_jtoggleButtonActionPerformed

    private void juncheckButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_juncheckButtonActionPerformed
        int start  = ((Integer) jstartComboBox.getModel().getSelectedItem()).intValue();
        int stride = ((Integer) jstrideComboBox.getModel().getSelectedItem()).intValue();
        int count  = ((Integer) jcountComboBox.getModel().getSelectedItem()).intValue();
        setHyperSlab(start, stride, count);        
        for(int i = 0; i < jCheckList1.getModel().getSize(); i++) {
            if (jCheckList1.isSelectedIndex(i)) {
                jCheckList1.setSelected(i, false);
            }
        }
    }//GEN-LAST:event_juncheckButtonActionPerformed

    private void jcheckButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jcheckButtonActionPerformed
        int start  = ((Integer) jstartComboBox.getModel().getSelectedItem()).intValue();
        int stride = ((Integer) jstrideComboBox.getModel().getSelectedItem()).intValue();
        int count  = ((Integer) jcountComboBox.getModel().getSelectedItem()).intValue();
        setHyperSlab(start, stride, count);        
        for(int i = 0; i < jCheckList1.getModel().getSize(); i++) {
            if (jCheckList1.isSelectedIndex(i)) {
                jCheckList1.setSelected(i, true);
            }
        }
    }//GEN-LAST:event_jcheckButtonActionPerformed

    private void jcountComboBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jcountComboBoxActionPerformed
        try {
            int start  = ((Integer) jstartComboBox.getModel().getSelectedItem()).intValue();
            int stride = ((Integer) jstrideComboBox.getModel().getSelectedItem()).intValue();
            int count  = ((Integer) jcountComboBox.getModel().getSelectedItem()).intValue();
            setHyperSlab(start, stride, count);
        } catch (java.lang.NullPointerException e) {}
    }//GEN-LAST:event_jcountComboBoxActionPerformed

    private void jstrideComboBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jstrideComboBoxActionPerformed
        try {
            int start  = ((Integer) jstartComboBox.getModel().getSelectedItem()).intValue();
            int stride = ((Integer) jstrideComboBox.getModel().getSelectedItem()).intValue();
            setHyperSlab(start, stride, Integer.MAX_VALUE);        
        } catch (java.lang.NullPointerException e) {}
    }//GEN-LAST:event_jstrideComboBoxActionPerformed

    private void jstartComboBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jstartComboBoxActionPerformed
        try {
            int start  = ((Integer) jstartComboBox.getModel().getSelectedItem()).intValue();
            int stride = ((Integer) jstrideComboBox.getModel().getSelectedItem()).intValue();
            setHyperSlab(start, stride, Integer.MAX_VALUE);        
        } catch (java.lang.NullPointerException e) {}
    }//GEN-LAST:event_jstartComboBoxActionPerformed

    private void jSelectAllButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jSelectAllButtonActionPerformed
        for (int i = 0; i < jCheckList1.getModel().getSize(); ++i) {
            jCheckList1.setSelected(i, true);
        }        
    }//GEN-LAST:event_jSelectAllButtonActionPerformed

    private void jSelectNoneButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jSelectNoneButtonActionPerformed
        for (int i = 0; i < jCheckList1.getModel().getSize(); ++i) {
            jCheckList1.setSelected(i, false);
        }        
    }//GEN-LAST:event_jSelectNoneButtonActionPerformed

    public void setListData(Object[] objs) {
        
        /* if jdk 1.4        
        try {
            jstartSpinner.setModel(new javax.swing.SpinnerNumberModel(0, 0, objs.length - 1, 1));
            jstrideSpinner.setModel(new javax.swing.SpinnerNumberModel(1, 1, objs.length, 1));
            jcountSpinner.setModel(new javax.swing.SpinnerNumberModel(objs.length, 0, objs.length, 1));
        } catch (Exception e) { System.out.println("setListData: " + e); }
         */
        
        if (objs == null) {
            jLabel3.setEnabled(false);
            jLabel2.setEnabled(false);
            jLabel1.setEnabled(false);
            jstartComboBox.setEnabled(false);
            jcountComboBox.setEnabled(false);
            jstrideComboBox.setEnabled(false);
            juncheckButton.setEnabled(false);
            jcheckButton.setEnabled(false);
            jtoggleButton.setEnabled(false);
            jHyperSlabPanel.setEnabled(false);
            return;
        }
        
        try {            
            jCheckList1.setListData(objs);
            
            Integer[] ints = new Integer[objs.length];
            for (int i = 0; i < objs.length; ++i) {
                ints[i] = new Integer(i);
            }
            
            Integer[] start_ints = new Integer[objs.length];                
            System.arraycopy(ints, 0, start_ints, 0, start_ints.length);
            jstartComboBox.setModel(new javax.swing.DefaultComboBoxModel(start_ints));
            
            if (objs.length > 1) {
                Integer[] stride_ints = new Integer[objs.length - 1];
                System.arraycopy(ints, 1, stride_ints, 0, stride_ints.length);
                jstrideComboBox.setModel(new javax.swing.DefaultComboBoxModel(stride_ints));
            }
            else {
                Integer[] stride_ints = new Integer[1];
                stride_ints[0] = new Integer(1);
                jstrideComboBox.setModel(new javax.swing.DefaultComboBoxModel(stride_ints));
            }
            
            jcountComboBox.setModel(new javax.swing.DefaultComboBoxModel(ints));
            jcountComboBox.setSelectedIndex(objs.length - 1);
            
            setHyperSlab(0, 1, objs.length);           
        } catch (Exception e) {
            System.out.println("setListData: " + e);
            e.printStackTrace(System.out);
        } finally {
            jCheckList1.clearSelection();            
        }
    }
    
    public boolean[] getSelected() {
        return jCheckList1.getSelected();
    }
    
    
    
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JPanel jPanel2;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JButton juncheckButton;
    private gov.usgs.phast.JCheckList jCheckList1;
    private javax.swing.JComboBox jstartComboBox;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JButton jcheckButton;
    private javax.swing.JButton jSelectNoneButton;
    private javax.swing.JPanel jHyperSlabPanel;
    private javax.swing.JComboBox jcountComboBox;
    private javax.swing.JButton jtoggleButton;
    private javax.swing.JButton jSelectAllButton;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JComboBox jstrideComboBox;
    // End of variables declaration//GEN-END:variables
 
 
    /* if jdk 1.4
    javax.swing.JSpinner jstartSpinner;
    javax.swing.JSpinner jstrideSpinner;
    javax.swing.JSpinner jcountSpinner;
    */
}
