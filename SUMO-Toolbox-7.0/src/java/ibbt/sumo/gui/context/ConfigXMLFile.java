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

import ibbt.sumo.gui.util.InputParameterInfo;
import ibbt.sumo.gui.util.OutputParameterInfo;

import java.io.File;
import java.util.Vector;

import javax.swing.DefaultComboBoxModel;
import javax.swing.JFileChooser;
import javax.swing.JFrame;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

/**
 * This class loads an existing configuration file for edit. This also loads DefaultXMLFile
 * beacause it is nessery for editting.
 * It is used to read config elements necessery
 * for initialization of create plan and add run dialogs. And all the other options
 * are read from this file.
 *
 * @author Sasa Berberovic
 */
public class ConfigXMLFile extends DefaultXMLFile{
    private Document configXML;
    private String configFilename;
    private String configPrefix;
    private SimulatorXMLFile simXML;

    /**
     * 
     * @param dxml
     */
    public ConfigXMLFile(){
        super();
        this.simXML = new SimulatorXMLFile("");
    }

    /**
     * 
     * @return
     */
    public String getPrefix(){
        return this.configPrefix;
    }

    /**
     * 
     * @return
     */
    public boolean load(){
        if (!super.load())
            return false;

        JFileChooser fc = new JFileChooser();
        int returnVal = fc.showOpenDialog(new JFrame());
        
        if (returnVal == JFileChooser.APPROVE_OPTION){
            File configfile = fc.getSelectedFile();
            this.configFilename = configfile.getName();
            this.configPrefix = this.configFilename.replace(".xml", "") + "_";
            
            SAXReader reader = new SAXReader();

            try {
                this.configXML = reader.read(configfile);
            } catch (DocumentException e2) {
                return false;
            }
        }
        else{
            return false;
        }
        
        return this.simXML.load(this.getSimulatorPath());
    }

    /**
     *
     * @return
     */
    public boolean load(String path){
        if (!super.load(path))
            return false;

        JFileChooser fc = new JFileChooser();
        int returnVal = fc.showOpenDialog(new JFrame());

        if (returnVal == JFileChooser.APPROVE_OPTION){
            File configfile = fc.getSelectedFile();
            this.configFilename = configfile.getName();
            this.configPrefix = this.configFilename.replace(".xml", "") + "_";

            SAXReader reader = new SAXReader();

            try {
                this.configXML = reader.read(configfile);
            } catch (DocumentException e2) {
                return false;
            }
        }
        else{
            return false;
        }

        return this.simXML.load(this.getSimulatorPath());
    }

    /**
     *
     * @param name
     * @return
     */
    public DefaultComboBoxModel getComboBoxModel(String name){
        DefaultComboBoxModel model = super.getComboBoxModel(name);

        Element root = this.configXML.getRootElement();  
        for (int i = 0; i < root.elements(name).size(); i++){
            Element e = (Element) root.elements(name).get(i);
            String tmp = e.attributeValue("id");
            model.addElement(tmp);
            model.setSelectedItem(tmp);
        }
        
        return model;
    }

    /**
     * 
     * @return
     */
    public String getSimulatorPath(){
        Element root = this.configXML.getRootElement();
        Element plan = root.element("Plan");
        Element sim = plan.element("Simulator");
        return sim.getText();
    }

    /**
     * 
     * @param paramName
     * @return
     */
    public InputParameterInfo getInputParameterInfo(String paramName){
        Element root = this.configXML.getRootElement();
        Element plan = root.element("Plan");
        Element inputs = plan.element("Inputs");
        for (int i = 0; i < inputs.elements().size(); i++){
            Element in = (Element) inputs.elements().get(i);
            if (in.attributeValue("name").equals(paramName))
                return new InputParameterInfo(in.attributeValue("name"),
                        in.attributeValue("type"),
                        in.attributeValue("value"),
                        in.attributeValue("min"),
                        in.attributeValue("max"),
                        in.attributeValue("autosampling"));
        }
        return null;
    }

