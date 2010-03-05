/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.context;

import ibbt.sumo.gui.util.ParameterInfo;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;

/**
 * Contains informatio of the selected input parameter
 *
 * @author Sasa Berberovic
 */
public class InputElement {
//    private String name;
    private ParameterInfo param;

    /**
     * Creates an InputElement with name of the selected input parameter
     *
     * @param name  name of the selected input parameter
     */
    public InputElement(String name){
//        this.name = name;
    }

    /**
     * Creates an InputElement with information of the parameter
     *
     * @param pi  informtion of the selected parameter
     */
    public InputElement(ParameterInfo pi) {
        this.param = pi;
    }

    /**
     * Getter for the name of the input element
     *
     * @return String   name of the input element
     */
    public String getName() {
        return this.param.getName();
    }

    /**
     * Getter for the type of the input element
     *
     * @return String   type of the input element
     */
    public String getType() {
        return this.param.getType();
    }


    /**
     * Getter for the value of the input element
     *
     * @return String   value of the input element
     */
    public String getValue() {
        return this.param.getValue();
    }

    /**
     * Getter for the maximum value of the input element
     *
     * @return String   maximum value of the input element
     */
    public String getMax() {
        return this.param.getMax();
    }

    /**
     * Getter for the minimum value of the input element
     *
     * @return String   minimum value of the input element
     */
    public String getMin() {
        return this.param.getMax();
    }

    /**
     * Getter for the autosampling of the input element
     *
     * @return String   autosampling of the input element
     */
    public String getAutosampling() {
        return this.param.getAutosampling();
    }

    public Element getElement(){
        Element e = DocumentHelper.createElement("Input");
        e.addAttribute("name", this.param.getName());
//        e.addAttribute("type", this.param.getType());
        if (!this.param.getValue().equals("n/a")){
            e.addAttribute("value", this.param.getValue());
        }
//        e.addAttribute("min", this.param.getMin());
//        e.addAttribute("max", this.param.getMax());
//        e.addAttribute("autosampling", this.param.getAutosampling());

        return e;
    }
}
