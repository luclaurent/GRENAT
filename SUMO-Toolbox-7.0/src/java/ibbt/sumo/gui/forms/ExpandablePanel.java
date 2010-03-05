/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * Expandable.java
 *
 * Created on Aug 5, 2009, 6:10:37 PM
 */

package ibbt.sumo.gui.forms;

import ibbt.sumo.gui.util.Util;

import java.awt.Color;
import java.awt.Font;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import org.dom4j.Attribute;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

/**
 * A panel that can be collapse/expand,
 *
 * @author Sasa Berberovic
 */
public class ExpandablePanel extends javax.swing.JPanel{
    private Element configElement;
    private JPanel optionsPanel;
    private OptionsFrameV2 parent;
    private boolean show = false;

    /** Creates new form ExpandablePanel */
    public ExpandablePanel() {
        initComponents();
    }

    /**
     * Create an ExpandablePanel that will show the element options
     *
     * @param parent    OptionsFrameV2 is a container for the  ExpandablePanel
     * @param element   Information that wil be shown
     */
    public ExpandablePanel(OptionsFrameV2 parent, Element element) {
        this.parent = parent;
        this.configElement = element;
        this.setName(element.getName());

        this.optionsPanel = new JPanel();
        this.optionsPanel.setLayout(new BoxLayout(this.optionsPanel, BoxLayout.Y_AXIS));
        this.optionsPanel.setBackground(Color.DARK_GRAY);

        initComponents();
        initTitlePanel();
        initContentPanel();
    }

    public void expand(){
        this.show = true;
        this.contentPanel.add(this.optionsPanel);
        this.lblPlus.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/icon_minus.gif")));
        this.refreshPanel();
        this.validate();
    }

    public void contract(){
        this.show = false;
        this.contentPanel.remove(this.optionsPanel);
        this.lblPlus.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/plus-icon.gif")));
        this.refreshPanel();
        this.validate();
    }

    public void refreshPanel(){
        this.parent.pack();
        this.repaint();
    }

    /**
     * Init of the title panel
     */
    public void initTitlePanel() {
        this.titlePanel.removeAll();
        this.titlePanel.add(this.lblPlus);
        JLabel cname = new JLabel(this.configElement.getName() + ": ");
        cname.setFont(new Font("Lucida Grande", Font.BOLD, 13));
        this.titlePanel.add(cname);
        for (int i = 0; i < this.configElement.attributes().size(); i++){
            Attribute a = (Attribute) this.configElement.attributes().get(i);

            if (a.getValue().equals("true")
                    || a.getValue().equals("yes")
                    || a.getValue().equals("on")){
                JCheckBox combOut = new JCheckBox();
                combOut.setText(a.getName());

                combOut.setSelected(true);
                combOut.setName(a.getName());
                this.titlePanel.add(combOut);
            }
            else if (a.getValue().equals("false")
                    || a.getValue().equals("no")
                    || a.getValue().equals("off")){

                JCheckBox combOut = new JCheckBox();
                combOut.setText(a.getName());

                combOut.setSelected(false);
                combOut.setName(a.getName());
                this.titlePanel.add(combOut);
            }
            else{
                JLabel name = new JLabel(a.getName() + ": ");
                this.titlePanel.add(name);

                JTextField value = new JTextField(a.getValue());
                value.setName(a.getName());
                this.titlePanel.add(value);
            }
        }
        this.titlePanel.add(this.editButton);
    }

