/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.context;

import ibbt.sumo.gui.util.ParameterInfo;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;

/**
 * Contains informatio of the selected output parameter
 *
 * @author Sasa Berberovic
 */
public class OutputElement {
//    private String name;
    private ParameterInfo param;

    /**
     * Creates an OutputElement with name of the selected output parameter
     *
     * @param name  name of the selected output parameter
     */
    public OutputElement(String name) {
//        this.name = name;
    }

    /**
     * Creates an OutputElement with information of the parameter
     *
     * @param pi  informtion of the selected parameter
     */
    public OutputElement(ParameterInfo pi) {
        this.param = pi;
    }

    /**
     * Getter for the name of the output element
     *
     * @return String   name of the output element
     */
    public String getName() {
        return this.param.getName();
    }

    /**
     * Getter for the type of the output element
     *
     * @return String   type of the output element
     */
    public String getType() {
        return this.param.getType();
    }


    /**
     * Getter for the value of the output element
     *
     * @return String   value of the output element
     */
    public String getValue() {
        return this.param.getValue();
    }

    /**
     * Getter for the maximum value of the output element
     *
     * @return String   maximum value of the output element
     */
    public String getMax() {
        return this.param.getMax();
    }

    /**
     * Getter for the minimum value of the output element
     *
     * @return String   minimum value of the output element
     */
    public String getMin() {
        return this.param.getMax();
    }

    public Element getElement(){
        Element e = DocumentHelper.createElement("Output");
        e.addAttribute("name", this.param.getName());
        e.addAttribute("complexHandeling", this.param.getType());

        return e;
    }
}
