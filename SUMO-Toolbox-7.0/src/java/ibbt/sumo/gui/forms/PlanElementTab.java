/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * PlanElementPanel.java
 *
 * Created on Jul 9, 2009, 7:12:46 PM
 */

package ibbt.sumo.gui.forms;

import ibbt.sumo.gui.context.ConfigXMLFile;
import ibbt.sumo.gui.context.DefaultXMLFile;
import ibbt.sumo.gui.context.PlanElement;
import ibbt.sumo.gui.context.SimulatorXMLFile;

import javax.swing.DefaultComboBoxModel;

/**
 *
 * @author Sasa Berberovic
 */
public class PlanElementTab extends javax.swing.JPanel {
    private NewConfigFileForm parent;
    private DefaultXMLFile defXML;
    private SimulatorXMLFile simXML;

    private SimulatorElementPanel simulator;
    private ConfigElementPanel levelplot;
    private ConfigElementPanel contextconfig;
    private ConfigElementPanel sumo;
    private ConfigElementPanel adaptivemodelbuilder;
    private ConfigElementPanel initialdesign;
    private ConfigElementPanel sampleselector;
    private ConfigElementPanel sampleevaluator;
    
    /**
     *
     * @param parent
     * @param defualt
     * @param simulator
     */
    public PlanElementTab(NewConfigFileForm parent, DefaultXMLFile defualt, SimulatorXMLFile simulator) {
        this.parent = parent;
        this.defXML = defualt;
        this.simXML = simulator;
        initComponents();
        initPlanElementPanel();

        this.setName("Plan");
    }


    /**
     * 
     * @param parent
     * @param config
     */
    public PlanElementTab(NewConfigFileForm parent, ConfigXMLFile config){
        this.parent = parent;
        this.defXML = config;
        this.simXML = config.getSimXMLFile();
        initComponents();
        initPlanElementPanelFromConfig();

        this.setName("Plan");
    }

    /**
     *
     */
    public void initPlanElementPanelFromConfig() {
        this.planElement.setName("Plan");
        this.setName("Plan");;
        
        ConfigXMLFile confXML = (ConfigXMLFile) this.defXML;
//        confXML.print();
        this.simulator = new SimulatorElementPanel();
        this.simulator.setPath(this.simXML.filepath());
        this.simulator.setName(this.simXML.filename());

        // Setting levelplot element panel
        if (confXML.getPlanElement().element("LevelPlot") != null){
            this.levelplot = new ConfigElementPanel("LevelPlot", confXML, this);
            this.levelplot.setSelected(true);
        }
        else{
            this.levelplot = new ConfigElementPanel("LevelPlot", this.defXML, this.simXML, this);
            this.levelplot.setSelected(false);
        }
        this.levelplot.setSelectAll(this.selectAll);

        // Setting contextconfig element panel
        if (confXML.getPlanElement().element("ContextConfig") != null){
            this.contextconfig = new ConfigElementPanel("ContextConfig", confXML, this);
            this.contextconfig.setSelected(true);
        }
        else{
            this.contextconfig = new ConfigElementPanel("ContextConfig", this.defXML, this.simXML, this);
            this.contextconfig.setSelected(false);
        }
        this.contextconfig.setSelectAll(this.selectAll);

        // Setting sumo element panel
        if (confXML.getPlanElement().element("SUMO") != null){
            this.sumo = new ConfigElementPanel("SUMO", confXML, this);
            this.sumo.setSelected(true);
        }
        else{
            this.sumo = new ConfigElementPanel("SUMO", this.defXML, this.simXML, this);
            this.sumo.setSelected(false);
        }
        this.sumo.setSelectAll(this.selectAll);

        // Setting adaptivemodelbuilder element panel
        if (confXML.getPlanElement().element("AdaptiveModelBuilder") != null){
            this.adaptivemodelbuilder = new ConfigElementPanel("AdaptiveModelBuilder", confXML, this);
            this.adaptivemodelbuilder.setSelected(true);
        }
        else{
            this.adaptivemodelbuilder = new ConfigElementPanel("AdaptiveModelBuilder", this.defXML, this.simXML, this);
            this.adaptivemodelbuilder.setSelected(false);
        }
        this.adaptivemodelbuilder.setSelectAll(this.selectAll);

        // Setting initialdesign element panel
        if (confXML.getPlanElement().element("InitialDesign") != null){
            this.initialdesign = new ConfigElementPanel("InitialDesign", confXML, this);
            this.initialdesign.setSelected(true);
        }
        else{
            this.initialdesign = new ConfigElementPanel("InitialDesign", this.defXML, this.simXML, this);
            this.initialdesign.setSelected(false);
        }
        this.initialdesign.setSelectAll(this.selectAll);

        // Setting sampleselector element panel
        if (confXML.getPlanElement().element("SampleSelector") != null){
            this.sampleselector = new ConfigElementPanel("SampleSelector", confXML, this);
            this.sampleselector.setSelected(true);
        }
        else{
            this.sampleselector = new ConfigElementPanel("SampleSelector", this.defXML, this.simXML, this);
            this.sampleselector.setSelected(false);
        }
        this.sampleselector.setSelectAll(this.selectAll);

        // Setting sampleevaluator element panel
        if (confXML.getPlanElement().element("SampleEvaluator") != null){
            this.sampleevaluator = new ConfigElementPanel("SampleEvaluator", confXML, this);
            this.sampleevaluator.setSelected(true);
        }
        else{
            this.sampleevaluator = new ConfigElementPanel("SampleEvaluator", this.defXML, this.simXML, this);
            this.sampleevaluator.setSelected(false);
        }
        this.sampleevaluator.setSelectAll(this.selectAll);

        this.planElement.add(this.simulator);
        this.planElement.add(this.levelplot);
        this.planElement.add(this.contextconfig);
        this.planElement.add(this.sumo);
        this.planElement.add(this.adaptivemodelbuilder);
        this.planElement.add(this.initialdesign);
        this.planElement.add(this.sampleselector);
        this.planElement.add(this.sampleevaluator);

        for (int i = 0; i < confXML.getMeasureElements().size(); i++){
            MeasureElementPanel mp = new MeasureElementPanel(this.planElement, confXML.getMeasureElements().get(i));
            mp.setSelected(true);
            this.planElement.add(mp);
        }
        this.parent.repaint();
    }


