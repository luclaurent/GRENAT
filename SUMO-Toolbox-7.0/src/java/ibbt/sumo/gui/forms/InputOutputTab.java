/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * InputOutputPanel.java
 *
 * Created on Jul 9, 2009, 7:09:40 PM
 */

package ibbt.sumo.gui.forms;

import ibbt.sumo.gui.context.ConfigXMLFile;
import ibbt.sumo.gui.context.InputElement;
import ibbt.sumo.gui.context.OutputElement;
import ibbt.sumo.gui.context.SimulatorXMLFile;
import ibbt.sumo.gui.util.ParameterInfo;

import java.util.Vector;

import org.dom4j.DocumentHelper;
import org.dom4j.Element;

/**
 *
 * @author theking
 */
public class InputOutputTab extends javax.swing.JPanel {
    private NewConfigFileForm parent;
    private SimulatorXMLFile simulator;
    private ConfigXMLFile config;

    /**
     * 
     * @param parent
     * @param simXML
     */
    public InputOutputTab(NewConfigFileForm parent, SimulatorXMLFile simXML) {
        this.parent = parent;
        this.simulator = simXML;
        initComponents();
        initParameters();
    }

    /**
     * 
     * @param parent
     * @param confXML
     * @param simXML
     */
    public InputOutputTab(NewConfigFileForm parent, ConfigXMLFile confXML, SimulatorXMLFile simXML) {
        this.parent = parent;
        this.config = confXML;
        this.simulator = simXML;
        initComponents();
        initParameters();
    }

    public InputOutputTab(NewConfigFileForm parent, ConfigXMLFile config) {
        this.parent = parent;
        this.config = config;
        this.simulator = config.getSimXMLFile();
        initComponents();
        initParametersFromConfig();
    }

    /**
     *
     */
    public void initParametersFromConfig() {
        this.inputsPanel.removeAll();
        this.outputsPanel.removeAll();

        for (int i = 0; i < this.config.getInputParameters().size(); i++){
            this.inputsPanel.add(new InputParameterPanel(this.config.getInputParameters().get(i)));
        }

        for (int i = 0; i < this.config.getOutputParameters().size(); i++){
            this.outputsPanel.add(new OutputParameterPanel(this.config.getOutputParameters().get(i)));
        }
    }

    /**
     *
     */
    public void initParameters(){
        this.inputsPanel.removeAll();
        this.outputsPanel.removeAll();

        for (int i = 0; i < this.simulator.inputParameters().size(); i++){
           this.inputsPanel.add(new InputParameterPanel(this.simulator.inputParameters().get(i)));
        }

        for (int i = 0; i < this.simulator.outputParameters().size(); i++){
            this.outputsPanel.add(new OutputParameterPanel(this.simulator.outputParameters().get(i)));
        }
    }

    /**
     *
     * @param in
     * @param out
     */
    public void setParameters(Vector<ParameterInfo> in, Vector<ParameterInfo> out) {
        this.inputsPanel.removeAll();
        for (int i = 0; i < in.size(); i++){
            this.inputsPanel.add(new InputParameterPanel(in.get(i)));
        }

        this.outputsPanel.removeAll();
        for (int i = 0; i < out.size(); i++){
            this.outputsPanel.add(new OutputParameterPanel(out.get(i)));
        }
    }

    /**
     * Return the list of selected input parameters
     *
     * @return
     */
    public Vector<InputElement> getInputParameters(){
        Vector<InputElement> result = new Vector<InputElement>();
        for (int i = 0; i < this.inputsPanel.getComponentCount(); i++){
            InputParameterPanel in = (InputParameterPanel)this.inputsPanel.getComponent(i);
            if (in.isSelected())
                result.add(in.getInputElement());
        }
        return result;
    }

    /**
     * Returns the list of selected output parameters
     *
     * @return
     */
    public Vector<OutputElement> getOutputParameters(){
        Vector<OutputElement> result = new Vector<OutputElement>();
        for (int i = 0; i < this.outputsPanel.getComponentCount(); i++){
            OutputParameterPanel out = (OutputParameterPanel)this.outputsPanel.getComponent(i);
            if (out.isSelected())
                result.add(out.getOutputElement());
        }
        return result;
    }

