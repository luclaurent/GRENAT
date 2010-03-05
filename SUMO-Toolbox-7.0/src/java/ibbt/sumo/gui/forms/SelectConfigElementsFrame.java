/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * SelectConfigElementsFrame.java
 *
 * Created on Jul 23, 2009, 12:39:56 PM
 */

package ibbt.sumo.gui.forms;

import ibbt.sumo.gui.context.ConfigXMLFile;
import ibbt.sumo.gui.context.DefaultXMLFile;
import ibbt.sumo.gui.context.RunElement;
import ibbt.sumo.gui.context.SimulatorXMLFile;

/**
 *
 * @author Sasa Berberovic
 */
public class SelectConfigElementsFrame extends javax.swing.JDialog {
    private ConfigElementPanel levelplot;
    private ConfigElementPanel contextconfig;
    private ConfigElementPanel sumo;
    private ConfigElementPanel adaptivemodelbuilder;
    private ConfigElementPanel initialdesign;
    private ConfigElementPanel sampleselector;
    private ConfigElementPanel sampleevaluator;

    private RunElement run;

    /** Creates new form SelectConfigElementsFrame */
    public SelectConfigElementsFrame(DefaultXMLFile defXML, SimulatorXMLFile simXML, RunElementPanel run) {
        this.run = run.getRunElement();

        initComponents();
        initConfigElementPanel(defXML, simXML, run);
    }

