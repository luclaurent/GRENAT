package ibbt.sumo.gui.context;
/**----------------------------------------------------------------------------------------
** This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
**
** This program is free software; you can redistribute it and/or modify it under
** the terms of the GNU Affero General Public License version 3 as published by the
** Free Software Foundation.
** 
** This program is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
** PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
** 
** You should have received a copy of the GNU Affero General Public License along
** with this program; if not, see http://www.gnu.org/licenses or write to the Free
** Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301 USA, or download the license from the following URL:
** 
** http://www.sumo.intec.ugent.be
** 
** In accordance with Section 7(b) of the GNU Affero General Public License, these
** Appropriate Legal Notices must retain the display of the "SUMO Toolbox" text and
** homepage.  In addition, when mentioning the program in written work, reference
** must be made to the corresponding publication.
** 
** You can be released from these requirements by purchasing a commercial license.
** Buying such a license is in most cases mandatory as soon as you develop
** commercial activities involving the SUMO Toolbox software. Commercial activities
** include: consultancy services or using the SUMO Toolbox in commercial projects 
** (standalone, on a server, through a webservice or other remote access technology).
** 
** For more information, please contact SUMO lab at
** 
**             sumo@intec.ugent.be - www.sumo.intec.ugent.be
**
** Revision: $Id$
**-----------------------------------------------------------------------------------------
*/

import java.io.File;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.swing.DefaultComboBoxModel;
import javax.swing.JFrame;
import javax.swing.JOptionPane;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

/**
 * This class loads an default xml and is used to read config elements necessery
 * for initialization of create plan and add run dialogs. And all the other options
 * are read from this file.
 *
 * @author Sasa Berberovic
 */
public class DefaultXMLFile {
    private Document defaultXML;
    private String filename = "default.xml";
    private String filepath = "default.xml";
    private JFrame mainFrame;

    /**
     * Create an new DefaultXMLFile object
     *
     */
    public DefaultXMLFile(){

    }

    /**
     * Loads a default.xml from a default path
     *
     */
    public boolean load(){
        try {
            SAXReader reader = new SAXReader();
            this.defaultXML = reader.read(this.getClass().getResourceAsStream("/ibbt/sumo/gui/inputfiles/default.xml"));
            return true;
        } catch (Exception e2) {
            //Logger.getLogger(DefaultXMLFile.class.getName()).log(Level.SEVERE, null, e2);
            JOptionPane.showMessageDialog(new JFrame(), "Unable to find default.xml, please select it", "Error", JOptionPane.ERROR_MESSAGE);
            return false;
        }
    }

    /**
     * Loads a default.xml from a sepcified location
     *
     * @param path  path of the specified default.xml
     * @return true if file excists and is loaded succesfully
     * @return false if file doesn't excist or an error occured while opening it
     */
    public boolean load(String path) {
        this.filepath = path;

        File file = new File(this.filepath);

        if (file.exists()){
            try {
                SAXReader reader = new SAXReader();
                this.defaultXML = reader.read(file);
                return true;
            } catch (DocumentException e2) {
                Logger.getLogger(DefaultXMLFile.class.getName()).log(Level.SEVERE, null, e2);
                JOptionPane.showMessageDialog(new JFrame(), "Could not find a default.xml!!!", "Error", JOptionPane.ERROR_MESSAGE);
                return false;
            }
        }
        else {
            return false;
        }
    }

    /**
     * Returns a combobox model that contains all the config elements with the
     * element name == elementName
     *
     * @param elementName   name op the config element
     * @return DefaultComboBoxModel combobox model containing all config elements with name == elementName
     *
     */
    public DefaultComboBoxModel getComboBoxModel(String elementName){
        DefaultComboBoxModel model = new DefaultComboBoxModel();

        if (elementName.equals("SampleSelector")){
            model.addElement("none");
        }

        for (int i = 0; i < this.defaultXML.getRootElement().elements(elementName).size(); i++){
            Element e = (Element)this.defaultXML.getRootElement().elements(elementName).get(i);
            model.addElement(e.attributeValue("id"));
        }

        return model;
    }

    /**
     * Adds a new config element to the default.xml
     *
     * @param e new element to add
     *
     */
    public void addNewConfigElement(Element e){
        if (!this.hasElement(e)){
            this.defaultXML.getRootElement().add((Element)e.clone());
        }
        else{
            this.createNewID(e);
            this.defaultXML.getRootElement().add((Element)e.clone());
        }
    }

    /**
     * Returns a config element with name == ename and id == eid
     *
     * @param ename config element name
     * @param eid   config element id
     * @return Element  config element with name  ename and id == eid
     *
     */
    public Element getConfigElement(String ename, String eid){
        Element result = null;
        
        for (int i = 0; i < this.defaultXML.getRootElement().elements(ename).size(); i++){
            result = (Element) ((Element)this.defaultXML.getRootElement().elements(ename).get(i)).clone();
            if (result.attributeValue("id").equals(eid)){
                return result;
            }
        }
   
        return null;
    }

    /**
     * Returns a config element with name == ename
     *
     * @param ename config element name
     * @return Element  config element with name == ename
     *
     */
    public Element getConfigElement(String ename){
        Element result = (Element) ((Element)this.defaultXML.getRootElement().element(ename)).clone();
        return result;
    }

