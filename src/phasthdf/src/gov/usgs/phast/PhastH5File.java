/*
 * PhastH5File.java
 *
 * Created on July 29, 2002, 06:16 PM
 */

package gov.usgs.phast;

/*
 * add jhdf*.jar to <path>/jre/lib/ext/ 
 * Note: setting classpath didn't work inside of Forte
 */
import ncsa.hdf.hdf5lib.*;
import ncsa.hdf.hdf5lib.exceptions.*;
import ncsa.hdf.object.h5.*;
import ncsa.hdf.object.*;
import javax.swing.tree.*;

/**
 *
 * @author  charlton
 */
public class PhastH5File extends ncsa.hdf.object.h5.H5File {
    
    private boolean[]  x_selection;
    private boolean[]  y_selection;
    private boolean[]  z_selection;
    private boolean[]  s_selection;
    private boolean[]  t_selection;
    private boolean[]  v_selection;    
    private PhastGrid  grid;
    
    private static corejava.Format s_format15g = new corejava.Format("%15g");
    private static corejava.Format s_format12_4e = new corejava.Format("%12.4e");    
    
    public PhastH5File(java.lang.String pathname) throws java.lang.Exception {
        super(pathname);      
        open();         // might throw
        grid = new PhastGrid();
    }    
    
    private TreeNode findNode(TreeNode root, String str) {
        int n = root.getChildCount();
        for (int i = 0; i < n; ++i) {
            if (root.getChildAt(i).toString().equals(str)) {
                return root.getChildAt(i);
            }
        }
        return null;
    }
    
    private TreeNode findNode(TreeNode root, String[] path) {
        TreeNode node = root;
        for (int i = 0; (node != null) && (i < path.length); ++i) {
            node = findNode(node, path[i]);	
        }
        return node;
    }
    
    private TreeNode findNode(TreeNode root, TreePath treepath) {
        TreeNode node = root;
        Object[] path = treepath.getPath();
        for (int i = 0; (node != null) && (i < path.length); ++i) {
            node = findNode(node, path[i].toString());	
        }
        return node;
    }
    
    public String[] getFixedStrings(TreePath treepath) {
        TreeNode node = findNode(this.getRootNode(), treepath);
        if (node != null) {
            Object obj = ((DefaultMutableTreeNode)node).getUserObject();
            if (obj instanceof H5ScalarDS) {
                Object data = null;
                try {
                    data = ((H5ScalarDS)obj).read();
                } catch (Exception e) {}
                if ((data != null) && (data.getClass().isArray())) {
                    String[] strings = (String[]) data;
                    return strings;
                }                
            }
        }
        return null;
    }    
    
    public String[] getX() {
        return grid.getX();
    }
    
    public String[] getY() {
        return grid.getY();
    }
    
    public String[] getZ() {
        return grid.getZ();
    }
    
    public String[] getTimeSteps() {
        return getFixedStrings(new TreePath(new String[]{"TimeSteps"}));        
    }
    
    public void setSelectedX(boolean[] bools) {
        x_selection = bools;
    }
    
    public void setSelectedY(boolean[] bools) {
        y_selection = bools;
    }
    
    public void setSelectedZ(boolean[] bools) {
        z_selection = bools;
    }
    
    public void setSelectedTimes(boolean[] bools) {
        t_selection = bools;
    }
    
    public void setSelectedScalars(boolean[] bools) {
        s_selection = bools;
    }

    public void setSelectedVectors(boolean[] bools) {
        v_selection = bools;
    }

    public String[] getScalars() {        
        return getFixedStrings(new TreePath(new String[]{"Scalars"}));
    }
    
    public String[] getVectors() {        
        return getFixedStrings(new TreePath(new String[]{"Vectors"}));
    }
    
