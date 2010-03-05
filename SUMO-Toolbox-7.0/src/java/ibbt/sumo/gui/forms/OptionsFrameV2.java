/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * OptionsFrameV2.java
 *
 * Created on Aug 7, 2009, 11:56:02 AM
 */

package ibbt.sumo.gui.forms;

import ibbt.sumo.gui.context.ConfigXMLFile;
import ibbt.sumo.gui.context.DefaultXMLFile;
import ibbt.sumo.gui.context.MeasureElement;

import org.dom4j.Element;

/**
 * This is dialog that shows all the options available of
 *
 * @author Sasa Berberovic
 */
public class OptionsFrameV2 extends javax.swing.JDialog {
    private Element configElement;
    private Element original;
    private DefaultXMLFile defaultXML;
    private ConfigElementPanel configElementPanel;
    private String parentName;
    private ConfigXMLFile configXML;
    private MeasureElement measureElement;
    private MeasureElementPanel measureElementPanel;

    /** Creates new form OptionsFrameV2 */
    public OptionsFrameV2() {
        initComponents();
    }

    /**
     * Creates an OptionsFrameV2 that shows the information selected in the
     * ConfigElementPanel
     *
     *
     * @param cp        needed so the changes made in e could be updated
     * @param e         configuration element with options
     * @param confXML   if changes are made, a new element has to be added tot the DefaultXMLFile
     * @param parentName name of the parent panel or frame
     */
    public OptionsFrameV2(ConfigElementPanel cp, Element e, DefaultXMLFile def, String parentName){
        this.configElementPanel = cp;
        this.configElement = (Element) e.clone();
        this.original = (Element) e.clone();
        this.defaultXML = def;
        this.parentName = parentName;
        
        this.renameConfigElement();

        initComponents();
        initContentPanel();

    }

    /**
     * Creates an OptionsFrameV2 that shows the information selected in the
     * ConfigElementPanel
     *
     * @param cp        needed so the changes made in e could be updated
     * @param e         configuration element with options
     * @param confXML   if changes are made, a new element has to be added tot the ConfigXMLFile
     * @param parentName name of the parent panel or frame
     */
    public OptionsFrameV2(ConfigElementPanel cp, Element e, ConfigXMLFile confXML, String parentName) {
        this.configElementPanel = cp;
        this.configElement = (Element) e.clone();
        this.original = (Element) e.clone();
        this.configXML = confXML;
        this.parentName = parentName;

        this.renameConfigElement();


        initComponents();
        initContentPanel();
    }

    /**
     * Create an options frame that shows the options of a MeasureElement
     *
     * @param mp            MeasureElementPanel containing the measure element
     * @param parentName    Is the name of the parent
     */
    public OptionsFrameV2(MeasureElementPanel mp, String parentName) {
        this.measureElementPanel = mp;
        this.measureElement = mp.getMeasureElement();
        this.configElement = mp.getMeasureElement().getMeasureElement();
        this.original = mp.getMeasureElement().getMeasureElement();
        this.parentName = parentName;

        initComponents();
        initContentPanel();
    }

    private void renameConfigElement(){
        if (!this.configElement.getName().equals("Measure")){
            String customId = "";
            String id = this.configElement.attributeValue("id");            
            if (id.contains(this.parentName)){
                int index = Integer.parseInt(id.substring(id.lastIndexOf("_") + 1));
                customId = id.replace("_" + String.valueOf(index), "");
                index++;
                customId = customId.concat("_" + index);
            }
            else
                customId = id + this.parentName + "_" + "0";

            this.configElement.addAttribute("id", customId);
        }
    }

    /**
     * 
     */
    public void initContentPanel() {
        this.contentPanel.removeAll();

        if (this.configElement.getName().equals("Measure"))
            this.setTitle("Options for " + this.configElement.getName() + " (" + this.configElement.attributeValue("type") + ")");
        else
            this.setTitle("Options for " + this.configElement.getName() + " (" + this.configElement.attributeValue("id") + ")");
        this.setName(this.configElement.getName());

        ExpandablePanel test = new ExpandablePanel(this, this.configElement);
        this.contentPanel.add(test);
        test.expand();
        
        this.validate();
        this.repaint();
    }

