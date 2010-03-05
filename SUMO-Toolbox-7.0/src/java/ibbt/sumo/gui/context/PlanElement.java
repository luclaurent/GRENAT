/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.context;

import java.util.Vector;

/**
 * Contains all the information selected by the user for the plan element
 * @author Sasa Berberovic
 */
public class PlanElement {
    private Vector<ConfigElement> configElements;
    private Vector<RunElement> runs;
    private Vector<InputElement> inputs;
    private Vector<OutputElement> outputs;
    private Vector<MeasureElement> measures;
    private ConfigElement simulator;

    /**
     * Create a new PlanElement
     *
     */
    public PlanElement(){
        this.configElements = new Vector<ConfigElement>();
        this.inputs = new Vector<InputElement>();
        this.outputs = new Vector<OutputElement>();
        this.runs = new Vector<RunElement>();
        this.measures = new Vector<MeasureElement>();
    }

    /**
     * Adds a new config element to the plan
     *
     * @param celement   ConfigElement that is added
     */
    public void addConfigElement(ConfigElement celement){
        this.configElements.add(celement);
    }

    /**
     * Adds a measure element to plan element
     *
     * @param m MeasureElement that is added
     */
    public void addMeasureElement(MeasureElement m) {
        this.measures.add(m);
    }

    /**
     * Remove the measure element from the plan
     *
     */
    public void removeMeaures(){
        this.measures.clear();
    }

    /**
     * Checks if a plan element contains an measure element
     *
     * @return true     if plan contains a measure element
     * @return false    if plan doesn't contains a measure element
     */
    public boolean hasMeasures(){
        return this.measures.isEmpty();
    }

    /**
     * Return the measure element in plan
     *
     * @return MeasureElement   MeasureElement in plan
     */
    public MeasureElement getMeasureElement(int index) {
        return measures.get(index);
    }

    /**
     * Adds a new run element to the plan
     *
     * @param run   RunElement that is added
     */
    public void addRun(RunElement run){
        this.runs.add(run);
    }

    /**
     * Removes the last added run element
     *
     * @return RunElement last added run element
     */
    public RunElement removeRun(){
        return this.runs.remove(this.runs.size() - 1);
    }

    /**
     * Adds a new input element to the plan
     *
     * @param input   InputElement that is added
     */
    public void addInput(InputElement input){
        this.inputs.add(input);
    }

    /**
     * Adds a new output element to the plan
     *
     * @param output   OutputElement that is added
     */
    public void addOuput(OutputElement output){
        this.outputs.add(output);
    }

    /**
     * Return the ith config element in the plan
     *
     * @param index              ith config element in the plan
     * @return ConfigElement    ConfigElement on the position index
     */
    public ConfigElement getConfigElement(int index){
        return this.configElements.get(index);
    }

    /**
     * Return the id of the config element in the plan, given the config name
     *
     * @param cname     name of the config element
     * @return String   id of the config element
     */
    public String getConfigElement(String cname) {
        for (int i = 0; i < this.configElements.size(); i++){
            if (this.configElements.get(i).getName().equals(cname)){
                return this.configElements.get(i).getId();
            }
        }
        return null;
    }

    /**
     * Return the ith run element in the plan
     *
     * @param index             ith run element in the plan
     * @return RunElement    RunElement on the position index
     */
    public RunElement getRun(int index) {
        return this.runs.get(index);
    }

    /**
     * Return the ith input element in the plan
     *
     * @param index             ith input element in the plan
     * @return InputElement    InputElement on the position index
     */
    public InputElement getInput(int index) {
        return this.inputs.get(index);
    }

    /**
     * Return the ith output element in the plan
     *
     * @param index             ith output element in the plan
     * @return OutputElement    OutputElement on the position index
     */
    public OutputElement getOutput(int index) {
        return this.outputs.get(index);
    }

    /**
     * Return the nr of config element in the plan
     *
     * @return int  nr of config element in the plan
     */
    public int nrOfCElements(){
        return this.configElements.size();
    }

    /**
     * Return the nr of run element in the plan
     *
     * @return int  nr of run element in the plan
     */
    public int nrOfRuns(){
        return this.runs.size();
    }

    /**
     * Return the nr of input element in the plan
     *
     * @return int  nr of input element in the plan
     */
    public int nrOfInputs(){
        return this.inputs.size();
    }

    /**
     * Return the nr of output element in the plan
     *
     * @return int  nr of output element in the plan
     */
    public int nrOfOutputs(){
        return this.outputs.size();
    }

    /**
     * Return the nr of measure elements in the plan
     *
     * @return int  nr of measure elements in the plan
     */
    public int nrOfMeasures(){
        return this.measures.size();
    }
    
    /**
     * Return the Last element added to the plan
     *
     * @return RunElement   last RunElement added
     */
    public RunElement getLastRunAdded() {
        return this.runs.lastElement();
    }

    /**
     *
     * @param simulatorName
     * @param simulatorPath
     */
    public void addSimulatorElement(String simulatorName, String simulatorPath) {
        this.simulator = new ConfigElement(simulatorName, simulatorPath);
    }

    /**
     * 
     * @return
     */
    public ConfigElement getSimulator(){
        return this.simulator;
    }
}