    /**
     * Init of the content panel
     */
    public void initContentPanel() {
        this.optionsPanel.removeAll();
        for (int i = 0; i < this.configElement.elements().size(); i++){
            Element e = (Element) this.configElement.elements().get(i);
            if (e.elements().size() > 0){
                ExpandablePanel tp = new ExpandablePanel(this.parent, e);
                tp.setName(e.getName());
                this.optionsPanel.add(tp);
            }
            else{
                JPanel p = new JPanel();
                p.setLayout(new GridLayout(1, 0, 0, 10));
                p.setBackground(Color.GRAY);
                if (e.getName().equals("Option")){
                    String descr = Util.getOptionsComment(e.attributeValue("key"), this.configElement);
                    if (descr != null)
                        p.setToolTipText(descr);
                    else
                        p.setToolTipText("No description available.");
                }
                else{
                    p.setToolTipText("No description available.");
                }

                JLabel cname = new JLabel(e.getName() + ": ");
                cname.setFont(new Font("Lucida Grande", Font.BOLD, 13));
                cname.setName(e.getName());
                p.add(cname);
                
                if (e.getName().equals("OutputDirectory")){
                    final JTextField outPath = new JTextField();
                    outPath.setText(e.getText());
                    p.add(outPath);
                    JButton open = new JButton();
                    open.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/load_icon.gif")));
                    open.setText("...");
                    open.addActionListener(new ActionListener() {
                        public void actionPerformed(ActionEvent e) {
                            JFileChooser jfc = new JFileChooser();
                            jfc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);

                            if (jfc.showOpenDialog(new JFrame()) == JFileChooser.APPROVE_OPTION)
                            {
                                outPath.setText(jfc.getSelectedFile().getPath());
                            }
                        }
                    });
                    p.add(open);
                }

                for(int j = 0; j < e.attributes().size(); j++){
                    JPanel attributePanel = new JPanel();
                    attributePanel.setLayout(new BoxLayout(attributePanel, BoxLayout.X_AXIS));
                    attributePanel.setBackground(Color.gray);

                    Attribute a = (Attribute) e.attributes().get(j);

                    JLabel name = new JLabel(a.getName() + ": ");
                    attributePanel.add(name);

                    if (a.getName().equals("key")){
                        KeyValueLabel value = new KeyValueLabel(a.getValue());
                        value.setName(a.getName());
                        attributePanel.add(value);
                    }
                    else{
                        if (a.getValue().equals("true") || a.getValue().equals("false")
                                || a.getValue().equals("on") || a.getValue().equals("off")
                                || a.getValue().equals("yes") || a.getValue().equals("no")){
                            JCheckBox value = new JCheckBox();
                            value.setText(this.parseBoolean(a.getValue()).toString());
                            value.setName(a.getName());
                            value.setSelected(this.parseBoolean(a.getValue()));
                            value.addActionListener(new ActionListener() {
                                public void actionPerformed(ActionEvent e) {
                                    JCheckBox tmp = (JCheckBox) e.getSource();
                                    if (tmp.isSelected()){
                                        tmp.setText("true");
                                    }
                                    else{
                                        tmp.setText("false");
                                    }
                                }
                            });
                            attributePanel.add(value);
                        }
                        else{
                            JTextField value = new JTextField(a.getValue());
                            value.setName(a.getName());
                            attributePanel.add(value);
                        }
                    }

                    p.add(attributePanel);
                }
                this.optionsPanel.add(p);
            }
        }
        this.parent.validate();
        this.parent.repaint();
    }

    public Element getElement(){
        Element e = DocumentHelper.createElement(this.getName());
        for (int i = 0; i < this.titlePanel.getComponentCount(); i++){
            if (this.titlePanel.getComponent(i) instanceof JTextField){
                JTextField value = (JTextField) this.titlePanel.getComponent(i);
                e.addAttribute(value.getName(), value.getText());
            }
            else if (this.titlePanel.getComponent(i) instanceof KeyValueLabel){
                KeyValueLabel keyvalue = (KeyValueLabel) this.titlePanel.getComponent(i);
                e.addAttribute(keyvalue.getName(), keyvalue.getText());
            }
            else if (this.titlePanel.getComponent(i) instanceof JCheckBox){
                JCheckBox aValue = (JCheckBox) this.titlePanel.getComponent(i);
                e.addAttribute(aValue.getName(), String.valueOf(aValue.isSelected()));
            }
        }

        for (int i = 0; i < this.optionsPanel.getComponentCount(); i++){
            if (this.optionsPanel.getComponent(i) instanceof ExpandablePanel){
                ExpandablePanel tp = (ExpandablePanel) this.optionsPanel.getComponent(i);
                e.add(tp.getElement());
            }
            else if (this.optionsPanel.getComponent(i) instanceof JPanel) {
                JPanel p = (JPanel) this.optionsPanel.getComponent(i);
                Element tmp = null;
                for (int j = 0; j < p.getComponentCount(); j++){
                    if (p.getComponent(j) instanceof JLabel){
                        JLabel l = (JLabel) p.getComponent(j);
                        tmp = DocumentHelper.createElement(l.getName());
                    }
                    else if (p.getComponent(j) instanceof JTextField){
                        JTextField text = (JTextField) p.getComponent(j);
                        tmp.setText(text.getText());
                    }
                    else if (p.getComponent(j) instanceof JPanel){
                        JPanel a = (JPanel) p.getComponent(j);
                        for (int k = 0; k < a.getComponentCount(); k++){
                            if (a.getComponent(k) instanceof JTextField){
                                JTextField aValue = (JTextField) a.getComponent(k);
                                tmp.addAttribute(aValue.getName(), aValue.getText());
                            }
                            else if (a.getComponent(k) instanceof KeyValueLabel){
                                KeyValueLabel keyvalue = (KeyValueLabel) a.getComponent(k);
                                tmp.addAttribute(keyvalue.getName(), keyvalue.getText());
                            }
                            else if (a.getComponent(k) instanceof JCheckBox){
                                JCheckBox aValue = (JCheckBox) a.getComponent(k);
                                tmp.addAttribute(aValue.getName(), aValue.getText());
                            }
                        }
                    }
                }
                e.add(tmp);
            }
        }
        return e;
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
        layoutPanel = new javax.swing.JPanel();
        titlePanel = new javax.swing.JPanel();
        lblPlus = new javax.swing.JLabel();
        contentPanel = new javax.swing.JPanel();

        editButton.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/edit_icon.png"))); // NOI18N
        editButton.setText("Edit");
        editButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                editButtonActionPerformed(evt);
            }
        });

        setLayout(new javax.swing.BoxLayout(this, javax.swing.BoxLayout.LINE_AXIS));

        titlePanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());
        titlePanel.setLayout(new javax.swing.BoxLayout(titlePanel, javax.swing.BoxLayout.LINE_AXIS));

        lblPlus.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/plus-icon.gif"))); // NOI18N
        lblPlus.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                lblPlusMouseClicked(evt);
            }
        });
        titlePanel.add(lblPlus);

        contentPanel.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.LOWERED));
        contentPanel.setLayout(new javax.swing.BoxLayout(contentPanel, javax.swing.BoxLayout.Y_AXIS));

        org.jdesktop.layout.GroupLayout layoutPanelLayout = new org.jdesktop.layout.GroupLayout(layoutPanel);
        layoutPanel.setLayout(layoutPanelLayout);
        layoutPanelLayout.setHorizontalGroup(
            layoutPanelLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(titlePanel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 770, Short.MAX_VALUE)
            .add(layoutPanelLayout.createSequentialGroup()
                .add(20, 20, 20)
                .add(contentPanel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 750, Short.MAX_VALUE))
        );
        layoutPanelLayout.setVerticalGroup(
            layoutPanelLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layoutPanelLayout.createSequentialGroup()
                .add(titlePanel, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(contentPanel, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE))
        );

        add(layoutPanel);
    }// </editor-fold>//GEN-END:initComponents

    private void editButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_editButtonActionPerformed
        EditFrame ef = new EditFrame(this, this.configElement);
        ef.setModal(true);
        ef.setVisible(true);
}//GEN-LAST:event_editButtonActionPerformed

    private void lblPlusMouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_lblPlusMouseClicked
        if (!this.show)
            this.expand();
        else
            this.contract();
    }//GEN-LAST:event_lblPlusMouseClicked
    
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JPanel contentPanel;
    private javax.swing.JButton editButton;
    private javax.swing.JPanel layoutPanel;
    private javax.swing.JLabel lblPlus;
    private javax.swing.JPanel titlePanel;
    // End of variables declaration//GEN-END:variables

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

    public void setConfigElement(Element element) {
        this.configElement = element;
    }

    public Element getConfigElement(){
        return (Element) this.configElement.clone();
    }
}
