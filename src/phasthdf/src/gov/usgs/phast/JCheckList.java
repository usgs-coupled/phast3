/*
 * JCheckBoxList.java
 *
 * Created on July 17, 2002, 1:39 PM
 */

package gov.usgs.phast;

/**
 *
 * @author  charlton
 */
public class JCheckList extends javax.swing.JList implements java.io.Serializable {

    public JCheckList() {
        super();
        
        JCheckListCellRenderer cellRenderer = new JCheckListCellRenderer();
        setCellRenderer(cellRenderer);
        
        JCheckListMouseListener mouseListener = new JCheckListMouseListener();
        addMouseListener(mouseListener);
        
        JCheckListKeyListener keyListener = new JCheckListKeyListener();
        addKeyListener(keyListener);
    }
    
    public JCheckList(final java.lang.Object[] items) {
        super(
        new javax.swing.AbstractListModel() {
            private JCheckListItem[] getItems() {
                JCheckListItem[] checkItems = new JCheckListItem[items.length];
                for (int i = 0; i < items.length; ++i) {
                    checkItems[i] = new JCheckListItem(items[i].toString(), true);
                }
                return checkItems;
            }
            private final JCheckListItem[] listItems = getItems();
            public int getSize() { return items.length; }
            public Object getElementAt(int i) {
                if (i < 0 || i >= items.length) throw new ArrayIndexOutOfBoundsException(i);
                return listItems[i];
            }
        }
        );
        
        JCheckListCellRenderer cellRenderer = new JCheckListCellRenderer();
        setCellRenderer(cellRenderer);
        
        JCheckListMouseListener mouseListener = new JCheckListMouseListener();
        addMouseListener(mouseListener);
        
        JCheckListKeyListener keyListener = new JCheckListKeyListener();
        addKeyListener(keyListener);
    }
    
    public boolean isSelected(int index) {
        return ((JCheckListItem)getModel().getElementAt(index)).isSelected();
    }
    
    public void setSelected(int index, boolean b) {
        ((JCheckListItem)getModel().getElementAt(index)).setSelected(b);
        java.awt.Rectangle rect = getCellBounds(index, index);
        repaint(rect.x, rect.y, rect.width, rect.height);
    }
    
    public void setSelected(boolean[] b) {
        for (int i = 0; i < b.length; ++i) {
            setSelected(i, b[i]);
        }
    }
    
    public boolean[] getSelected() {
        boolean[] bools = new boolean[getModel().getSize()];
        for (int i = 0; i < bools.length; ++i) {
            bools[i] = isSelected(i);
        }
        return bools;
    }
    
    public void setListData(final java.lang.Object[] items) {
        setModel(
        new javax.swing.AbstractListModel() {
            private JCheckListItem[] getItems() {
                JCheckListItem[] checkItems = new JCheckListItem[items.length];
                for (int i = 0; i < items.length; ++i) {
                    checkItems[i] = new JCheckListItem(items[i].toString(), true);
                }
                return checkItems;
            }
            private final JCheckListItem[] listItems = getItems();
            public int getSize() { return items.length; }
            public Object getElementAt(int i) {
                if (i < 0 || i >= items.length) throw new ArrayIndexOutOfBoundsException(i);
                return listItems[i];
            }
        }
        );
    }
    
    private static final class JCheckListItem extends java.lang.Object {
        private boolean m_selected;
        private String m_text;
        public JCheckListItem(String text, boolean selected) {
            m_text = text.trim();
            m_selected = selected;
        }
        public void setSelected(boolean b) {
            m_selected = b;
        }
        public String getText() {
            return m_text;
        }
        public void setText(String text) {
            m_text = text;
        }
        public boolean isSelected() {
            return m_selected;
        }
    }
    
    private final class JCheckListMouseListener extends java.awt.event.MouseAdapter {

        private java.awt.Rectangle iconRect;
       
