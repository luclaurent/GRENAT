/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.util;

/**
 *
 * @author Sasa Berberovic
 */
public class OutputParameterInfo extends ParameterInfo{
   
    public OutputParameterInfo(String name, String type, String value, String min, String max) {
        super(name, type, value, min, max, "false");
    }

    public OutputParameterInfo(String name, String type) {
        super(name, type, "n/a", "-1.0", "1.0", "false");
    }
}