    /**
     *
     */
    public void initPlanElementPanel() {
        this.planElement.setName("Plan");
        this.setName("Plan");
        
        this.simulator = new SimulatorElementPanel();
        this.simulator.setPath(this.simXML.filepath());
        this.simulator.setName(this.simXML.filename());

        this.levelplot = new ConfigElementPanel("LevelPlot", this.defXML, null, this);
        this.levelplot.setSelectAll(this.selectAll);
        this.contextconfig = new ConfigElementPanel("ContextConfig", this.defXML, null, this);
        this.contextconfig.setSelectAll(this.selectAll);
        this.sumo = new ConfigElementPanel("SUMO", this.defXML, null, this);
        this.sumo.setSelectAll(this.selectAll);
        this.adaptivemodelbuilder = new ConfigElementPanel("AdaptiveModelBuilder", this.defXML, null, this);
        this.adaptivemodelbuilder.setSelectAll(this.selectAll);
        this.initialdesign = new ConfigElementPanel("InitialDesign", this.defXML, null, this);
        this.initialdesign.setSelectAll(this.selectAll);
        this.sampleselector = new ConfigElementPanel("SampleSelector", this.defXML, null, this);
        this.sampleselector.setSelectAll(this.selectAll);
        this.sampleevaluator = new ConfigElementPanel("SampleEvaluator", this.defXML, this.simXML, this);
        this.sampleevaluator.setSelectAll(this.selectAll);
                
        this.planElement.add(this.simulator);
        this.planElement.add(this.levelplot);
        this.planElement.add(this.contextconfig);
        this.planElement.add(this.sumo);
        this.planElement.add(this.adaptivemodelbuilder);
        this.planElement.add(this.initialdesign);
        this.planElement.add(this.sampleselector);
        this.planElement.add(this.sampleevaluator);

        for (int i = 0; i < this.defXML.getMeasureElements().size(); i++){
            MeasureElementPanel mp = new MeasureElementPanel(this.planElement, this.defXML.getMeasureElements().get(i));
            mp.setSelected(true);
            this.planElement.add(mp);
        }
        this.parent.repaint();
    }

    /**
     *
     * @param path
     */
    public void setSimulatorPath(String path){
        this.simulator.setPath(path);
    }

    /**
     *
     * @param model
     */
    public void setSampleEvaluator(DefaultComboBoxModel model){
        this.sampleevaluator.setModel(model);
    }

