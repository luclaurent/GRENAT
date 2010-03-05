/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.context;

import java.util.Vector;

import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

/**
 * ToolboxConfigurationFile is created when finish button is clicked.
 * It holds all the informaio selected by the user, and can write this 
 * information to 1 or more files, depending what the user wants.
 *
 * @author Sasa Berberovic
 */
public class ToolboxConfigurationFile {
    DefaultXMLFile defaultXML;
    
    private PlanElement plan;
    private Vector<RunElement> runs;
    private Vector<InputElement> inputs;
    private Vector<OutputElement> outputs;

    /**
     * Creates ToolboxConfigurationFile with a DefaultXMLFile
     * @param defXML
     */
    public ToolboxConfigurationFile(DefaultXMLFile defXML) {
        this.defaultXML = defXML;
    }

    /**
     *
     * @param plan
     */
    public void addPlan(PlanElement plan){
        this.plan = plan;
    }

    /**
     *
     * @param runs
     */
    public void addRuns(Vector<RunElement> runs){
        this.runs = runs;
    }

    /**
     *
     * @param inputs
     */
    public void addInputParameters(Vector<InputElement> inputs){
        this.inputs = inputs;
    }

    /**
     *
     * @param outputs
     */
    public void addOutputParameters(Vector<OutputElement> outputs){
        this.outputs = outputs;
    }

    /**
     * Creates a sampleEvaluator element in a config.xml
     *
     * @param text      text node of the sampleevaluator element
     * @return Element  created sampleEvaluator element
     *
     */
    public Element createSampleEvaluatorElement(String text){
        Element sampleEval = DocumentHelper.createElement("SampleEvaluator");

        if (text.contains("matlab"))
            sampleEval.setText("matlab");
        else if (text.contains("java") || text.contains("unix") || text.contains("windows"))
            sampleEval.setText("local");
        else if (text.contains("scatteredDataset"))
            sampleEval.setText("scatteredDataset");
        else if (text.contains("griddedDataset"))
            sampleEval.setText("griddedDataset");
        else if (text.contains("calcua"))
            sampleEval.setText("calcua");
        else if (text.contains("begrid"))
            sampleEval.setText("begrid");

        return sampleEval;
    }

