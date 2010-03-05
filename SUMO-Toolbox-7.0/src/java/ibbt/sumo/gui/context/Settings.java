/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.context;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.swing.JFrame;
import javax.swing.JOptionPane;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.io.OutputFormat;
import org.dom4j.io.SAXReader;
import org.dom4j.io.XMLWriter;

/**
 *
 * @author Sasa Berberovic
 */
public class Settings {
    private Document settings;

    /**
     *
     */
    public Settings(){

    }

    /**
     *
     * @param settings
     */
    public Settings(Document settings){
        this.settings = settings;
    }

    /**
     *
     * @return
     */
    public void load(){
        File file = new File("settings.xml");

        if (file.exists()){
            try {
                SAXReader reader = new SAXReader();
                this.settings = reader.read(file);
            } catch (DocumentException e2) {
                JOptionPane.showMessageDialog(new JFrame(), "Could not find a settings.xml!!!", "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        else {
            System.out.println("Settings file niet gevonden!!!");
            try {
                this.settings  = DocumentHelper.parseText("<Settings><DefaultXML use=\"false\"></DefaultXML></Settings>");
                OutputFormat format = OutputFormat.createPrettyPrint();
                XMLWriter writer = new XMLWriter(new FileWriter(file), format);
                writer.write(this.settings);
                writer.close();
            } catch (IOException ex) {
                Logger.getLogger(Settings.class.getName()).log(Level.SEVERE, null, ex);
            } catch (DocumentException ex) {
                Logger.getLogger(Settings.class.getName()).log(Level.SEVERE, null, ex);
            }

        }
    }

    /**
     * 
     * @return
     */
    public String getDefaultXMLPath(){
        Element e = this.settings.getRootElement().element("DefaultXML");
        return e.getText();
    }

    /**
     *
     * @param path
     */
    public void setDefaultXML(String path){
       this.settings.getRootElement().element("DefaultXML").setText(path);

    }

    /**
     *
     * @return
     */
    public boolean useDefaultXMLPath(){
        Element e = this.settings.getRootElement().element("DefaultXML");
        if (e.attributeValue("use").equals("false"))
            return false;
        else
            return true;
    }

    /**
     *
     * @param b
     */
    public void setUseDefaultXMLPath(boolean b){
        this.settings.getRootElement().element("DefaultXML").addAttribute("use", String.valueOf(b));

    }

    /**
     *
     */
    public void wrtieChanges(){
        FileWriter file = null;
        try {
            file = new FileWriter("settings.xml");
            OutputFormat format = OutputFormat.createPrettyPrint();
            XMLWriter writer = new XMLWriter(file, format);
            writer.write(this.settings);
            writer.close();
        } catch (IOException ex) {
            Logger.getLogger(Settings.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                file.close();
            } catch (IOException ex) {
                Logger.getLogger(Settings.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

    }

}
