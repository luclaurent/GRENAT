/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.context;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;

/**
 * Holds the information of the measure element selected by the user
 *
 * @author Sasa Berberovic
 */
public class MeasureElement {
    private String type;
    private String target;
    private String errFunction;
    private String use;
    private Element measure;

    /**
     * Create an measure element
     *
     */
    public MeasureElement(){
        this.type = "";
        this.target = "";
        this.errFunction = "";
        this.measure = DocumentHelper.createElement("Measure");
    }

    /**
     * Create an measure element with type, target en errorFunction
     *
     * @param mtype     type of the measure element
     * @param target    target for the measure element
     * @param merrf     errorFunction used by the measure element
     */
    public MeasureElement(String mtype, String mtarget, String merrf){
        this.type = mtype;
        this.target = mtarget;
        this.errFunction = merrf;
        this.measure = DocumentHelper.createElement("Measure");
        this.measure.addAttribute("type", this.type);
        this.measure.addAttribute("target", this.target);
        this.measure.addAttribute("errorFcn", this.errFunction);
    }

    /**
     * 
     * @param m
     */
    public MeasureElement(Element m){
        initMeasureElement(m);
        this.measure = (Element) m.clone();
    }

    /**
     * Getter for the errFucntion
     *
     * @return String   err function used
     */
    public String getErrFunction() {
        return errFunction;
    }

    /**
     * Setter for the err function
     *
     * @param errFunction   errFunction used for the measure element
     */
    public void setErrFunction(String errFunction) {
        this.errFunction = errFunction;
        this.measure.addAttribute("errorFcn", this.errFunction);
    }

    /**
     * Getter for the measure target
     *
     * @return String   measure target
     */
    public String getTarget() {
        return target;
    }

    /**
     * Setter for the measure target
     *
     * @param target   measure target
     */
    public void setTarget(String target) {
        this.target = target;
        this.measure.addAttribute("target", this.target);
    }

    /**
     * Getter for the measure type
     *
     * @return String   measure type
     */
    public String getType() {
        return type;
    }

   /**
     * Setter for the measure type
     *
     * @param type   measure type
     */
    public void setType(String type) {
        this.type = type;
        this.measure.addAttribute("type", this.type);
    }

    /**
     * Setter for the use of measure
     *
     * @param use
     */
    public void setUse(String use) {
        this.use = use;
        this.measure.addAttribute("use", this.use);
    }

    /**
     * 
     * @return
     */
    public String getUse(){
        return this.use;
    }

    /**
     * 
     * @return
     */
    public Element getMeasureElement(){
        return (Element) this.measure.clone();
    }

    /**
     * Setter for measre element
     * @param e
     */
    public void setMeasureElement(Element e) {
        this.initMeasureElement(e);
        this.measure = (Element) e.clone();
    }

    private void initMeasureElement(Element m) {
        if (m.attributeValue("type") != null) {
            this.type = m.attributeValue("type");
        }
        if (m.attributeValue("target") != null) {
            this.target = m.attributeValue("target");
        }
        if (m.attributeValue("errorFcn") != null) {
            this.errFunction = m.attributeValue("errorFcn");
        }
        if (m.attributeValue("use") != null) {
            this.use = m.attributeValue("use");
        }
    }
}