    public void writeSelected(java.io.OutputStream out, IProgressMonitor progressMonitor) {
        java.io.PrintStream output = new java.io.PrintStream(out);
        
        // print header
        corejava.Format f = new corejava.Format("%15s");        
        output.print(f.form("x"));
        output.print("\t");
        output.print(f.form("y"));
        output.print("\t");
        output.print(f.form("z"));
        output.print("\t");
        output.print(f.form("time"));
        output.print("\t");
        corejava.Format.print(output, "%2s", "in");
        output.print("\t");
        String[] scalars = getScalars();
        if (scalars != null) {
            for (int s = 0; s < scalars.length; ++s) {
                if ((s_selection == null) || s_selection[s]) {
                    corejava.Format.print(output, "%12s\t", scalars[s]);
                }
            }
        }        
        String[] vectors = getVectors();
        if (vectors != null) {
            corejava.Format.print(output, "%3s", "Vin");
            output.print("\t");            
            String[] suffix = new String[] { "_vx", "_vy", "_vz" };
            for (int v = 0; v < vectors.length; ++v) {
                if ((v_selection == null) || v_selection[v]) {
                    for (int i = 0; i < suffix.length; ++i) {
                        corejava.Format.print(output, "%12s\t", vectors[v] + suffix[i]);
                    }
                }
            }
        }        
        output.println();
        
        String[]         x = getX();
        String[]         y = getY();
        String[]         z = getZ();
        String[] timesteps = getTimeSteps();
        if (progressMonitor != null) {
            // show progress
            progressMonitor.setMinimum(0);
            progressMonitor.setMaximum(timesteps.length);
        }            

        // remove timestep units
        String[] time = new String[timesteps.length];
        for (int t = 0; t < time.length; ++t) {
            time[t] = f.form(timesteps[t].substring(0, timesteps[t].indexOf(' ')));
        }
        
        // do each timestep
        for (int t = 0; t < timesteps.length; ++t) {
            if (progressMonitor != null) {
                if (progressMonitor.isCanceled()) break;
                progressMonitor.setProgress(t);
            }                
            if (!((t_selection == null) || t_selection[t])) continue;
            
            Transform trans = new Transform(timesteps[t]);
            for (int k = 0; k < z.length; ++k) {
                if (!((z_selection == null) || z_selection[k])) continue;
                
                for (int j = 0; j < y.length; ++j) {
                    if (!((y_selection == null) || y_selection[j])) continue;
                    
                    for (int i = 0; i < x.length; ++i) {
                        if (!(x_selection == null || x_selection[i])) continue;
                        
                        output.print(x[i] + "\t" + y[j] + "\t" + z[k] + "\t" + time[t] + "\t");
                        if (trans.isActive(i, j, k) || trans.isVectorActive(i, j, k)) {
                            // print inactive flag
                            corejava.Format.print(output, "%2d\t", 1);
                            if (trans.isActive(i, j, k)) {
                                for (int s = 0; s < scalars.length; ++s) {
                                    if (!((s_selection == null) || s_selection[s])) continue;
                                    
                                    if (trans.isScalarOn(s)) {
                                        // print scalar
                                        output.print(s_format12_4e.form(trans.getAt(i, j, k, s)) + "\t");
                                    }
                                    else {
                                        // skip scalar
                                        output.print("            \t");
                                    }
                                }
                            }
                            if (trans.isVectorActive(i, j, k)) {
                                // print vector inactive flag
                                corejava.Format.print(output, "%3d", 1);
                                output.print("\t");                                
                                for (int v = 0; v < vectors.length; ++v) {
                                    if (!((v_selection == null) || v_selection[v])) continue;
                                    
                                    // print vector
                                    output.print(s_format12_4e.form(trans.getVxAt(i, j, k)) + "\t");
                                    output.print(s_format12_4e.form(trans.getVyAt(i, j, k)) + "\t");
                                    output.print(s_format12_4e.form(trans.getVzAt(i, j, k)) + "\t");
                                }
                            }
                            else {
                                // print vector inactive flag
                                corejava.Format.print(output, "%3d", 0);
                            }
                        }
                        else {
                            // print inactive flag
                            corejava.Format.print(output, "%2d\t", 0);
                        }
                        output.println();
                    }
                }
            }
        }            
    }
    
    public void writeSelected(java.io.OutputStream out) {
        writeSelected(out, null);
    }
    
    private boolean isActive(int i, int j, int k) {
        return grid.isActive(i, j, k);
    }
    
    public int[] getActiveScalars(String timestep) {
        TreeNode node = findNode(getRootNode(), new TreePath(new String[]{timestep, "Scalars"}));
        if (node != null) {
            Object obj = ((DefaultMutableTreeNode)node).getUserObject();
            if (obj instanceof H5ScalarDS) {
                Object data = null;
                try {
                    data = ((H5ScalarDS)obj).read();
                } catch (Exception e) {}
                if (data != null && data.getClass().isArray()) {
                    int[] ints = (int[]) data;
                    return ints;
                }                
            }
        }
        return null;       
    }
    