    /**
     *  Returns a document containing all the selected sonfiguration.
     *
     * @return Document created by the user with the GUI
     */
    public Document write(){
        Document doc = DocumentHelper.createDocument();

        Element root = DocumentHelper.createElement("ToolboxConfiguration");
        root.addAttribute("version", "6.1.1");

        Element plan = DocumentHelper.createElement("Plan");
        root.add(plan);

        Element simulator = DocumentHelper.createElement("Simulator");
        simulator.addText(this.plan.getSimulator().getId());
        plan.add(simulator);

        for (int i = 0; i < this.plan.nrOfCElements(); i++){
            String cname = this.plan.getConfigElement(i).getName();
            String cid = this.plan.getConfigElement(i).getId();
            
            if (cname.equals("SampleEvaluator")){              
                if (this.defaultXML instanceof ConfigXMLFile){
                    ConfigXMLFile config = (ConfigXMLFile) this.defaultXML;
                    if (cid.contains(config.getPrefix())){
                        Element tmp = DocumentHelper.createElement(cname);
                        tmp.setText(cid);
                        plan.add((Element)tmp.clone());
                    }
                    else{
                        plan.add((Element)this.createSampleEvaluatorElement(cid).clone());
                    }

                    if (config.getSampleEvaluatorElement(cid) == null)
                        continue;

                    Element e = (Element) config.getSampleEvaluatorElement(cid).clone();
                    if (!this.elementAlreadyAdded(e, root))
                        root.add(e);
                }
                else{
                    plan.add((Element)this.createSampleEvaluatorElement(cid).clone());
                    if (this.defaultXML.getSampleEvaluatorElement(cid) == null)
                        continue;

                    Element e = (Element) this.defaultXML.getSampleEvaluatorElement(cid).clone();
                    if (!this.elementAlreadyAdded(e, root))
                        root.add(e);
                }
            }
            else if (cname.equals("SampleSelector") && cid.equals("none")) {
                //do nothing
            }
            else{
                Element ce = DocumentHelper.createElement(cname);
                ce.setText(cid);
                plan.add(ce);

                if (this.defaultXML instanceof ConfigXMLFile){
                    ConfigXMLFile config = (ConfigXMLFile) this.defaultXML;
                    Element tmp = (Element) config.getConfigElement(cname, cid).clone();
                    if (!this.elementAlreadyAdded(tmp, root))
                        root.add(tmp);
                }
                else{
                    Element tmp = (Element) this.defaultXML.getConfigElement(cname, cid).clone();
                    if (!this.elementAlreadyAdded(tmp, root))
                        root.add(tmp);
                }
            }
        }

        for (int i = 0; i < this.plan.nrOfMeasures(); i++){
            plan.add((Element) this.plan.getMeasureElement(i).getMeasureElement().clone());
        }

        Element inputs = DocumentHelper.createElement("Inputs");
        for (int i = 0; i < this.inputs.size(); i++){
            Element input = (Element) this.inputs.get(i).getElement().clone();
            inputs.add(input);
        }
        plan.add(inputs);

        Element outputs = DocumentHelper.createElement("Outputs");
        for (int i = 0; i < this.outputs.size(); i++){
            Element output = (Element) this.outputs.get(i).getElement().clone();
            outputs.add(output);
        }
        plan.add(outputs);

        for (int i = 0; i < this.runs.size(); i++){
            Element run = DocumentHelper.createElement("Run");
            run.addAttribute("name", this.runs.get(i).getName());
            run.addAttribute("repeat", String.valueOf(this.runs.get(i).getRepititions()));

            for (int j = 0; j < this.runs.get(i).nrOfElements(); j++){
                String cname = this.runs.get(i).getConfigElement(j).getName();
                String cid = this.runs.get(i).getConfigElement(j).getId();

                if (cname.equals("SampleEvaluator")){
                    if (this.defaultXML instanceof ConfigXMLFile){
                        ConfigXMLFile config = (ConfigXMLFile) this.defaultXML;
                        if (cid.contains(config.getPrefix())){
                            Element tmp = DocumentHelper.createElement(cname);
                            tmp.setText(cid);
                            run.add((Element)tmp.clone());
                        }
                        else{
                            run.add((Element)this.createSampleEvaluatorElement(cid).clone());
                        }
                        if (config.getSampleEvaluatorElement(cid) == null)
                            continue;

                        Element e = (Element) config.getSampleEvaluatorElement(cid).clone();
                        if (!this.elementAlreadyAdded(e, root))
                            root.add(e);
                    }
                    else{
                        run.add((Element)this.createSampleEvaluatorElement(cid).clone());
                        if (this.defaultXML.getSampleEvaluatorElement(cid) == null)
                            continue;

                        Element e = (Element) this.defaultXML.getSampleEvaluatorElement(cid).clone();
                        if (!this.elementAlreadyAdded(e, root))
                            root.add(e);
                    }
                }
                else if (cname.equals("SampleSelector") && cid.equals("none")) {
                    //do nothing
                }
                else{
                    Element ce = DocumentHelper.createElement(cname);
                    ce.setText(cid);
                    run.add(ce);

                    if (this.defaultXML instanceof ConfigXMLFile){
                        ConfigXMLFile config = (ConfigXMLFile) this.defaultXML;
                        Element tmp = (Element) config.getConfigElement(cname, cid).clone();
                        if (!this.elementAlreadyAdded(tmp, root))
                            root.add(tmp);
                    }
                    else{
                        Element tmp = (Element) this.defaultXML.getConfigElement(cname, cid).clone();
                        if (!this.elementAlreadyAdded(tmp, root))
                            root.add(tmp);
                    }
                }
            }

            for (int j = 0; j < this.runs.get(i).nrOfMeasures(); j++){
                run.add((Element) this.runs.get(i).getMeasure(j).getMeasureElement().clone());
            }

            plan.add(run);
        }
        
        root.add((Element)this.defaultXML.getConfigElement("Logging").clone());
        doc.setRootElement(root);

        return doc;
    }