    /**
     * Returns a SampleEvaluator element with ID == id
     *
     * @param is        sampleEvaluator element id
     * @return Element  sampleEvaluator element with ID ==  id
     *
     */
    public Element getSampleEvaluatorElement(String id){
        Element sampleEval = null;
        if (id.contains("matlab")){
            sampleEval = (Element) this.getConfigElement("SampleEvaluator", "matlab").clone();
        }
        else if (id.contains("java")){
            sampleEval = (Element) this.getConfigElement("SampleEvaluator", "local").clone();
            for (int j = 0; j< sampleEval.elements("Option").size(); j++){
                if (((Element) sampleEval.elements("Option").get(j)).attributeValue("key").equals("simulatorType")){
                    ((Element) sampleEval.elements("Option").get(j)).addAttribute("value", "java");
                }
            }
        }
        else if (id.contains("unix")){
            sampleEval = (Element) this.getConfigElement("SampleEvaluator", "local").clone();
            for (int j = 0; j< sampleEval.elements("Option").size(); j++){
                if (((Element) sampleEval.elements("Option").get(j)).attributeValue("key").equals("simulatorType")){
                    ((Element) sampleEval.elements("Option").get(j)).addAttribute("value", "external");
                }
            }
        }
        else if (id.contains("windows")){
            sampleEval = (Element) this.getConfigElement("SampleEvaluator", "local").clone();
            for (int j = 0; j< sampleEval.elements("Option").size(); j++){
                if (((Element) sampleEval.elements("Option").get(j)).attributeValue("key").equals("simulatorType")){
                    ((Element) sampleEval.elements("Option").get(j)).addAttribute("value", "external");
                }
            }
        }
        else if (id.contains("scatteredDataset")){
            sampleEval = (Element) this.getConfigElement("SampleEvaluator", "scatteredDataset").clone();
            String dataSetID = id.substring(id.indexOf("(")+1, id.indexOf(")"));
            for (int i = 0; i < sampleEval.elements("Option").size(); i++){
                Element o = (Element) sampleEval.elements("Option").get(i);
                if (o.attributeValue("key").equals("id")){
                    o.addAttribute("value", dataSetID);
                }
            }
        }
        else if (id.contains("griddedDataset")){
            sampleEval = (Element) this.getConfigElement("SampleEvaluator", "griddedDataset").clone();
            String dataSetID = id.substring(id.indexOf("(")+1, id.indexOf(")")-1);
            for (int i = 0; i < sampleEval.elements("Option").size(); i++){
                Element o = (Element) sampleEval.elements("Option").get(i);
                if (o.attributeValue("key").equals("id")){
                    o.addAttribute("value", dataSetID);
                }
            }
        }
        else if (id.contains("calcua")){
            sampleEval = (Element) this.getConfigElement("SampleEvaluator", "calcua").clone();
        }
        else if (id.contains("begrid")){
            sampleEval = (Element) this.getConfigElement("SampleEvaluator", "begrid").clone();
        }
        return sampleEval;
    }

    /**
     *
     * @return
     */
    public Element getRootElement(){
        return (Element) this.defaultXML.getRootElement().clone();
    }

    /**
     * 
     * @return
     */
    public Vector<MeasureElement> getMeasureElements(){
        Vector<MeasureElement> measures = new Vector<MeasureElement>();

        Element plan = this.defaultXML.getRootElement().element("Plan");
        for (int i = 0; i < plan.elements().size(); i++){
            Element e = (Element) plan.elements().get(i);
            if (e.getName().equals("Run")){
                for (int j = 0; j < e.elements().size(); j++){
                    Element tmp = (Element) e.elements().get(j);
                    if (tmp.getName().equals("Measure")){
                        MeasureElement m = new MeasureElement();
                        m.setType(tmp.attributeValue("type"));
                        m.setTarget(tmp.attributeValue("target"));
                        m.setErrFunction(tmp.attributeValue("errorFcn"));
                        if (tmp.attributeValue("use").equals("on"))
                            m.setUse("true");
                        else
                            m.setUse("false");
                        measures.add(m);
                    }
                }
            }
            else if(e.getName().equals("Measure")){
                MeasureElement m = new MeasureElement();
                m.setType(e.attributeValue("type"));
                m.setTarget(e.attributeValue("target"));
                m.setErrFunction(e.attributeValue("errorFcn"));
                if (e.attributeValue("use").equals("on"))
                    m.setUse("true");
                else
                    m.setUse("false");
                measures.add(m);
            }
        }
        return measures;
    }

    /**
     * 
     * @param e
     * @return
     */
    public boolean hasElement(Element e) {
        Element root = this.defaultXML.getRootElement();
        for (int i = 0; i < root.elements(e.getName()).size(); i++){
            Element tmp = (Element) root.elements(e.getName()).get(i);
            if (tmp.attributeValue("id").equals(e.attributeValue("id")))
                return true;
        }
        return false;
    }

    /**
     *
     * @param e
     */
    public void createNewID(Element e) {
        while (this.hasElement(e)){
            String temp = e.attributeValue("id");
            int index = Integer.parseInt(temp.substring(temp.lastIndexOf("_") + 1));
            temp = temp.replace("_" + String.valueOf(index), "_" + String.valueOf(++index));
            e.addAttribute("id", temp);
        }
    }
}