    /**
     *
     */
    public void clearInputOutputPanels() {
        this.inputsPanel.removeAll();
        this.outputsPanel.removeAll();
    }

    /**
     *
     * @return
     */
    public Element getInputsElement(){
        Element inputs = DocumentHelper.createElement("Inputs");
        for (int i = 0; i < this.inputsPanel.getComponentCount(); i++){
            InputParameterPanel in = (InputParameterPanel)this.inputsPanel.getComponent(i);
            if (in.isSelected()){
                Element input = DocumentHelper.createElement("Input");
                input.addAttribute("name", in.getInputName());
                input.addAttribute("type", in.getInputType());
                input.addAttribute("value", in.getInputValue());
                input.addAttribute("min", in.getInputMin());
                input.addAttribute("max", in.getInputMax());
                input.addAttribute("autosampling", in.getInputAutoSampling());
                inputs.add(input);
            }
        }
        return inputs;
    }

    /**
     *
     * @return
     */
    public Element getOutputsElement(){
        Element outputs = DocumentHelper.createElement("outputs");
        for (int i = 0; i < this.outputsPanel.getComponentCount(); i++){
            OutputParameterPanel out = (OutputParameterPanel)this.inputsPanel.getComponent(i);
            if (out.isSelected()){
                Element output = DocumentHelper.createElement("Output");
                output.addAttribute("name", out.getOutputName());
                output.addAttribute("type", out.getOutputType());
                outputs.add(output);
            }
        }
        return outputs;
    }

    /**
     *
     * @return
     */
    public boolean atLeastOneInputSelected(){
        for (int i = 0; i < this.inputsPanel.getComponentCount(); i++){
            if (((InputParameterPanel)this.inputsPanel.getComponent(i)).isSelected()){
                return true;
            }
        }
        return false;
    }

    /**
     *
     * @return
     */
    public boolean atLeastOneOutputSelected(){
        for (int i = 0; i < this.outputsPanel.getComponentCount(); i++){
            if (((OutputParameterPanel)this.outputsPanel.getComponent(i)).isSelected()){
                return true;
            }
        }
        return false;
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jLabel3 = new javax.swing.JLabel();
        jPanel1 = new javax.swing.JPanel();
        jScrollPane1 = new javax.swing.JScrollPane();
        inputsPanel = new javax.swing.JPanel();
        jScrollPane2 = new javax.swing.JScrollPane();
        outputsPanel = new javax.swing.JPanel();

        setPreferredSize(new java.awt.Dimension(869, 490));

        jLabel3.setIcon(new javax.swing.ImageIcon("sumo.ico")); // NOI18N
        jLabel3.setText("Select input and output parametes for the configuration file.");

        jScrollPane1.setBorder(null);

        inputsPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Input Parameters"));
        inputsPanel.setLayout(new javax.swing.BoxLayout(inputsPanel, javax.swing.BoxLayout.PAGE_AXIS));
        jScrollPane1.setViewportView(inputsPanel);

        jScrollPane2.setBorder(null);

        outputsPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Output Parameters"));
        outputsPanel.setLayout(new javax.swing.BoxLayout(outputsPanel, javax.swing.BoxLayout.PAGE_AXIS));
        jScrollPane2.setViewportView(outputsPanel);

        org.jdesktop.layout.GroupLayout jPanel1Layout = new org.jdesktop.layout.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(jScrollPane1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 829, Short.MAX_VALUE)
            .add(jScrollPane2, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 829, Short.MAX_VALUE)
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(jPanel1Layout.createSequentialGroup()
                .add(jScrollPane1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 213, Short.MAX_VALUE)
                .add(jScrollPane2, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 213, Short.MAX_VALUE))
        );

        org.jdesktop.layout.GroupLayout layout = new org.jdesktop.layout.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createSequentialGroup()
                .addContainerGap()
                .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
                    .add(jPanel1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .add(jLabel3, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 829, Short.MAX_VALUE))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createSequentialGroup()
                .addContainerGap()
                .add(jLabel3)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(jPanel1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addContainerGap())
        );
    }// </editor-fold>//GEN-END:initComponents


    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JPanel inputsPanel;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JPanel outputsPanel;
    // End of variables declaration//GEN-END:variables


}