    /**
     * 
     * @param outputName
     * @return
     */
    public OutputParameterInfo getOutputParameterInfo(String outputName) {
        Element root = this.configXML.getRootElement();
        Element plan = root.element("Plan");
        Element outputs = plan.element("Outputs");
        for (int i = 0; i < outputs.elements().size(); i++){
            Element out = (Element) outputs.elements().get(i);
            if (out.attributeValue("name").equals(outputName))
                return new OutputParameterInfo(out.attributeValue("name"), out.attributeValue("type"));
        }
        return null;
    }
    
    /**
     * 
     * @return
     */
    public SimulatorXMLFile getSimXMLFile() {
        return this.simXML;
    }

    /**
     *
     * @return
     */
    public Element getPlanElement(){
        Element plan = this.configXML.getRootElement().element("Plan");
        return plan;
    }

    /**
     * 
     * @return
     */
    public Vector<Element> getRunElements(){
        Vector<Element> runs = new Vector<Element>();
        Element plan = this.configXML.getRootElement().element("Plan");
        for (int i = 0; i < plan.elements("Run").size(); i++){
            runs.add((Element) plan.elements("Run").get(i));
        }
        return runs;
    }
    
    /**
     * 
     * @return
     */
    public Vector<InputParameterInfo> getInputParameters() {
        Vector<InputParameterInfo> result = new Vector<InputParameterInfo>();

        Element plan = this.configXML.getRootElement().element("Plan");
        Element inputs = plan.element("Inputs");
        if (inputs != null){
            for (int i = 0; i < inputs.elements().size(); i++){
                Element e = (Element) inputs.elements().get(i);
                String name = e.attributeValue("name");
                String type = e.attributeValue("type");
                String value = e.attributeValue("value");
                String min = e.attributeValue("min");
                String max = e.attributeValue("max");
                String autos = e.attributeValue("autoSampling");

                InputParameterInfo in = new InputParameterInfo(name, type, value, min, max, autos);
                result.add(in);
            }
        }
        return result;
    }

    /**
     *
     * @return
     */
    public Vector<OutputParameterInfo> getOutputParameters() {
        Vector<OutputParameterInfo> result = new Vector<OutputParameterInfo>();

        Element plan = this.configXML.getRootElement().element("Plan");
        Element outputs = plan.element("Outputs");
        if (outputs != null){
            for (int i = 0; i < outputs.elements().size(); i++){
                Element e = (Element) outputs.elements().get(i);
                String name = e.attributeValue("name");
                String type = e.attributeValue("complexHandeling");
                String value = e.attributeValue("value");
                String min = e.attributeValue("min");
                String max = e.attributeValue("max");

                OutputParameterInfo out = new OutputParameterInfo(name, type, value, min, max);
                result.add(out);
            }
        }
        return result;
    }

    /**
     * 
     * @param name
     * @param id
     * @return
     */
    public Element getConfigElement(String name, String id) {
        if (this.getElement(name, id) != null){
            return this.getElement(name, id);
        }
        else{
            return super.getConfigElement(name, id);
        }
    }

    /**
     * 
     * @return
     */
    public DefaultComboBoxModel getSampleEvaluators(){
        DefaultComboBoxModel model = this.simXML.sampleEvaluators();

        Element root = this.configXML.getRootElement();
        for (int i = 0; i < root.elements("SampleEvaluator").size(); i++){
            Element e = (Element) root.elements("SampleEvaluator").get(i);
            String tmp = e.attributeValue("id");
            model.addElement(tmp);
            model.setSelectedItem(tmp);
        }
        return model;
    }

    /**
     *
     */
    private Element getElement(String name, String id) {
        for (int i = 0; i < this.configXML.getRootElement().elements().size(); i++){
            Element e = (Element) this.configXML.getRootElement().elements().get(i);
            if (e.getName().equals(name) && e.attributeValue("id").equals(id)){
                return e;
            }
        }
        return null;
    }