    /**
     * This one u used when every run element hes to be in a seprate file.
     * 
     * @return vector of documents, one for every run element.
     */
    public Vector<Document> writeMultipleFiles(){
        Vector<Document> docs = new Vector<Document>();

        for (int k = 0; k < this.runs.size(); k++){
            Document doc = DocumentHelper.createDocument();

            Element root = DocumentHelper.createElement("ToolboxConfiguration");
            root.addAttribute("version", "6.1.1");

            Element plan = DocumentHelper.createElement("Plan");
            root.add(plan);

            Element simulator = DocumentHelper.createElement("Simulator");
            simulator.addText(this.plan.getSimulator().getId());
            plan.add(simulator);

            for (int i = 0; i < this.plan.nrOfCElements(); i++){
                String cname = this.plan.getConfigElement(i).getName();
                String cid = this.plan.getConfigElement(i).getId();

                if (cname.equals("SampleEvaluator")){
                    if (this.defaultXML instanceof ConfigXMLFile){
                        ConfigXMLFile config = (ConfigXMLFile) this.defaultXML;
                        if (cid.contains(config.getPrefix())){
                            Element tmp = DocumentHelper.createElement(cname);
                            tmp.setText(cid);
                            plan.add((Element)tmp.clone());
                        }
                        else{
                            plan.add((Element)this.createSampleEvaluatorElement(cid).clone());
                        }

                        if (config.getSampleEvaluatorElement(cid) == null)
                            continue;

                        Element e = (Element) config.getSampleEvaluatorElement(cid).clone();
                        if (!this.elementAlreadyAdded(e, root))
                            root.add(e);
                    }
                    else{
                        plan.add((Element)this.createSampleEvaluatorElement(cid).clone());
                        if (this.defaultXML.getSampleEvaluatorElement(cid) == null)
                            continue;

                        Element e = (Element) this.defaultXML.getSampleEvaluatorElement(cid).clone();
                        if (!this.elementAlreadyAdded(e, root))
                            root.add(e);
                    }
                }
                else if (cname.equals("SampleSelector") && cid.equals("none")) {
                    //do nothing
                }
                else{
                    Element ce = DocumentHelper.createElement(cname);
                    ce.setText(cid);
                    plan.add(ce);

                    if (this.defaultXML instanceof ConfigXMLFile){
                        ConfigXMLFile config = (ConfigXMLFile) this.defaultXML;
                        Element tmp = (Element) config.getConfigElement(cname, cid).clone();
                        if (!this.elementAlreadyAdded(tmp, root))
                            root.add(tmp);
                    }
                    else{
                        Element tmp = (Element) this.defaultXML.getConfigElement(cname, cid).clone();
                        if (!this.elementAlreadyAdded(tmp, root))
                            root.add(tmp);
                    }
                }
            }

            for (int i = 0; i < this.plan.nrOfMeasures(); i++){
                plan.add((Element) this.plan.getMeasureElement(i).getMeasureElement().clone());
            }

            Element inputs = DocumentHelper.createElement("Inputs");
            for (int i = 0; i < this.inputs.size(); i++){
                Element input = (Element) this.inputs.get(i).getElement().clone();
                inputs.add(input);
            }
            plan.add(inputs);

            Element outputs = DocumentHelper.createElement("Outputs");
            for (int i = 0; i < this.outputs.size(); i++){
                Element output = (Element) this.outputs.get(i).getElement().clone();
                outputs.add(output);
            }
            plan.add(outputs);


            Element run = DocumentHelper.createElement("Run");
            run.addAttribute("name", this.runs.get(k).getName());
            run.addAttribute("repeat", String.valueOf(this.runs.get(k).getRepititions()));

            for (int j = 0; j < this.runs.get(k).nrOfElements(); j++){
                String cname = this.runs.get(k).getConfigElement(j).getName();
                String cid = this.runs.get(k).getConfigElement(j).getId();

                if (cname.equals("SampleEvaluator")){                    
                    if (this.defaultXML instanceof ConfigXMLFile){
                        ConfigXMLFile config = (ConfigXMLFile) this.defaultXML;
                        if (cid.contains(config.getPrefix())){
                            Element tmp = DocumentHelper.createElement(cname);
                            tmp.setText(cid);
                            run.add((Element)tmp.clone());
                        }
                        else{
                            run.add((Element)this.createSampleEvaluatorElement(cid).clone());
                        }

                        if (config.getSampleEvaluatorElement(cid) == null)
                            continue;

                        Element e = (Element) config.getSampleEvaluatorElement(cid).clone();
                        if (!this.elementAlreadyAdded(e, root))
                            root.add(e);
                    }
                    else{
                        run.add((Element)this.createSampleEvaluatorElement(cid).clone());
                        
                        if (this.defaultXML.getSampleEvaluatorElement(cid) == null)
                            continue;

                        Element e = (Element) this.defaultXML.getSampleEvaluatorElement(cid).clone();
                        if (!this.elementAlreadyAdded(e, root))
                            root.add(e);
                    }
                }
                else if (cname.equals("SampleSelector") && cid.equals("none")) {
                    //do nothing
                }
                else{
                    Element ce = DocumentHelper.createElement(cname);
                    ce.setText(cid);
                    run.add(ce);

                    if (this.defaultXML instanceof ConfigXMLFile){
                        ConfigXMLFile config = (ConfigXMLFile) this.defaultXML;
                        Element tmp = (Element) config.getConfigElement(cname, cid).clone();
                        if (!this.elementAlreadyAdded(tmp, root))
                            root.add(tmp);
                    }
                    else{
                        Element tmp = (Element) this.defaultXML.getConfigElement(cname, cid).clone();
                        if (!this.elementAlreadyAdded(tmp, root))
                            root.add(tmp);
                    }
                }
            }

            for (int j = 0; j < this.runs.get(k).nrOfMeasures(); j++){
                run.add((Element)this.runs.get(k).getMeasure(j).getMeasureElement().clone());
            }
            plan.add(run);

            root.add((Element)this.defaultXML.getConfigElement("Logging").clone());
            
            doc.setRootElement(root);
            docs.add(doc);
        }

        return docs;
    }

    /**
     * Checks if a cofig element already exists in the toolboxconfigfile
     *
     * @param e     element to be checked
     * @param root  element that should contain e
     *
     */
    public boolean elementAlreadyAdded(Element e, Element root) {
        for (int i = 0; i < root.elements().size(); i++){
            Element tmp = (Element) root.elements().get(i);
            if (tmp.getName().equals(e.getName())
                    && tmp.attributeValue("id").equals(e.attributeValue("id"))){
                return true;
            }
        }
        return false;
    }

}