    public float[] getActiveArray(String timestep) {
        TreeNode node = findNode(getRootNode(), new TreePath(new String[]{timestep, "ActiveArray"}));
        if (node != null) {
            Object obj = ((DefaultMutableTreeNode)node).getUserObject();
            if (obj instanceof H5ScalarDS) {
                Object data = null;
                try {
                    data = ((H5ScalarDS)obj).read();
                } catch (Exception e) {}
                if (data != null && data.getClass().isArray()) {
                    float[] floats = (float[]) data;
                    return floats;
                }                
            }
        }
        return null;       
    }
    
    public int[] getVMask(String timestep) {
        TreeNode node = findNode(getRootNode(), new TreePath(new String[]{timestep, "Vmask"}));
        if (node != null) {
            Object obj = ((DefaultMutableTreeNode)node).getUserObject();
            if (obj instanceof H5ScalarDS) {
                Object data = null;
                try {
                    data = ((H5ScalarDS)obj).read();
                } catch (Exception e) {}
                if (data != null && data.getClass().isArray()) {
                    int[] ints = (int[]) data;
                    return ints;
                }                
            }
        }
        return null;       
    }

    private float[] getVel(String timestep, String axis) {
        TreeNode node = findNode(getRootNode(), new TreePath(new String[]{timestep, axis}));
        if (node != null) {
            Object obj = ((DefaultMutableTreeNode)node).getUserObject();
            if (obj instanceof H5ScalarDS) {
                Object data = null;
                try {
                    data = ((H5ScalarDS)obj).read();
                } catch (Exception e) {}
                if (data != null && data.getClass().isArray()) {
                    float[] floats = (float[]) data;
                    return floats;
                }                
            }
        }
        return null;       
    }
    
    public float[] getVelocityX(String timestep) {
        return getVel(timestep, "Vx_node");
    }
    
    public float[] getVelocityY(String timestep) {
        return getVel(timestep, "Vy_node");
    }
    
    public float[] getVelocityZ(String timestep) {
        return getVel(timestep, "Vz_node");
    }

    public String[] getAxisObj(TreePath treepath) {
        TreeNode node = findNode(getRootNode(), treepath);
        if (node != null) {
            Object obj = ((DefaultMutableTreeNode)node).getUserObject();
            if (obj instanceof H5ScalarDS) {
                Object data = null;
                try {
                    data = ((H5ScalarDS)obj).read();
                } catch (Exception e) {}
                if (data != null && data.getClass().isArray()) {
                    float[] floats = (float[]) data;
                    String[] strings = new String[floats.length];
                    for (int i = 0; i < strings.length; ++i) {
                        strings[i] = s_format15g.form(floats[i]);
                    } 
                    return strings;
                }                
            }
        }
        return null;
    }    
    
    public static boolean isThisTypeStatic(final java.lang.String fileName) {
        boolean isValid = false;
        try {
            ncsa.hdf.object.h5.H5File file = new ncsa.hdf.object.h5.H5File();            
            if (!file.isThisType(fileName)) return isValid;
            
            PhastH5File hdf = new PhastH5File(fileName);
            
            String[] strings = null;
            strings = hdf.getX();
            if (strings == null) throw new gov.usgs.phast.JMalformedHDFException("Didn't find X");
            strings = hdf.getY();
            if (strings == null) throw new gov.usgs.phast.JMalformedHDFException("Didn't find Y");
            strings = hdf.getZ();
            if (strings == null) throw new gov.usgs.phast.JMalformedHDFException("Didn't find Z");
            strings = hdf.getTimeSteps();
            if (strings == null) throw new gov.usgs.phast.JMalformedHDFException("Didn't find Timesteps");            
            hdf.close();
            isValid = true;
        } catch (ncsa.hdf.hdf5lib.exceptions.HDF5Exception e) {
            System.out.println(e);
        } catch (gov.usgs.phast.JMalformedHDFException e) {
            System.out.println(e);
        } catch (java.lang.Exception e) {
            System.out.println(e);
        }
        return isValid;
    }
    