    /**
     *
     * @return
     */
    public Vector<MeasureElement> getMeasureElements() {
        Vector<MeasureElement> measures = new Vector<MeasureElement>();
        Element plan = this.configXML.getRootElement().element("Plan");

        for (int i = 0; i < plan.elements("Measure").size(); i++){
            Element e = (Element) plan.elements("Measure").get(i);

            MeasureElement m = new MeasureElement(e);
            measures.add(m);
        }
        return measures;
    }

    /**
     *
     * @param element
     */
    public void addNewConfigElement(Element element) {
        if (!this.hasElement(element)){
            this.configXML.getRootElement().add((Element)element.clone());
        }
        else{
            this.createNewID(element);
            this.configXML.getRootElement().add((Element)element.clone());
        }
    }

    /**
     * 
     * @param id
     * @return
     */
    public Element getSampleEvaluatorElement(String id) {
        if (id.contains(this.configPrefix)){
            return this.getElement("SampleEvaluator", id);
        }
        else{
            return super.getSampleEvaluatorElement(id);
        }
    }

    /**
     *
     */
    public void prePorcessing(){
        Element root = this.configXML.getRootElement();
        Element plan = root.element("Plan");
        for (int i = 0; i < plan.elements().size(); i++){
            Element e = (Element) plan.elements().get(i);
            if (e.getName().equals("LevelPlot")
                    || e.getName().equals("SUMO")
                    || e.getName().equals("ContextConfig")
                    || e.getName().equals("AdaptiveModelBuilder")
                    || e.getName().equals("InitialDesign")
                    || e.getName().equals("SampleSelector")
                    || e.getName().equals("SampleEvaluator")){
                String tmp = this.configPrefix + e.getText();
                e.setText(tmp);
            }
            else if (e.getName().equals("Outputs")){
                for (int j = 0; j < e.elements().size(); j++){
                    Element output = (Element) e.elements().get(j);
                    if (output.getName().equals("LevelPlot")
                            || output.getName().equals("SUMO")
                            || output.getName().equals("ContextConfig")
                            || output.getName().equals("AdaptiveModelBuilder")
                            || output.getName().equals("InitialDesign")
                            || output.getName().equals("SampleSelector")
                            || output.getName().equals("SampleEvaluator")){
                        String tmp = this.configPrefix + output.getText();
                        output.setText(tmp);
                    }
                }
            }
            else if (e.getName().equals("Run")){
                Element run = (Element) e;
                for (int j = 0; j < run.elements().size(); j++){
                    Element tmp = (Element) run.elements().get(j);
                    if (tmp.getName().equals("LevelPlot")
                            || tmp.getName().equals("SUMO")
                            || tmp.getName().equals("ContextConfig")
                            || tmp.getName().equals("AdaptiveModelBuilder")
                            || tmp.getName().equals("InitialDesign")
                            || tmp.getName().equals("SampleSelector")
                            || tmp.getName().equals("SampleEvaluator")){
                        String s = this.configPrefix + tmp.getText();
                        tmp.setText(s);
                    }
                }
            }
        }


        for (int i = 0; i < root.elements().size(); i++){
            Element e = (Element) root.elements().get(i);
            if (e.getName().equals("LevelPlot")
                    || e.getName().equals("SUMO")
                    || e.getName().equals("ContextConfig")
                    || e.getName().equals("AdaptiveModelBuilder")
                    || e.getName().equals("InitialDesign")
                    || e.getName().equals("SampleSelector")
                    || e.getName().equals("SampleEvaluator")){
                String tmp = this.configPrefix + e.attributeValue("id");
                e.addAttribute("id", tmp);
            }
        }
//        System.out.println(root.asXML());
    }