    public void initConfigElementPanel(DefaultXMLFile df, SimulatorXMLFile sim, RunElementPanel run) {
        if (df instanceof ConfigXMLFile){
            ConfigXMLFile config = (ConfigXMLFile) df;
            System.out.print(run.getRunElement().getElement().asXML());
            this.levelplot = new ConfigElementPanel("LevelPlot", config, null, run);
            this.levelplot.setSelected(false);
            this.levelplot.setSelectAll(this.selectAll);
            this.contextconfig = new ConfigElementPanel("ContextConfig", config, null, run);
            this.contextconfig.setSelected(false);
            this.contextconfig.setSelectAll(this.selectAll);
            this.sumo = new ConfigElementPanel("SUMO", config, null, run);
            this.sumo.setSelected(false);
            this.sumo.setSelectAll(this.selectAll);
            this.adaptivemodelbuilder = new ConfigElementPanel("AdaptiveModelBuilder", config, null, run);
            this.adaptivemodelbuilder.setSelected(false);
            this.adaptivemodelbuilder.setSelectAll(this.selectAll);
            this.initialdesign = new ConfigElementPanel("InitialDesign", config, null, run);
            this.initialdesign.setSelected(false);
            this.initialdesign.setSelectAll(this.selectAll);
            this.sampleselector = new ConfigElementPanel("SampleSelector", config, null, run);
            this.sampleselector.setSelected(false);
            this.sampleselector.setSelectAll(this.selectAll);
            this.sampleevaluator = new ConfigElementPanel("SampleEvaluator", config, config.getSimXMLFile(), run);
            this.sampleevaluator.setSelected(false);
            this.sampleevaluator.setSelectAll(this.selectAll);
        }
        else{
            this.levelplot = new ConfigElementPanel("LevelPlot", df, null, run);
            this.levelplot.setSelected(false);
            this.levelplot.setSelectAll(this.selectAll);
            this.contextconfig = new ConfigElementPanel("ContextConfig", df, null, run);
            this.contextconfig.setSelected(false);
            this.contextconfig.setSelectAll(this.selectAll);
            this.sumo = new ConfigElementPanel("SUMO", df, null, run);
            this.sumo.setSelected(false);
            this.sumo.setSelectAll(this.selectAll);
            this.adaptivemodelbuilder = new ConfigElementPanel("AdaptiveModelBuilder", df, null, run);
            this.adaptivemodelbuilder.setSelected(false);
            this.adaptivemodelbuilder.setSelectAll(this.selectAll);
            this.initialdesign = new ConfigElementPanel("InitialDesign", df, null, run);
            this.initialdesign.setSelected(false);
            this.initialdesign.setSelectAll(this.selectAll);
            this.sampleselector = new ConfigElementPanel("SampleSelector", df, null, run);
            this.sampleselector.setSelected(false);
            this.sampleselector.setSelectAll(this.selectAll);
            this.sampleevaluator = new ConfigElementPanel("SampleEvaluator", df, sim, run);
            this.sampleevaluator.setSelected(false);
            this.sampleevaluator.setSelectAll(this.selectAll);
        }


        for (int i = 0; i < this.run.nrOfElements(); i++){
            if (this.run.getConfigElement(i).getName().equals("LevelPlot")){
                this.levelplot.setSelected(true);
                this.levelplot.setID(this.run.getConfigElement(i).getId());
            }
            else if (this.run.getConfigElement(i).getName().equals("ContextConfig")){
                this.contextconfig.setSelected(true);
                this.contextconfig.setID(this.run.getConfigElement(i).getId());
            }
            else if (this.run.getConfigElement(i).getName().equals("SUMO")){
                this.sumo.setSelected(true);
                this.sumo.setID(this.run.getConfigElement(i).getId());
            }
            else if (this.run.getConfigElement(i).getName().equals("AdaptiveModelBuilder")){
                this.adaptivemodelbuilder.setSelected(true);
                this.adaptivemodelbuilder.setID(this.run.getConfigElement(i).getId());
            }
            else if (this.run.getConfigElement(i).getName().equals("InitialDesign")){
                this.initialdesign.setSelected(true);
                this.initialdesign.setID(this.run.getConfigElement(i).getId());
            }
            else if (this.run.getConfigElement(i).getName().equals("SampleSelector")){
                this.sampleselector.setSelected(true);
                this.sampleselector.setID(this.run.getConfigElement(i).getId());
            }
            else if (this.run.getConfigElement(i).getName().equals("SampleEvaluator")){
                this.sampleevaluator.setSelected(true);
                this.sampleevaluator.setID(this.run.getConfigElement(i).getId());
            }
        }
        
        this.configElements.add(this.levelplot);
        this.configElements.add(this.contextconfig);
        this.configElements.add(this.sumo);
        this.configElements.add(this.adaptivemodelbuilder);
        this.configElements.add(this.initialdesign);
        this.configElements.add(this.sampleselector);
        this.configElements.add(this.sampleevaluator);

        for (int i = 0; i < this.run.nrOfMeasures(); i++){
            MeasureElementPanel m = new MeasureElementPanel(this.configElements);
            if (this.run.getMeasure(i).getType() != null)
                m.setMeasureType(this.run.getMeasure(i).getType());
            if (this.run.getMeasure(i).getTarget() != null)
                m.setMeasureTarget(this.run.getMeasure(i).getTarget());
            if (this.run.getMeasure(i).getErrFunction() != null)
                m.setMeasureErrFunction(this.run.getMeasure(i).getErrFunction());
            if (this.run.getMeasure(i).getUse() != null)
                m.setMeasureUse(this.run.getMeasure(i).getUse());
            m.setSelected(true);
            this.configElements.add(m);
        }
       
        this.repaint();
    }

    public boolean allSelected(){
        return this.levelplot.isSelected()
                && this.contextconfig.isSelected()
                && this.sumo.isSelected()
                && this.adaptivemodelbuilder.isSelected()
                && this.initialdesign.isSelected()
                && this.sampleselector.isSelected()
                && this.sampleevaluator.isSelected();
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        descriptionLabel = new javax.swing.JLabel();
        selectAll = new javax.swing.JCheckBox();
        addMeasure = new javax.swing.JButton();
        buttonPanel = new javax.swing.JPanel();
        okButton = new javax.swing.JButton();
        cancelButton = new javax.swing.JButton();
        jScrollPane1 = new javax.swing.JScrollPane();
        configElements = new javax.swing.JPanel();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);

        descriptionLabel.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/sumo1.png"))); // NOI18N
        descriptionLabel.setText("Select the configuration elements for the run.");

