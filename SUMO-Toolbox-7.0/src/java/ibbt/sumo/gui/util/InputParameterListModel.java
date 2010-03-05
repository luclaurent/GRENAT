/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.util;

import javax.swing.DefaultListModel;

/**
 *
 * @author theking
 */
public class InputParameterListModel extends DefaultListModel{
    private String name;
	private String type;
	private String value;
	private String min;
	private String max;
	private boolean autosampling;


    public InputParameterListModel(String name, String type, String value, String min, String max, boolean autos){
         this.name = name;
         this.type = type;
         this.value = value;
         this.min = min;
         this.max = max;
         this.autosampling = autos;
    }

    public String getMin() {
		return min;
	}

    public void setMin(String min) {
        this.min = min;
    }

    public String getMax() {
        return max;
    }

    public void setMax(String max) {
        this.max = max;
    }

    public boolean getAutosampling() {
        return autosampling;
    }

    public void setAutosampling(boolean autosampling) {
        this.autosampling = autosampling;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getName(){
        return this.name;
    }

    public String getType(){
        return this.type;
    }

    public String getValue(){
        return this.value;
    }

    public void setValue(String value){
        this.value = value;
    }

    public String toString(){
        return this.name + " : [" + this.min + ", " + this.max + "]";
    }
}