    /**
     *
     */
    public void postPorcessing(){
        Element root = this.configXML.getRootElement();
        Element plan = root.element("Plan");
        for (int i = 0; i < plan.elements().size(); i++){
            Element e = (Element) plan.elements().get(i);
            if (e.getName().equals("LevelPlot")
                    || e.getName().equals("SUMO")
                    || e.getName().equals("ContextConfig")
                    || e.getName().equals("AdaptiveModelBuilder")
                    || e.getName().equals("InitialDesign")
                    || e.getName().equals("SampleSelector")
                    || e.getName().equals("SampleEvaluator")){
                String tmp = e.getText().replace(this.configPrefix, "");
                e.setText(tmp);
            }
            else if (e.getName().equals("Outputs")){
                for (int j = 0; j < e.elements().size(); j++){
                    Element output = (Element) e.elements().get(j);
                    if (output.getName().equals("LevelPlot")
                            || output.getName().equals("SUMO")
                            || output.getName().equals("ContextConfig")
                            || output.getName().equals("AdaptiveModelBuilder")
                            || output.getName().equals("InitialDesign")
                            || output.getName().equals("SampleSelector")
                            || output.getName().equals("SampleEvaluator")){
                        String tmp = output.getText().replace(this.configPrefix, "");
                        output.setText(tmp);
                    }
                }
            }
            else if (e.getName().equals("Run")){
                Element run = (Element) e;
                for (int j = 0; j < run.elements().size(); j++){
                    Element tmp = (Element) run.elements().get(j);
                    if (tmp.getName().equals("LevelPlot")
                            || tmp.getName().equals("SUMO")
                            || tmp.getName().equals("ContextConfig")
                            || tmp.getName().equals("AdaptiveModelBuilder")
                            || tmp.getName().equals("InitialDesign")
                            || tmp.getName().equals("SampleSelector")
                            || tmp.getName().equals("SampleEvaluator")){
                        String s = tmp.getText().replace(this.configPrefix, "");
                        tmp.setText(s);
                    }
                }
            }
        }


        for (int i = 0; i < root.elements().size(); i++){
            Element e = (Element) root.elements().get(i);
            if (e.getName().equals("LevelPlot")
                    || e.getName().equals("SUMO")
                    || e.getName().equals("ContextConfig")
                    || e.getName().equals("AdaptiveModelBuilder")
                    || e.getName().equals("InitialDesign")
                    || e.getName().equals("SampleSelector")
                    || e.getName().equals("SampleEvaluator")){
                String tmp = e.attributeValue("id").replace(this.configPrefix, "");
                e.addAttribute("id", tmp);
            }
        }
    }

    /**
     *
     * @param element
     * @return
     */
    public boolean hasElement(Element element) {
        String id = element.attributeValue("id");
        if (id.contains(this.configPrefix)){
            Element root = this.configXML.getRootElement();
            for (int i = 0; i < root.elements(element.getName()).size(); i++){
                Element tmp = (Element) root.elements(element.getName()).get(i);
                if (tmp.attributeValue("id").equals(element.attributeValue("id")))
                    return true;
            }
            return false;
        }
        else
            return super.hasElement(element);
    }

    /**
     * 
     * @param element
     */
    public void createNewID(Element element) {
        String id = element.attributeValue("id");
        if (id.contains(this.configPrefix)){
            while (this.hasElement(element)){
                String temp = element.attributeValue("id");
                int index = Integer.parseInt(temp.substring(temp.lastIndexOf("_") + 1));
                temp = temp.replace("_" + String.valueOf(index), "_" + String.valueOf(++index));
                element.addAttribute("id", temp);
            }
        }
        else{
            super.createNewID(element);
        }
    }

    /**
     *
     * @return
     */
    public String getFilename() {
        return this.configFilename;
    }

    public static void main(String[] args){
        ConfigXMLFile c = new ConfigXMLFile();
        if (c.load())
            c.prePorcessing();
        c.postPorcessing();
    }

    public void print() {
        System.out.println(this.configXML.asXML());
    }

}