    /**
     * Parses string that represent true of false, like on/of and yes/no
     *
     * @param str
     * @return
     */
    private Boolean parseBoolean(String str){
        if (str.equalsIgnoreCase("yes") || str.equalsIgnoreCase("on") || str.equalsIgnoreCase("true")){
            return true;
        }
        else if (str.equalsIgnoreCase("no") || str.equalsIgnoreCase("off") || str.equalsIgnoreCase("false")){
            return false;
        }
        else{
            return null;
        }
    }
    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        editButton = new javax.swing.JButton();
        titlePanel = new javax.swing.JPanel();
        layoutPanel = new javax.swing.JPanel();
        contentPanel = new javax.swing.JPanel();
        buttonPanel = new javax.swing.JPanel();
        okButton = new javax.swing.JButton();
        cancelButton = new javax.swing.JButton();

        editButton.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/edit_icon.png"))); // NOI18N
        editButton.setText("Edit");
        editButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                editButtonActionPerformed(evt);
            }
        });

        titlePanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());
        titlePanel.setLayout(new java.awt.FlowLayout(java.awt.FlowLayout.LEFT));

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        getContentPane().setLayout(new javax.swing.BoxLayout(getContentPane(), javax.swing.BoxLayout.LINE_AXIS));

        layoutPanel.setLayout(new javax.swing.BoxLayout(layoutPanel, javax.swing.BoxLayout.Y_AXIS));

        contentPanel.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED, null, java.awt.Color.gray, null, java.awt.Color.darkGray));
        contentPanel.setLayout(new javax.swing.BoxLayout(contentPanel, javax.swing.BoxLayout.Y_AXIS));
        layoutPanel.add(contentPanel);

        buttonPanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());

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

        layoutPanel.add(buttonPanel);

        getContentPane().add(layoutPanel);

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void okButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_okButtonActionPerformed
        if (!this.configElement.getName().equals("Measure")){
            Element e = ((ExpandablePanel)this.contentPanel.getComponent(0)).getElement();
            if (this.configXML != null)
                this.configXML.addNewConfigElement((Element) e.clone());
            else{
                this.defaultXML.createNewID(e);
                this.defaultXML.addNewConfigElement((Element) e.clone());
            }
            this.configElementPanel.initConfigElementPanel();
            this.configElementPanel.setID(e.attributeValue("id"));
        }
        else{
            Element e = ((ExpandablePanel)this.contentPanel.getComponent(0)).getElement();
            this.measureElement.setMeasureElement(e);
            this.measureElementPanel.setMeasureElement(this.measureElement);
        }
        this.dispose();
    }//GEN-LAST:event_okButtonActionPerformed

    private void cancelButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_cancelButtonActionPerformed
        this.configElement = (Element) this.original.clone();
        this.dispose();
    }//GEN-LAST:event_cancelButtonActionPerformed

    private void editButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_editButtonActionPerformed
        EditFrame ef = new EditFrame((ExpandablePanel) this.contentPanel.getComponent(0), this.configElement);
        ef.setModal(true);
        ef.setVisible(true);
    }//GEN-LAST:event_editButtonActionPerformed

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JPanel buttonPanel;
    private javax.swing.JButton cancelButton;
    private javax.swing.JPanel contentPanel;
    private javax.swing.JButton editButton;
    private javax.swing.JPanel layoutPanel;
    private javax.swing.JButton okButton;
    private javax.swing.JPanel titlePanel;
    // End of variables declaration//GEN-END:variables

    public void setConfigElement(Element e) {
        this.configElement = (Element) e.clone();
    }

    public Element getConfigElement(){
        return this.configElement;
    }
}