        public void mousePressed(java.awt.event.MouseEvent e) {
            
            if (!javax.swing.SwingUtilities.isLeftMouseButton(e)) return;
            
            int index = JCheckList.this.locationToIndex(e.getPoint());
            if (index < 0) return;
            
            JCheckListItem item = (JCheckListItem)JCheckList.this.getModel().getElementAt(index);
            
            java.awt.Rectangle rect = JCheckList.this.getCellBounds(index, index);
            if (getIconBounds().contains(e.getX() - rect.x, e.getY() - rect.y)) {
                item.setSelected(!item.isSelected());
                e.consume(); // this doesn't seem to do anything
                JCheckList.this.repaint(rect);
            }
        }
        
        protected java.awt.Rectangle getIconBounds() {
            if (iconRect == null) {
                JCheckListItem item = new JCheckListItem("Text", true);
                JCheckListCellRenderer c = (JCheckListCellRenderer)JCheckList.this.getCellRenderer().getListCellRendererComponent(JCheckList.this, item, 0, true, true);
                
                iconRect = new java.awt.Rectangle();
                java.awt.Rectangle viewRect = new java.awt.Rectangle();
                java.awt.Rectangle textRect = new java.awt.Rectangle();
                
                javax.swing.Icon icon = javax.swing.UIManager.getIcon("CheckBox.icon");               
                
                javax.swing.AbstractButton b = (javax.swing.AbstractButton) c;
                javax.swing.ButtonModel model = b.getModel();           
                java.awt.Insets i = c.getInsets();                
                java.awt.Dimension size = b.getPreferredSize();                
                
                viewRect.x = i.left;
                viewRect.y = i.top;
                viewRect.width = size.width - (i.right + viewRect.x);
                viewRect.height = size.height - (i.bottom + viewRect.y);
                iconRect.x = iconRect.y = iconRect.width = iconRect.height = 0;
                textRect.x = textRect.y = textRect.width = textRect.height = 0;
                
                String text = javax.swing.SwingUtilities.layoutCompoundLabel(
                c,                
                null,
                null,
                icon,
                b.getVerticalAlignment(),
                b.getHorizontalAlignment(),
                b.getVerticalTextPosition(),
                b.getHorizontalTextPosition(),
                viewRect,
                iconRect,
                textRect,
                0);
                
                if (Boolean.getBoolean("phast.debug")) {
                    System.out.println("JCheckListMouseListener.getIconBounds() = " + iconRect);
                }
            }
            return iconRect;
        }        
    }
    
    private final class JCheckListKeyListener extends java.awt.event.KeyAdapter {
        
        public void keyPressed(java.awt.event.KeyEvent e) {
            
            if (e.getKeyCode() == java.awt.event.KeyEvent.VK_SPACE) {
                int[] sel = JCheckList.this.getSelectedIndices();             
                for (int i = 0; i < sel.length; ++i) {
                    JCheckListItem item = (JCheckListItem)JCheckList.this.getModel().getElementAt(sel[i]);
                    item.setSelected(!item.isSelected());
                    java.awt.Rectangle rect = JCheckList.this.getCellBounds(sel[i], sel[i]);
                    JCheckList.this.repaint(rect);
                }
            }
        }
        
    }
    
    private final class JCheckListCellRenderer extends javax.swing.JCheckBox implements javax.swing.ListCellRenderer {
        
        public JCheckListCellRenderer() {
            super();
            setFont(new java.awt.Font("Dialog", 0, 11));
            try {
                // setBorderPaintedFlat(true);  -- can't see checks in com.sun.java.swing.plaf.motif.MotifLookAndFeel
            }
            catch (java.lang.Throwable e) {
            }            
        }
        
        public java.awt.Component getListCellRendererComponent(javax.swing.JList jList, Object obj, int param, boolean isSelected, boolean cellHasFocus) {
            if (isSelected) {
                setBackground(jList.getSelectionBackground());
                setForeground(jList.getSelectionForeground());
            } else {
                setBackground(jList.getBackground());
                setForeground(jList.getForeground());
            }
            
            try {
                JCheckListItem item = (JCheckListItem)obj;
                this.setSelected(item.isSelected());
                this.setText(item.getText());
            } catch (java.lang.ClassCastException e) {
                // this is necessary for setPrototypeCellValue
                this.setText(obj.toString());
            }          
            return this;
        }        
    }    
}

