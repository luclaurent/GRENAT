/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.context;

import java.util.Vector;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;

/**
 *  Contains all the information selected by the user for the run element
 *
 * @author Sasa Berberovic
 */
public class RunElement {
    private String name;
    private int repititions;
    private Vector<ConfigElement> elements;
    private Vector<MeasureElement> measures;
    private Element run;


    /**
     * Create a new RunElement
     *
     */
    public RunElement(){
        this.elements = new Vector<ConfigElement>();
        this.name = "";
        this.repititions = 1;
        this.measures = new Vector<MeasureElement>();
    }

    /**
     * Create a new RunElement with run name and run repititions
     *
     * @param runname           name of the run element
     * @param runrepititions    repititions of the run element
     */
    public RunElement(String runname, int runrepititions) {
        this.elements = new Vector<ConfigElement>();
        this.name = runname;
        this.repititions = runrepititions;
        this.measures = new Vector<MeasureElement>();
    }

    public RunElement(Element run){
        this.run = run;
        initRunElement();
    }

    public void initRunElement() {
        this.elements = new Vector<ConfigElement>();
        this.measures = new Vector<MeasureElement>();
        this.name = this.run.attributeValue("name");
        this.repititions = Integer.parseInt(this.run.attributeValue("repeat"));

        for (int i = 0; i < this.run.elements().size(); i++){
            Element e = (Element) this.run.elements().get(i);
            if (e.getName().equals("Measure")){
                MeasureElement m = new MeasureElement();
                m.setType(e.attributeValue("type"));
                m.setTarget(e.attributeValue("target"));
                m.setErrFunction(e.attributeValue("errorFcn"));
                m.setUse(e.attributeValue("use"));

                this.measures.add(m);
            }
            else if (e.getName().equals("Inputs")){
                // TODO
            }
            else if (e.getName().equals("Outputs")){
                // TODO
            }
            else{
                ConfigElement ce = new ConfigElement(e.getName(), e.getText());
                this.elements.add(ce);
            }
        }
    }

     /**
     * Return the measure element in run
     *
     * @return MeasureElement   MeasureElement in run
     */
    public MeasureElement getMeasure(int index) {
        return measures.get(index);
    }

    /**
     * Set a measure element to run element
     *
     * @param m MeasureElement to set
     */
    public void addMeasures(MeasureElement m) {
        this.measures.add(m);
    }

    /**
     * Checks if a run element contains an measure element
     *
     * @return true     if run contains a measure element
     * @return false    if run doesn't contains a measure element
     */
    public boolean hasMeasures() {
        return !this.measures.isEmpty();
    }

    public int nrOfMeasures(){
        return this.measures.size();
    }

    public void setName(String n) {
        this.name = n;
    }

    /**
     * Return the run element name
     *
     * @return String   run name
     */
    public String getName() {
        return this.name;
    }

    public void setRepititions(int rep) {
        this.repititions = rep;
    }

    /**
     * Return the run element repitititions
     *
     * @return int  run repititions
     */
    public int getRepititions() {
        return this.repititions;
    }

     /**
     * Adds a new config element to the run element
     *
     * @param e   ConfigElement that is added
     */
    public void addElement(ConfigElement e) {
        this.elements.addElement(e);
    }

    /**
     * Return the nr of config element in the run
     *
     * @return int  nr of config element in the run
     */
    public int nrOfElements() {
        return this.elements.size();
    }

    /**
     * Checks if run contains any config elements
     *
     * @return true  if there are config elements in run
     * @return false if run doesn't contain any run elements
     */
    public boolean isEmpty() {
        return this.elements.isEmpty();
    }

    /**
     * 
     * @param text
     * @return
     */
    public Element createSampleEvaluatorElement(String text){
        Element sampleEval = DocumentHelper.createElement("SampleEvaluator");

        if (text.contains("matlab"))
            sampleEval.setText("matlab");
        else if (text.contains("java") || text.contains("unix") || text.contains("windows"))
            sampleEval.setText("local");
        else if (text.contains("ScatteredDataFile"))
            sampleEval.setText("scatteredDataset");
        else if (text.contains("GriddedDataFile"))
            sampleEval.setText("griddedDataset");
        else if (text.contains("calcua"))
            sampleEval.setText("calcua");
        else if (text.contains("begrid"))
            sampleEval.setText("begrid");

        return sampleEval;
    }

    /**
     * 
     * @return
     */
    public Element getElement(){
        Element e = DocumentHelper.createElement("Run");
        e.addAttribute("name", this.name);
        e.addAttribute("repeat", String.valueOf(this.repititions));

        for (int i = 0; i < this.elements.size(); i++){
            if (this.elements.get(i).getName().equals("SampleEvaluator")){
                e.add((Element)this.createSampleEvaluatorElement(this.elements.get(i).getId()).clone());
            }
            else{
                e.addElement(this.elements.get(i).getName()).addText(this.elements.get(i).getId());
            }
        }

        for (int i = 0; i < this.measures.size(); i++){
            Element m = DocumentHelper.createElement("Measure");
            m.addAttribute("type", this.measures.get(i).getType());
            m.addAttribute("target", this.measures.get(i).getTarget());
            m.addAttribute("errFunction", this.measures.get(i).getErrFunction());
            e.add(m);
        }
        
        return e;
    }
    
    /**
     * Return the ith config element in the run
     *
     * @param index             ith config element in the run
     * @return ConfigElement    ConfigElement on the position index
     */
    public ConfigElement getConfigElement(int index) {
        return this.elements.get(index);
    }

    public boolean containsConfigElement(String cname) {
        for (int i = 0; i < this.elements.size(); i++){
            if (this.elements.get(i).getName().equals(cname))
                return true;
        }
        return false;
    }

    public void removeConfigAllElements(){
        this.elements.clear();
    }

    public void removeAllMeasures(){
        this.measures.clear();
    }

}
