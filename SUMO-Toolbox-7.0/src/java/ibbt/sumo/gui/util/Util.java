/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;

import org.dom4j.Comment;
import org.dom4j.Element;
import org.dom4j.Node;

/**
 *
 * @author theking
 */
public class Util {


    public static boolean isDouble(String value){
        try{
            double d = Double.parseDouble(value);
        }
        catch(java.lang.NumberFormatException e){
            return false;
        }
        return true;
    }

     public static boolean isInteger(String value){
        try{
            double i = Integer.parseInt(value);
        }
        catch(java.lang.NumberFormatException e){
            return false;
        }
        return true;
    }

     public static boolean isFloat(String value){
        try{
            double f = Float.parseFloat(value);
        }
        catch(java.lang.NumberFormatException e){
            return false;
        }
        return true;
    }

    public static boolean outOfRange(double value, double min, double max){
        if (value < min || value > max)
            return false;
        else
            return true;
    }

    public static String systemPlatform(){
        return System.getProperty("os.name");
    }

    public static String systemArchitecture(){
        return System.getProperty("os.arch");
    }

    public boolean loadDefaultXMLFileFromJar() throws IOException{
        BufferedReader reader = new BufferedReader(new InputStreamReader(this.getClass().getResourceAsStream("/ibbt/sumo/gui/inputfiles/default.xml")));

        File f = new File("default.xml");
        BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(f));


        String line = null;
        while ((line = reader.readLine()) != null) {
            bufferedWriter.write(line);
            bufferedWriter.newLine();
        }

        bufferedWriter.flush();
        bufferedWriter.close();
        reader.close();

        
        if (f.exists())
            return true;
        else
            return false;
    }

    public static String getCommentOf(String elementName, String elementID, Element root){
        for ( int i = 0; i < root.nodeCount(); i++ ) {
            Node node1 = root.node(i);
            if (node1 instanceof Element ) {
                Element e = (Element) node1;
                if (e.getName().equals(elementName) ){
                    if (e.attributeValue("id").equals(elementID)){
                        Node node2 = root.node(i-2);
                        if (node2 instanceof Comment){
                            Comment c = (Comment) node2;
                            return c.getText();
                        }
                    }
                }
            }
        }
        return null;
    }

    public static String getCommentOf(Element e, Element root){
        for ( int i = 0; i < root.nodeCount(); i++ ) {
            Node node1 = root.node(i);
            if (node1 instanceof Element ) {
                Element tmp = (Element) node1;
                if (tmp.asXML().equals(e.asXML())){
                    Node node2 = root.node(i-2);
                    if (node2 instanceof Comment){
                        Comment c = (Comment) node2;
                        return c.getText();
                    }
                }
            }
        }
        return null;
    }

    public static String getOptionsComment(String key, Element root){
        for ( int i = 0; i < root.nodeCount(); i++ ) {
            Node node1 = root.node(i);
            if (node1 instanceof Element ) {
                Element e = (Element) node1;
                if (e.getName().equals("Option") ){
                    if (e.attributeValue("key").equals(key)){
                        Node node2 = root.node(i-2);
                        if (node2 instanceof Comment){
                            Comment c = (Comment) node2;
                            return c.getText();
                        }
                    }
                }
                else
                    return null;
            }
        }
        return null;
    }
}
