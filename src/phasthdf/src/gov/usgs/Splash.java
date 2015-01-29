/*
 * Splash.java
 *
 * Created on November 26, 2002, 12:01 PM
 */

package gov.usgs;

import javax.swing.*;
import java.awt.*;

/**
 *
 * @author  charlton
 */
public final class Splash extends javax.swing.JWindow {
    
    /** Creates a new instance of Splash */
    public Splash() {
        ImageIcon icon = null;
        java.net.URL iconURL = ClassLoader.getSystemResource("images/splash.jpeg");
        if (iconURL != null) {
            icon = new ImageIcon(iconURL);
            Image image = icon.getImage();
            Dimension size = new Dimension(image.getWidth(null) + 2, image.getHeight(null) + 2);
            setSize(size);

            Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
            setLocation((screenSize.width - size.width) / 2, (screenSize.height - size.height) / 2);
            JLabel splashLabel = new JLabel(icon);
            splashLabel.setBorder(BorderFactory.createLineBorder(Color.black, 1));

            getContentPane().add(splashLabel, BorderLayout.CENTER);
            pack();
            setVisible(true);        
        }
        else {
            java.lang.System.err.println("Warning:Can't find images/splash.jpeg.");
        }
    }    
}
