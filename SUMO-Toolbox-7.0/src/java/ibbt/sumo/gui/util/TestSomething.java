/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.util;

import org.dom4j.Comment;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.Node;
import org.dom4j.io.SAXReader;

/**
 *
 * @author theking
 */
public class TestSomething {
    Document defaultXML;

    public TestSomething() {
        try {
            SAXReader reader = new SAXReader();
            this.defaultXML = reader.read(this.getClass().getResourceAsStream("/ibbt/sumo/gui/inputfiles/default.xml"));
        } catch (DocumentException e2) {

        }
    }

    public Comment getComment(String cname, String cid){
        for ( int i = 0; i < this.defaultXML.getRootElement().nodeCount(); i++ ) {
            Node node1 = this.defaultXML.getRootElement().node(i);
            if (node1 instanceof Element ) {
                Element e = (Element) node1;
                if (e.getName().equals(cname) ){
                    System.out.println("-----------------------------------------------------------------------------------");
                    System.out.println(e.asXML());
                    System.out.println("-----------------------------------------------------------------------------------");
                    if (e.attributeValue("id").equals(cid)){
                        Node node2 = this.defaultXML.getRootElement().node(i-2);
                        System.out.println("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
                        System.out.println(node2.asXML());
                        System.out.println("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
                        if (node2 instanceof Comment){
                            Comment c = (Comment) node2;
                            return (Comment) node2;
                        }
                    }
                }
            }
            
        }
        return null;
    }

    public static void main(String[] args){
        TestSomething t = new TestSomething();

        System.out.println(t.getComment("SUMO", "default").getText());
    }

}
