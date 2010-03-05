/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * InputParamterPanel.java
 *
 * Created on Jul 8, 2009, 2:44:16 PM
 */

package ibbt.sumo.gui.forms;

import ibbt.sumo.gui.context.InputElement;
import ibbt.sumo.gui.util.InputParameterInfo;
import ibbt.sumo.gui.util.ParameterInfo;
import ibbt.sumo.gui.util.Util;

import javax.swing.JFrame;
import javax.swing.JOptionPane;

/**
 *
 * @author theking
 */
public class InputParameterPanel extends javax.swing.JPanel {
    private ParameterInfo info;

    /** Creates new form InputParamterPanel
     *
     * @param pi    Information of the input parameter
     *
     */
    public InputParameterPanel(ParameterInfo pi) {
        this.info = pi;
        initComponents();
        setValues();
    }

    /** Sets the value of the componenets on the panel.
     *
     */
    public void setValues() {
        this.inputName.setText(this.info.getName());
        this.inputName.setSelected(true);
        this.inputType.setText(this.info.getType());
        this.inputValue.setText(this.info.getValue());
        this.inputMinValue.setText(this.info.getMin());
        this.inputMaxValue.setText(this.info.getMax());
        if (this.info.getAutosampling().equals("true"))
            this.inputAutosampling.setSelected(true);
        else
            this.inputAutosampling.setSelected(false);
    }

    /** Return the parameter information selected by the user
     *
     */
    public ParameterInfo getParameterInfo(){
        String name = this.inputName.getText();
        String type = this.inputType.getText();
        String value = this.inputValue.getText();
        String min = this.inputMinValue.getText();
        String max = this.inputMaxValue.getText();
        String autos = "";
        if (this.inputAutosampling.isSelected())
            autos = "true";
        else
            autos = "false";

        return new ParameterInfo(name, type, value, min, max, autos);
    }

    /**
     * Checks if the input parameter is selected
     *
     */
    public boolean isSelected(){
        return this.inputName.isSelected();
    }

    public InputElement getInputElement(){
        return new InputElement(this.getParameterInfo());
    }


    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        inputName = new javax.swing.JCheckBox();
        typeLabel = new javax.swing.JLabel();
        inputType = new javax.swing.JLabel();
        valueLabel = new javax.swing.JLabel();
        inputValue = new javax.swing.JTextField();
        minLabel = new javax.swing.JLabel();
        inputMinValue = new javax.swing.JTextField();
        maxLabel = new javax.swing.JLabel();
        inputMaxValue = new javax.swing.JTextField();
        inputAutosampling = new javax.swing.JCheckBox();
        resetAllValue = new javax.swing.JButton();

