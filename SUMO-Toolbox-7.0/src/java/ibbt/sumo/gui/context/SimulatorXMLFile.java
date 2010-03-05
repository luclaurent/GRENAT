/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.context;

import ibbt.sumo.gui.util.InputParameterInfo;
import ibbt.sumo.gui.util.OutputParameterInfo;
import ibbt.sumo.gui.util.ParameterInfo;
import ibbt.sumo.gui.util.XMLFileFilter;
import ibbt.sumo.util.SystemArchitecture;
import ibbt.sumo.util.SystemPlatform;
import ibbt.sumo.util.Util;

import java.io.File;
import java.util.Vector;

import javax.swing.DefaultComboBoxModel;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JOptionPane;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

/**
 * This class loads a simulator xml and is used to read parameters necessery
 * for initialization of selectparameter dialog.
 *
 * @author Sasa Berberovic
 */
public class SimulatorXMLFile {
    private Document simulator;
    private String filename;
    private String filepath;
    private boolean success = false;
    private String name;

    /**
     * Create an new SimulatorXMLFile object
     *
     */
    public SimulatorXMLFile(String filepath){
        this.filepath = filepath;
    }

    /**
     * Loads a simulator.xml file
     *
     */
    public boolean load(){
        JFileChooser jfc = new JFileChooser(this.filepath);
        jfc.setFileFilter(new XMLFileFilter());

        JFrame f = new JFrame();
        f.setTitle("Open a simulator file");

        if (jfc.showOpenDialog(f) == JFileChooser.APPROVE_OPTION)
        {
            this.filename = jfc.getSelectedFile().getName();
            this.filepath = jfc.getSelectedFile().getAbsolutePath();

            File simfile = new File(this.filepath);
            SAXReader reader = new SAXReader();

            try {
                this.simulator = reader.read(simfile);
            } catch (DocumentException e2) {
                JOptionPane.showMessageDialog(new JFrame(), "An error occured while trying to open file" + this.filepath, "Error", JOptionPane.ERROR_MESSAGE);
                this.success = false;
                return false;
            }

            if (this.simulator != null && this.simulator.getRootElement().getName().equalsIgnoreCase("Simulator")){
                this.name = this.simulator.getRootElement().elementText("Name");
                this.success = true;
                return true;
            }
            else{
                JOptionPane.showMessageDialog(new JFrame(), "The file you selected is not a simulator file", "Error", JOptionPane.ERROR_MESSAGE);
                this.success = false;
                return false;
            }
        }
        return false;
    }

    /**
     * 
     * @param simulatorPath
     * @return
     */
    public boolean load(String simulatorPath) {
        File simfile = new File(simulatorPath);

        if (simfile.exists())
        {
            this.filename = simfile.getName();
            this.filepath = simfile.getAbsolutePath();

            SAXReader reader = new SAXReader();

            try {
                this.simulator = reader.read(simfile);
            } catch (DocumentException e2) {
                JOptionPane.showMessageDialog(new JFrame(), "An error occured while trying to open file" + this.filepath, "Error", JOptionPane.ERROR_MESSAGE);
                this.success = false;
                return false;
            }

            if (this.simulator != null && this.simulator.getRootElement().getName().equalsIgnoreCase("Simulator")){
                this.name = this.simulator.getRootElement().elementText("Name");
                this.success = true;
                return true;
            }
            else{
                JOptionPane.showMessageDialog(new JFrame(), "The file you selected is not a simulator file", "Error", JOptionPane.ERROR_MESSAGE);
                this.success = false;
                return false;
            }
        }
        return false;
    }

    /**
     * Returns the filename of the simulator.xml
     *
     * @return String   filename of the simulator
     *
     */
    public String filename(){
        return this.filename;
    }

    /**
     * Returns the path of the simulator.xml
     *
     * @return String   path of the simulator
     *
     */
    public String filepath(){
        return this.filepath;
    }

    /**
     * Returns the name of the simulator.xml
     *
     * @return String   name of the simulator
     *
     */
    public String name(){
        return this.name;
    }

    /**
     * Checks if the load happend successfully
     *
     * @return true   simulator is successfully loaded
     * @return false  simulator is not successfully loaded
     *
     */
    public boolean loadSuccessfully(){
        return this.success;
    }

    /**
     * Returns the description of the simulator
     *
     * @return String   simulator description
     *
     */
    public String simulatorDescription(){
        String temp = this.simulator.getRootElement().element("Description").getText();
        temp = temp.replaceAll("\t", "");
        return temp;
    }