    public PlanElement getPlanElement(){
        PlanElement plan = new PlanElement();
        for (int i = 0; i < this.planElement.getComponentCount(); i++){
            if (this.planElement.getComponent(i) instanceof SimulatorElementPanel){
                SimulatorElementPanel sp= (SimulatorElementPanel) this.planElement.getComponent(i);
                plan.addSimulatorElement(sp.getSimulatorName(), sp.getSimulatorPath());
            }
            else if (this.planElement.getComponent(i) instanceof ConfigElementPanel){
                ConfigElementPanel cp = (ConfigElementPanel)this.planElement.getComponent(i);
                if (cp.isSelected() && cp.getConfigElement() != null)
                    plan.addConfigElement(cp.getConfigElement());
            }
            else if (this.planElement.getComponent(i) instanceof MeasureElementPanel){
                MeasureElementPanel mp = (MeasureElementPanel)this.planElement.getComponent(i);

                plan.addMeasureElement(mp.getMeasureElement());
            }
        }
        return plan;
    }


    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        descrPanel = new javax.swing.JLabel();
        jScrollPane1 = new javax.swing.JScrollPane();
        planElement = new javax.swing.JPanel();
        addMeasure = new javax.swing.JButton();
        selectAll = new javax.swing.JCheckBox();

        setPreferredSize(new java.awt.Dimension(869, 460));

        descrPanel.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/sumo1.png"))); // NOI18N
        descrPanel.setText("Select the plan elements you need in the configuration files.");

        jScrollPane1.setBorder(null);

        planElement.setBorder(javax.swing.BorderFactory.createTitledBorder("Plan"));
        planElement.setLayout(new javax.swing.BoxLayout(planElement, javax.swing.BoxLayout.PAGE_AXIS));
        jScrollPane1.setViewportView(planElement);

        addMeasure.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/add_icon.png"))); // NOI18N
        addMeasure.setText("Add measure ...");
        addMeasure.setToolTipText("Add a new measure element.");
        addMeasure.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                addMeasureActionPerformed(evt);
            }
        });

        selectAll.setSelected(true);
        selectAll.setText("Select all");
        selectAll.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                selectAllActionPerformed(evt);
            }
        });

        org.jdesktop.layout.GroupLayout layout = new org.jdesktop.layout.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createSequentialGroup()
                .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
                    .add(layout.createSequentialGroup()
                        .add(20, 20, 20)
                        .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
                            .add(addMeasure)
                            .add(jScrollPane1, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, 831, Short.MAX_VALUE)))
                    .add(org.jdesktop.layout.GroupLayout.TRAILING, layout.createSequentialGroup()
                        .addContainerGap()
                        .add(descrPanel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 831, Short.MAX_VALUE))
                    .add(layout.createSequentialGroup()
                        .addContainerGap()
                        .add(selectAll)))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createSequentialGroup()
                .addContainerGap()
                .add(descrPanel)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.UNRELATED)
                .add(selectAll)
                .add(3, 3, 3)
                .add(jScrollPane1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 346, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.UNRELATED)
                .add(addMeasure)
                .addContainerGap())
        );
    }// </editor-fold>//GEN-END:initComponents

    /**
     * 
     * @param evt
     */
    private void addMeasureActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_addMeasureActionPerformed
        MeasureElementPanel m = new MeasureElementPanel(this.planElement);
        m.setSelected(true);
        
        this.planElement.add(m);
        this.parent.repaint();
    }//GEN-LAST:event_addMeasureActionPerformed

    private void selectAllActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_selectAllActionPerformed
        this.levelplot.setSelected(this.selectAll.isSelected());
        this.contextconfig.setSelected(this.selectAll.isSelected());
        this.sumo.setSelected(this.selectAll.isSelected());
        this.adaptivemodelbuilder.setSelected(this.selectAll.isSelected());
        this.initialdesign.setSelected(this.selectAll.isSelected());
        this.sampleselector.setSelected(this.selectAll.isSelected());
        this.sampleevaluator.setSelected(this.selectAll.isSelected());

        for (int i = 0; i < this.planElement.getComponentCount(); i++){
            if (this.planElement.getComponent(i) instanceof MeasureElementPanel){
                MeasureElementPanel mp = (MeasureElementPanel) this.planElement.getComponent(i);
                mp.setSelected(this.selectAll.isSelected());
            }
        }
    }//GEN-LAST:event_selectAllActionPerformed

    /**
     *
     * @param m
     */
    public void removeMeasureElement(MeasureElementPanel m){
        this.planElement.remove(m);
        this.parent.repaint();
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton addMeasure;
    private javax.swing.JLabel descrPanel;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JPanel planElement;
    private javax.swing.JCheckBox selectAll;
    // End of variables declaration//GEN-END:variables


}
