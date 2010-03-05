/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.util;

import java.io.File;

import javax.swing.filechooser.FileFilter;

/**
 *
 * @author theking
 */
public class XMLFileFilter extends FileFilter{
    public XMLFileFilter(){

    }

    public boolean accept(File pathname) {
        return (pathname.isDirectory() || pathname.getAbsolutePath().endsWith(".xml"));
    }

   
    public String getDescription() {
        return ".xml";
    }

}