    /**
     * Returns the list of input parameters
     *
     * @return Vector<ParameterInfo>   list of input parameters
     *
     */
    public Vector<ParameterInfo> inputParameters(){
        Vector<ParameterInfo> list = new Vector<ParameterInfo>();
        Element inputP = (Element)this.simulator.getRootElement().element("InputParameters");
        for (int i = 0; i < inputP.elements("Parameter").size(); i++){
            String name = ((Element)inputP.elements("Parameter").get(i)).attributeValue("name");
            String type = ((Element)inputP.elements("Parameter").get(i)).attributeValue("type");
            String value = "n/a";
            if (((Element)inputP.elements("Parameter").get(i)).attribute("value") != null)
                    value = ((Element)inputP.elements("Parameter").get(i)).attributeValue("value");
            String min = "-1";
            if (((Element)inputP.elements("Parameter").get(i)).attribute("minimum") != null)
                    min = ((Element)inputP.elements("Parameter").get(i)).attributeValue("minimum");
            String max = "1";
            if (((Element)inputP.elements("Parameter").get(i)).attribute("maximum") != null)
                    max = ((Element)inputP.elements("Parameter").get(i)).attributeValue("maximum");
            String autos = "false";
            if (((Element)inputP.elements("Parameter").get(i)).attribute("autoSampling") != null)
                    autos = ((Element)inputP.elements("Parameter").get(i)).attributeValue("autoSampling");
            InputParameterInfo pi = new InputParameterInfo(name, type, value, min, max, autos);
            list.addElement(pi);
        }
        return list;
    }

    /**
     * Returns the list of output parameters
     *
     * @return DefaultListModel   list of output parameters
     *
     */
    public Vector<ParameterInfo> outputParameters(){
        Vector<ParameterInfo> list = new Vector<ParameterInfo>();
        Element outputP = (Element)this.simulator.getRootElement().element("OutputParameters");
        for (int i = 0; i < outputP.elements("Parameter").size(); i++){
            String name = ((Element)outputP.elements("Parameter").get(i)).attributeValue("name");
            String type = ((Element)outputP.elements("Parameter").get(i)).attributeValue("type");
            String value = "n/a";
            if (((Element)outputP.elements("Parameter").get(i)).attribute("value") != null)
                    value = ((Element)outputP.elements("Parameter").get(i)).attributeValue("value");
            String min = "-1";
            if (((Element)outputP.elements("Parameter").get(i)).attribute("minimum") != null)
                    min = ((Element)outputP.elements("Parameter").get(i)).attributeValue("minimum");
            String max = "1";
            if (((Element)outputP.elements("Parameter").get(i)).attribute("maximum") != null)
                    max = ((Element)outputP.elements("Parameter").get(i)).attributeValue("maximum");
            String autos = "false";
            OutputParameterInfo pi = new OutputParameterInfo(name, type, value, min, max);
            list.addElement(pi);
        }
        return list;
    }

    /**
     * Returns the list of possible sample evaluators for this simulator
     *
     * @return DefaultListModel   list of sample evaluators
     *
     */
    public DefaultComboBoxModel sampleEvaluators(){
        DefaultComboBoxModel model = new DefaultComboBoxModel();
        Element impl = this.simulator.getRootElement().element("Implementation");
        Element exec = impl.element("Executables");

        SystemArchitecture sysA = Util.getArchitecture();
        SystemPlatform sysP = Util.getPlatform();

        if (exec != null){
            model.addElement("---Executables--------------");
            for (int i = 0; i < exec.elements("Executable").size(); i++){
                if (((Element)exec.elements("Executable").get(i)).attribute("platform") != null){
                    String platform = ((Element)exec.elements("Executable").get(i)).attributeValue("platform");
                    if (((Element)exec.elements("Executable").get(i)).attribute("arch") != null){
                        String arch = ((Element)exec.elements("Executable").get(i)).attributeValue("arch");
                        
                        SystemPlatform simPlatform = Util.resolvePlatformName(platform);
                        SystemArchitecture simArch = Util.resolveArchitectureName(arch);                

                        if (simPlatform.holds(sysP) && simArch.holds(sysA)){
                            String tmp = platform + ":" + arch;
                            model.addElement(tmp);
                        }
                    }
                    else{
                        String tmp = platform;
                        model.addElement(tmp);
                    }
                }
            }
            model.addElement("calcua");
            model.addElement("begrid");
        }

        Element data = impl.element("DataFiles");
        if (data != null && !data.elements().isEmpty()){
            model.addElement("---DataFiles--------------");
            if (data.elements("ScatteredDataFile") != null){
                for (int i = 0; i < data.elements("ScatteredDataFile").size(); i++){
//                    if (((Element)data.elements("ScatteredDataFile").get(i)).attribute("id") != null){
                        String tmp = "scatteredDataset (" + ((Element)data.elements("ScatteredDataFile").get(i)).getText() + ")";
                        model.addElement(tmp);
//                    }
//                    else{
//                        String tmp = "scatteredDataset";
//                        model.addElement(tmp);
//                    }
                }
            }
            if (data.elements("GriddedDataFile") != null){
                for (int i = 0; i < data.elements("GriddedDataFile").size(); i++){
//                    if (((Element)data.elements("GriddedDataFile").get(i)).attribute("id") != null){
                        String tmp = "griddedDataset (" + ((Element)data.elements("GriddedDataFile").get(i)).getText() + ")";
                        model.addElement(tmp);
//                    }
//                    else{
//                        String tmp = "griddedDataset";
//                        model.addElement(tmp);
//                    }
                }
            }
        }
        return model;
    }
}
