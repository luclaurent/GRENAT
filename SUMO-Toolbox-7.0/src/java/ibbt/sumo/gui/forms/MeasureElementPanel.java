/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * MeasureElementPanel.java
 *
 * Created on Jul 22, 2009, 4:52:25 PM
 */

package ibbt.sumo.gui.forms;

import ibbt.sumo.gui.context.MeasureElement;

import javax.swing.JPanel;

/**
 * Panel that show information stored in MeasureElement 
 *
 * @author Sasa Berberovic
 */
public class MeasureElementPanel extends javax.swing.JPanel {
    private JPanel parent;
    private MeasureElement measureElement;
      
    /** Creates new form MeasureElementPanel */
    public MeasureElementPanel(JPanel p) {
        initComponents();
        this.parent = p;
        this.measureElement = new MeasureElement();
        this.use.setSelected(true);
    }

    /**
     *
     * @param p
     * @param m
     */
    public MeasureElementPanel(JPanel p, MeasureElement m){
        initComponents();
        this.parent = p;
        this.measureElement = m;
        initMeasureElementPanel();
    }

    /**
     * 
     */
    public void initMeasureElementPanel() {
        this.measureType.setSelectedItem(this.measureElement.getType());
        this.measureTarget.setText(this.measureElement.getTarget());
        this.measureErrorFunction.setSelectedItem(this.measureElement.getErrFunction());
        this.use.setSelected(Boolean.parseBoolean(this.measureElement.getUse()));
    }

    /**
     * Getter for measure element
     * 
     * @return
     */
    public MeasureElement getMeasureElement(){
        this.measureElement.setType(this.measureType.getSelectedItem().toString());
        this.measureElement.setTarget(this.measureTarget.getText());
        this.measureElement.setErrFunction(this.measureErrorFunction.getSelectedItem().toString());
        this.measureElement.setUse(String.valueOf(this.use.isSelected()));

        return this.measureElement;
    }

    /**
     * Setter for maesure element
     *
     * @param m
     */
    public void setMeasureElement(MeasureElement m){
        this.measureType.setSelectedItem(m.getType());
        this.measureTarget.setText(m.getTarget());
        this.measureErrorFunction.setSelectedItem(m.getErrFunction());
        this.use.setSelected(Boolean.parseBoolean(m.getUse()));
    }

    /**
     *
     * @param type
     */
    public void setMeasureType(String type) {
        this.measureType.setSelectedItem(type);
    }

    /**
     *
     * @param target
     */
    public void setMeasureTarget(String target) {
        this.measureTarget.setText(target);
    }

    /**
     *
     * @param errFunction
     */
    public void setMeasureErrFunction(String errFunction) {
        this.measureErrorFunction.setSelectedItem(errFunction);
    }

    /**
     *
     * @param use
     */
    public void setMeasureUse(String use){
        if (use.equals("true"))
            this.use.setSelected(true);
        else
            this.use.setSelected(false);

    }

    public void setSelected(boolean selected) {
        this.measure.setEnabled(selected);;
        this.measureType.setEnabled(selected);
        this.targetLabel.setEnabled(selected);
        this.measureTarget.setEnabled(selected);
        this.measureErrorFunction.setEnabled(selected);
        this.use.setEnabled(selected);
        this.removeMeasure.setEnabled(selected);
        this.optionsButton.setEnabled(selected);
    }

   /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        measureType = new javax.swing.JComboBox();
        measureTarget = new javax.swing.JTextField();
        measureErrorFunction = new javax.swing.JComboBox();
        removeMeasure = new javax.swing.JButton();
        optionsButton = new javax.swing.JButton();
        targetLabel = new javax.swing.JLabel();
        use = new javax.swing.JCheckBox();
        measure = new javax.swing.JLabel();

        setPreferredSize(new java.awt.Dimension(770, 29));

        measureType.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "AIC", "CrossValidation", "LeaveOneOut", "LRMMeasure", "MinMax", "ModelDifference", "SampleError", "TestMinimum", "ValidationSet" }));
        measureType.setToolTipText("Measure type");
        measureType.setSelectedItem("CrossValidation");

        measureTarget.setText("0.01");
        measureTarget.setToolTipText("Measure target");

        measureErrorFunction.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "averageEuclideanError", "beeq", "maxAbsoluteError", "maxCombinedRelativeError", "maxGenericRelativeError", "maxRelativeError", "meanAbsoluteError", "meanCombinedRelativeError", "meanRelativeError", "meanSquareError", "rootMeanSquareError", "rootRelativeSquareError"}));
        measureErrorFunction.setToolTipText("Error function");
        measureErrorFunction.setSelectedItem("beeq");

        removeMeasure.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/delete_icon.gif"))); // NOI18N
        removeMeasure.setToolTipText("Remove this measure element.");
        removeMeasure.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                removeMeasureActionPerformed(evt);
            }
        });

        optionsButton.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/options_icon.png"))); // NOI18N
        optionsButton.setText("Options");
        optionsButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                optionsButtonActionPerformed(evt);
            }
        });

        targetLabel.setText("target:");

        use.setText("use");
        use.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                useActionPerformed(evt);
            }
        });

        measure.setFont(new java.awt.Font("Lucida Grande", 1, 13));
        measure.setText("Measure:");

        org.jdesktop.layout.GroupLayout layout = new org.jdesktop.layout.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createSequentialGroup()
                .addContainerGap()
                .add(removeMeasure)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.UNRELATED)
                .add(measure)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.UNRELATED)
                .add(measureType, 0, 138, Short.MAX_VALUE)
                .add(18, 18, 18)
                .add(targetLabel)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(measureTarget, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 68, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(measureErrorFunction, 0, 168, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.UNRELATED)
                .add(use)
                .add(45, 45, 45)
                .add(optionsButton, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, 94, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.CENTER)
                .add(optionsButton)
                .add(measureErrorFunction, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .add(use)
                .add(measureTarget, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .add(targetLabel)
                .add(removeMeasure)
                .add(measure)
                .add(measureType, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE))
        );
    }// </editor-fold>//GEN-END:initComponents

    /**
     *
     * @param evt
     */
    private void removeMeasureActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_removeMeasureActionPerformed
        this.parent.remove(this);
        this.parent.repaint();
        this.parent.validate();
    }//GEN-LAST:event_removeMeasureActionPerformed

    /**
     *
     * @param evt
     */
    private void optionsButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_optionsButtonActionPerformed
        OptionsFrameV2 op = new OptionsFrameV2(this, this.parent.getName());
        op.setModal(true);
        op.setVisible(true);
        op.pack();
    }//GEN-LAST:event_optionsButtonActionPerformed

    private void useActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_useActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_useActionPerformed


    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JLabel measure;
    private javax.swing.JComboBox measureErrorFunction;
    private javax.swing.JTextField measureTarget;
    private javax.swing.JComboBox measureType;
    private javax.swing.JButton optionsButton;
    private javax.swing.JButton removeMeasure;
    private javax.swing.JLabel targetLabel;
    private javax.swing.JCheckBox use;
    // End of variables declaration//GEN-END:variables

}