        selectAll.setText("Select all");
        selectAll.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                selectAllActionPerformed(evt);
            }
        });

        addMeasure.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/add_icon.png"))); // NOI18N
        addMeasure.setText("Add measure ...");
        addMeasure.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                addMeasureActionPerformed(evt);
            }
        });

        okButton.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/ok_icon.gif"))); // NOI18N
        okButton.setText("OK");
        okButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                okButtonActionPerformed(evt);
            }
        });
        buttonPanel.add(okButton);

        cancelButton.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/cancel_icon.gif"))); // NOI18N
        cancelButton.setText("Cancel");
        cancelButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                cancelButtonActionPerformed(evt);
            }
        });
        buttonPanel.add(cancelButton);

        jScrollPane1.setBackground(new java.awt.Color(238, 238, 238));
        jScrollPane1.setBorder(javax.swing.BorderFactory.createTitledBorder("Configuration elements"));

        configElements.setLayout(new javax.swing.BoxLayout(configElements, javax.swing.BoxLayout.Y_AXIS));
        jScrollPane1.setViewportView(configElements);

        org.jdesktop.layout.GroupLayout layout = new org.jdesktop.layout.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createSequentialGroup()
                .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
                    .add(org.jdesktop.layout.GroupLayout.TRAILING, layout.createSequentialGroup()
                        .addContainerGap()
                        .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
                            .add(jScrollPane1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 759, Short.MAX_VALUE)
                            .add(descriptionLabel)
                            .add(selectAll)
                            .add(addMeasure)))
                    .add(org.jdesktop.layout.GroupLayout.TRAILING, layout.createSequentialGroup()
                        .add(23, 23, 23)
                        .add(buttonPanel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 756, Short.MAX_VALUE)))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(org.jdesktop.layout.GroupLayout.TRAILING, layout.createSequentialGroup()
                .add(27, 27, 27)
                .add(descriptionLabel)
                .add(18, 18, 18)
                .add(selectAll)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(jScrollPane1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 286, Short.MAX_VALUE)
                .add(7, 7, 7)
                .add(addMeasure)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(buttonPanel, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, 38, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void cancelButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_cancelButtonActionPerformed
        this.dispose();
    }//GEN-LAST:event_cancelButtonActionPerformed

    private void selectAllActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_selectAllActionPerformed
        this.levelplot.setSelected(this.selectAll.isSelected());
        this.contextconfig.setSelected(this.selectAll.isSelected());
        this.sumo.setSelected(this.selectAll.isSelected());
        this.adaptivemodelbuilder.setSelected(this.selectAll.isSelected());
        this.initialdesign.setSelected(this.selectAll.isSelected());
        this.sampleselector.setSelected(this.selectAll.isSelected());
        this.sampleevaluator.setSelected(this.selectAll.isSelected());
    }//GEN-LAST:event_selectAllActionPerformed

    private void addMeasureActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_addMeasureActionPerformed
        MeasureElementPanel m = new MeasureElementPanel(this.configElements);
        m.setSelected(true);
        this.configElements.add(m);
        this.repaint();
        this.validate();
    }//GEN-LAST:event_addMeasureActionPerformed

    private void okButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_okButtonActionPerformed
        this.run.removeConfigAllElements();
        this.run.removeAllMeasures();
        
        for (int i = 0; i < this.configElements.getComponentCount(); i++){
            if (this.configElements.getComponent(i) instanceof ConfigElementPanel){
                ConfigElementPanel cp = (ConfigElementPanel)this.configElements.getComponent(i);
                if (cp.isSelected())
                    this.run.addElement(cp.getConfigElement());
            }
            else if (this.configElements.getComponent(i) instanceof MeasureElementPanel){
                MeasureElementPanel m = (MeasureElementPanel)this.configElements.getComponent(i);
                this.run.addMeasures(m.getMeasureElement());
            }
        }
        this.dispose();
    }//GEN-LAST:event_okButtonActionPerformed

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton addMeasure;
    private javax.swing.JPanel buttonPanel;
    private javax.swing.JButton cancelButton;
    private javax.swing.JPanel configElements;
    private javax.swing.JLabel descriptionLabel;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JButton okButton;
    private javax.swing.JCheckBox selectAll;
    // End of variables declaration//GEN-END:variables

}