    public class PhastGrid {        
        private String[]  xStrings;        
        private String[]  yStrings;        
        private String[]  zStrings;        
        private int       nx;        
        private int       nxy;        
        private int       nxyz;        
        private int[]     naturalToActive;      
        private int       activeCount;
        
        public PhastGrid() {
            xStrings = getAxisObj(new TreePath(new String[]{"Grid", "X"}));
            yStrings = getAxisObj(new TreePath(new String[]{"Grid", "Y"}));
            zStrings = getAxisObj(new TreePath(new String[]{"Grid", "Z"}));
            
            nx   = xStrings.length;
            nxy  = nx * yStrings.length;
            nxyz = nxy * zStrings.length;
            
            naturalToActive = new int[nxyz];
            int[] active = getActive();
            if (active == null) {
                // all are active
                activeCount = nxyz;
                for (int i = 0; i < nxyz; ++i) {
                    naturalToActive[i] = i;
                }
            }
            else {
                // some are inactive
                activeCount = active.length;
                java.util.Arrays.fill(naturalToActive, -1);
                for (int i = 0; i < active.length; ++i) {
                    naturalToActive[active[i]] = i;
                }                    
            }            
        }
        
        public int getActiveCount() {
            return activeCount;
        }
        
        private int[] getActive() {
            TreeNode node = findNode(getRootNode(), new TreePath(new String[]{"Grid", "Active"}));
            if (node != null) {
                Object obj = ((DefaultMutableTreeNode)node).getUserObject();
                if (obj instanceof H5ScalarDS) {
                    Object data = null;
                    try {
                        data = ((H5ScalarDS)obj).read();
                    } catch (Exception e) {}
                    if (data != null && data.getClass().isArray()) {
                        int[] ints = (int[]) data;
                        return ints;
                    }                
                }
            }
            return null;            
        }
        
        public boolean isActive(int i, int j, int k) {
            return (naturalToActive[getNatural(i, j, k)] >= 0);
        }
        
        public int getActiveIndex(int i, int j, int k) {
            return naturalToActive[getNatural(i, j, k)];
        }
        
        public String[] getX() {
            return xStrings;
        }
        
        public String[] getY() {
            return yStrings;
        }
        
        public String[] getZ() {
            return zStrings;
        }      
        
        public int getNx() {
            return xStrings.length;
        }
        
        public int getNy() {
            return yStrings.length;
        }
        
        public int getNz() {
            return zStrings.length;
        }
        
        public int getNatural(int i, int j, int k) {
            return (k * nxy + j * nx + i);
        }
        
    }
    
    public class Transform {        
        private float[]  active_array;        
        private int[]    active_scalars;        
        private float[]  vx;
        private float[]  vy;
        private float[]  vz;
        private int[]    v_mask;
        
        public Transform(java.lang.String timestep) {
            active_array   = getActiveArray(timestep);
            active_scalars = getActiveScalars(timestep);
            v_mask         = getVMask(timestep);
            if (v_mask != null) {
                vx = getVelocityX(timestep);
                vy = getVelocityY(timestep);
                vz = getVelocityZ(timestep);
            }
        }
        
        public float getAt(int i, int j, int k, int s) {
            int n = java.util.Arrays.binarySearch(active_scalars, s);
            return active_array[grid.getActiveIndex(i, j, k) + n * grid.getActiveCount()];
        }
        
        public float getVxAt(int i, int j, int k) {
            return (vx[grid.getNatural(i, j, k)]);            
        }
        
        public float getVyAt(int i, int j, int k) {
            return (vy[grid.getNatural(i, j, k)]);            
        }
        
        public float getVzAt(int i, int j, int k) {
            return (vz[grid.getNatural(i, j, k)]);
        }
        
        public boolean isScalarOn(int n) {
            return (java.util.Arrays.binarySearch(active_scalars, n) >= 0 );
        }
        
        private boolean isDry(int i, int j, int k) {
            return (active_array[grid.getActiveIndex(i, j, k)] >= 1e+030); 
        }
        
        public boolean isActive(int i, int j, int k) {
            if (active_array == null) return false;
            return (grid.isActive(i, j, k) && !isDry(i, j, k));            
        }
        
        public boolean isVectorActive(int i, int j, int k) {        
            if (v_mask == null) return false;
            return (v_mask[grid.getNatural(i, j, k)] > 0);
        }       
    }
}
