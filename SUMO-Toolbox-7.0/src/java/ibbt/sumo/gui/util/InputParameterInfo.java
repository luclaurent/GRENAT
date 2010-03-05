/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.util;

public class InputParameterInfo extends ParameterInfo{

    /**
     * Create an instance of InputParameterInfo
     *
     * @param name      parameter name
     * @param type      parameter type
     * @param value     parameter value
     * @param min       minimal parameter value
     * @param max       maximal parameter value
     * @param autos     autosampling option for the parameter
     *
     */
    public InputParameterInfo(String name, String type, String value, String min, String max, String autos) {
        super(name, type, value, min, max, autos);
    }
}