        inputName.setText("Name");
        inputName.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                inputNameActionPerformed(evt);
            }
        });

        typeLabel.setFont(new java.awt.Font("Lucida Grande", 1, 13));
        typeLabel.setText("Type:");

        inputType.setText("type");

        valueLabel.setFont(new java.awt.Font("Lucida Grande", 1, 13));
        valueLabel.setText("Value:");

        inputValue.setText("value");
        inputValue.setMinimumSize(new java.awt.Dimension(50, 28));
        inputValue.setPreferredSize(new java.awt.Dimension(50, 28));
        inputValue.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                inputValueActionPerformed(evt);
            }
        });
        inputValue.addFocusListener(new java.awt.event.FocusAdapter() {
            public void focusLost(java.awt.event.FocusEvent evt) {
                inputValueFocusLost(evt);
            }
        });

        minLabel.setFont(new java.awt.Font("Lucida Grande", 1, 13));
        minLabel.setText("Min:");

        inputMinValue.setEditable(false);
        inputMinValue.setText("min");
        inputMinValue.setMinimumSize(new java.awt.Dimension(40, 28));
        inputMinValue.setPreferredSize(new java.awt.Dimension(40, 28));

        maxLabel.setFont(new java.awt.Font("Lucida Grande", 1, 13));
        maxLabel.setText("Max:");

        inputMaxValue.setEditable(false);
        inputMaxValue.setText("max");
        inputMaxValue.setMinimumSize(new java.awt.Dimension(40, 28));
        inputMaxValue.setPreferredSize(new java.awt.Dimension(40, 28));
        inputMaxValue.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                inputMaxValueActionPerformed(evt);
            }
        });

        inputAutosampling.setFont(new java.awt.Font("Lucida Grande", 1, 13));
        inputAutosampling.setText("Autosampling");

        resetAllValue.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/reset_icon.gif"))); // NOI18N
        resetAllValue.setToolTipText("Set all value to default");
        resetAllValue.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                resetAllValueActionPerformed(evt);
            }
        });

        org.jdesktop.layout.GroupLayout layout = new org.jdesktop.layout.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(org.jdesktop.layout.GroupLayout.TRAILING, layout.createSequentialGroup()
                .add(inputName, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 126, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(typeLabel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 44, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(inputType, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 74, Short.MAX_VALUE)
                .add(18, 18, 18)
                .add(valueLabel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 48, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(inputValue, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 71, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(minLabel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 38, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(inputMinValue, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 47, Short.MAX_VALUE)
                .add(18, 18, 18)
                .add(maxLabel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 40, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(inputMaxValue, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 45, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(inputAutosampling, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 134, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(resetAllValue, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 48, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.CENTER)
                .add(inputName)
                .add(maxLabel)
                .add(typeLabel)
                .add(inputValue, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .add(inputAutosampling)
                .add(inputMinValue, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .add(inputMaxValue, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .add(valueLabel)
                .add(minLabel)
                .add(inputType)
                .add(resetAllValue))
        );
    }// </editor-fold>//GEN-END:initComponents

    private void inputValueActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_inputValueActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_inputValueActionPerformed

    private void inputNameActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_inputNameActionPerformed
        this.inputType.setEnabled(this.inputName.isSelected());
        this.inputValue.setEnabled(this.inputName.isSelected());
        this.inputMinValue.setEnabled(this.inputName.isSelected());
        this.inputMaxValue.setEnabled(this.inputName.isSelected());
        this.inputAutosampling.setEnabled(this.inputName.isSelected());
        this.typeLabel.setEnabled(this.inputName.isSelected());
        this.valueLabel.setEnabled(this.inputName.isSelected());
        this.minLabel.setEnabled(this.inputName.isSelected());
        this.maxLabel.setEnabled(this.inputName.isSelected());
        this.resetAllValue.setEnabled(this.inputName.isSelected());
    }//GEN-LAST:event_inputNameActionPerformed

    private void resetAllValueActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_resetAllValueActionPerformed
        this.setValues();
    }//GEN-LAST:event_resetAllValueActionPerformed

    private void inputMaxValueActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_inputMaxValueActionPerformed
        
    }//GEN-LAST:event_inputMaxValueActionPerformed

    private void inputValueFocusLost(java.awt.event.FocusEvent evt) {//GEN-FIRST:event_inputValueFocusLost
        String strValue = this.inputValue.getText();
        if (Util.isDouble(strValue)){
            double dblValue = Double.valueOf(strValue);
            double dblMin = Double.valueOf(this.inputMinValue.getText());
            double dblMax = Double.valueOf(this.inputMaxValue.getText());
            if (!Util.outOfRange(dblValue, dblMin, dblMax)){
                String msg = "Input value is out of range!";
                JOptionPane.showMessageDialog(new JFrame(), msg, "Error", JOptionPane.OK_OPTION);

                this.inputValue.setText("n/a");
                this.inputValue.requestFocus();
            }
        }
        else{
            if (!strValue.equals("n/a")){
                String msg = "Input value not a double!";
                JOptionPane.showMessageDialog(new JFrame(), msg, "Error", JOptionPane.OK_OPTION);
                
                this.inputValue.setText("n/a");
                this.inputValue.requestFocus();
            }
        }
    }//GEN-LAST:event_inputValueFocusLost

    /**
     *
     * @return
     */
    public String getInputName(){
        return this.inputName.getText();
    }

    /**
     *
     * @return
     */
    public String getInputType() {
        return this.inputType.getText();
    }

    /**
     *
     * @return
     */
    public String getInputValue() {
        if (this.inputValue.getText().equals("n/a"))
            return "0";
        else
            return this.inputValue.getText();
    }

    /**
     *
     * @return
     */
    public String getInputMin() {
        return this.inputMinValue.getText();
    }

    /**
     *
     * @return
     */
    public String getInputMax() {
        return this.inputMaxValue.getText();
    }

    /**
     *
     * @return
     */
    public String getInputAutoSampling() {
        if (this.inputAutosampling.isSelected())
            return "true";
        else
            return "false";
    }

    /**
     * 
     * @param b
     */
    public void setSelected(boolean b){
        this.inputName.setEnabled(b);
        this.inputType.setEnabled(b);
        this.inputValue.setEnabled(b);
        this.inputMinValue.setEnabled(b);
        this.inputMaxValue.setEnabled(b);
        this.inputAutosampling.setEnabled(b);
    }

    /**
     * 
     * @param inputParameterInfo
     */
    public void setParameterInfo(InputParameterInfo inputParameterInfo) {
        this.inputValue.setText(inputParameterInfo.getValue());
        this.inputMinValue.setText(inputParameterInfo.getMin());
        this.inputMaxValue.setText(inputParameterInfo.getMax());
        if (inputParameterInfo.getAutosampling().equals("true"))
            this.inputAutosampling.setSelected(true);
        else
            this.inputAutosampling.setSelected(false);
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JCheckBox inputAutosampling;
    private javax.swing.JTextField inputMaxValue;
    private javax.swing.JTextField inputMinValue;
    private javax.swing.JCheckBox inputName;
    private javax.swing.JLabel inputType;
    private javax.swing.JTextField inputValue;
    private javax.swing.JLabel maxLabel;
    private javax.swing.JLabel minLabel;
    private javax.swing.JButton resetAllValue;
    private javax.swing.JLabel typeLabel;
    private javax.swing.JLabel valueLabel;
    // End of variables declaration//GEN-END:variables


}
