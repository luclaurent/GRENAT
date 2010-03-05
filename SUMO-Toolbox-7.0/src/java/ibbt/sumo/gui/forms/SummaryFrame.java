/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * SummaryFrame.java
 *
 * Created on Jul 27, 2009, 6:17:43 PM
 */

package ibbt.sumo.gui.forms;

import ibbt.sumo.gui.context.ToolboxConfigurationFile;
import ibbt.sumo.gui.util.XMLFileFilter;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;

import org.dom4j.Attribute;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.OutputFormat;
import org.dom4j.io.XMLWriter;

/**
 *
 * @author Sasa Berberovic
 */
public class SummaryFrame extends javax.swing.JDialog {
    private NewConfigFileForm parent;
    private Document doc;
    private Vector<Document> docs;
    private String location;

   /**
    * 
    * @param p
    * @param newConfigFile
    */
    public SummaryFrame(NewConfigFileForm p, ToolboxConfigurationFile newConfigFile) {
        this.parent = p;
        this.doc = newConfigFile.write();
        this.docs = newConfigFile.writeMultipleFiles();

        initComponents();
        initInfoPanel();
    }
    
    public void initInfoPanel(){
        String curDir = System.getProperty("user.dir");
        this.savePath.setText(curDir);

        Element root = this.doc.getRootElement();
        Element plan = this.doc.getRootElement().element("Plan");

        String html = "<html>";

        String simulator = "<p><b>Selected simulator: </b><br>" 
                + plan.element("Simulator").getText() + "</p>";
        html = html.concat(simulator);

        String inputs1 = "<p><b>Selected input parameters: </b><br>";

        Element inputs = plan.element("Inputs");
        for (int i = 0; i < inputs.elements("Input").size(); i++){
            Element in = (Element) inputs.elements("Input").get(i);
            inputs1 = inputs1.concat("name = " + in.attributeValue("name") + "<br>");
        }
        inputs1.concat("</p>");
        html = html.concat(inputs1);

        String outputs1 = "<p><b>Selected output parameters: </b><br>";
        Element outputs = plan.element("Outputs");
        for (int i = 0; i < outputs.elements("Output").size(); i++){
            Element out = (Element) outputs.elements("Output").get(i);
            outputs1 = outputs1.concat("name = " + out.attributeValue("name") + "<br>");
        }
        outputs1.concat("</p>");
        html = html.concat(outputs1);

        String minTotSamples = "<p><b>Minimum Total Samples: </b><br>";
        String maxTotSamples = "<p><b>Maximum Total Samples: </b><br>";
        String maxRunTime = "<p><b>Maximum Running Time: </b><br>";

        if (root.element("SUMO") != null){
            Element sumo = root.element("SUMO");
            for (int i = 0; i < sumo.elements("Option").size(); i++){
                Element o = (Element) sumo.elements("Option").get(i);
                if (o.attributeValue("key").equals("minimumTotalSamples")){
                    minTotSamples = minTotSamples.concat("value = " + o.attributeValue("value") + "<br></p>");
                }
                else if (o.attributeValue("key").equals("maximumTotalSamples")){
                    maxTotSamples = maxTotSamples.concat("value = " + o.attributeValue("value") + "<br></p>");
                }
                else if (o.attributeValue("key").equals("maximumTime")){
                    maxRunTime = maxRunTime.concat("value = " + o.attributeValue("value") + "<br></p>");
                }
            }
        }
        html = html.concat(minTotSamples);
        html = html.concat(maxTotSamples);
        html = html.concat(maxRunTime);
        html = html.concat("</html>");

        JLabel info = new JLabel(html);
        this.information.add(info);
    }

    /**
     * 
     * @param root
     * @return
     */
    public DefaultMutableTreeNode getTreeModel(Element root){
        String nodeName = root.getName();
        nodeName = nodeName + ":" + root.getText();
       
        DefaultMutableTreeNode node = new DefaultMutableTreeNode(nodeName);
        
        for (int i = 0; i < root.attributeCount(); i++){
            Attribute a = (Attribute) root.attributes().get(i);
            String tmp = a.getName() + ": " + a.getValue();
            node.add(new DefaultMutableTreeNode(tmp));
        }

        for (int i = 0; i < root.elements().size(); i++){
            node.add(this.getTreeModel((Element) root.elements().get(i)));
        }
        
        return node;
    }

    /**
     *
     * @param doc
     */
    public void setPreview(DefaultMutableTreeNode root){
        this.previewTree.setModel(new DefaultTreeModel(root));
        this.repaint();
        this.validate();
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
        previewScrollPane = new javax.swing.JScrollPane();
        previewTree = new javax.swing.JTree();
        separator = new javax.swing.JSeparator();
        mainPanel = new javax.swing.JPanel();
        informationScrollPane = new javax.swing.JScrollPane();
        information = new javax.swing.JPanel();
        dirPanel = new javax.swing.JPanel();
        savePath = new javax.swing.JTextField();
        openButton = new javax.swing.JButton();
        jLabel1 = new javax.swing.JLabel();
        splitRuns = new javax.swing.JCheckBox();
        buttonPanel = new javax.swing.JPanel();
        okButton = new javax.swing.JButton();
        cancelButton = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setTitle("Summary Frame");

        descriptionLabel.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/sumo1.png"))); // NOI18N
        descriptionLabel.setText("This diolog shows the selected configurations.");

        previewScrollPane.setBorder(javax.swing.BorderFactory.createTitledBorder("Preview"));
        previewScrollPane.setViewportView(previewTree);

        separator.setOrientation(javax.swing.SwingConstants.VERTICAL);

        information.setLayout(new javax.swing.BoxLayout(information, javax.swing.BoxLayout.Y_AXIS));
        informationScrollPane.setViewportView(information);

        savePath.setText("jTextField1");

        openButton.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/load_icon.gif"))); // NOI18N
        openButton.setText("...");
        openButton.setToolTipText("Select the save location");
        openButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                openButtonActionPerformed(evt);
            }
        });

        jLabel1.setText("Location:");

        org.jdesktop.layout.GroupLayout dirPanelLayout = new org.jdesktop.layout.GroupLayout(dirPanel);
        dirPanel.setLayout(dirPanelLayout);
        dirPanelLayout.setHorizontalGroup(
            dirPanelLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(dirPanelLayout.createSequentialGroup()
                .addContainerGap()
                .add(jLabel1)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(savePath, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 382, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(openButton)
                .add(28, 28, 28))
        );
        dirPanelLayout.setVerticalGroup(
            dirPanelLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(dirPanelLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.CENTER)
                .add(openButton)
                .add(savePath, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .add(jLabel1))
        );

        splitRuns.setText("Split runs in different files");
        splitRuns.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                splitRunsActionPerformed(evt);
            }
        });

        org.jdesktop.layout.GroupLayout mainPanelLayout = new org.jdesktop.layout.GroupLayout(mainPanel);
        mainPanel.setLayout(mainPanelLayout);
        mainPanelLayout.setHorizontalGroup(
            mainPanelLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(informationScrollPane, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 550, Short.MAX_VALUE)
            .add(dirPanel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .add(mainPanelLayout.createSequentialGroup()
                .addContainerGap()
                .add(splitRuns)
                .addContainerGap(336, Short.MAX_VALUE))
        );
        mainPanelLayout.setVerticalGroup(
            mainPanelLayout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(mainPanelLayout.createSequentialGroup()
                .add(dirPanel, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED, 4, Short.MAX_VALUE)
                .add(splitRuns)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.UNRELATED)
                .add(informationScrollPane, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, 342, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE))
        );

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

        org.jdesktop.layout.GroupLayout layout = new org.jdesktop.layout.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createSequentialGroup()
                .addContainerGap()
                .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
                    .add(buttonPanel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 936, Short.MAX_VALUE)
                    .add(layout.createSequentialGroup()
                        .add(previewScrollPane, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, 350, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                        .add(separator, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                        .add(mainPanel, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE))
                    .add(descriptionLabel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 936, Short.MAX_VALUE))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(layout.createSequentialGroup()
                .addContainerGap(20, Short.MAX_VALUE)
                .add(descriptionLabel)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.UNRELATED)
                .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
                    .add(mainPanel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING, false)
                        .add(separator)
                        .add(previewScrollPane)))
                .add(20, 20, 20)
                .add(buttonPanel, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void okButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_okButtonActionPerformed
        try {
           if (this.savePath.getText().endsWith(".xml")){
               File f = new File(this.savePath.getText());
               if (f.exists()){
                    int tmp = JOptionPane.showConfirmDialog(this, "Are you sure you want to override this file!", "Information", JOptionPane.YES_NO_OPTION);
                    if (tmp == JOptionPane.NO_OPTION){
                        return;
                    }
               }

                if (!this.splitRuns.isSelected()){
                    OutputFormat format = OutputFormat.createPrettyPrint();
                    XMLWriter writer = new XMLWriter(new FileWriter(this.savePath.getText()), format);
                    writer.write(this.doc);
                    writer.close();
                }
                else {
                    String filepath = this.savePath.getText().replace(".xml", "");
                    System.out.println(filepath);
                    for (int i = 0; i < this.docs.size(); i++){
                        String tmp = filepath + String.valueOf(i) + ".xml";
                        System.out.println(tmp);

                        OutputFormat format = OutputFormat.createPrettyPrint();
                        XMLWriter writer = new XMLWriter(new FileWriter(tmp), format);
                        writer.write(this.docs.get(i));
                        writer.close();
                    }
                }

                this.parent.dispose();
                this.dispose();
            }
            else {
                String msg = "You didn't fill in the filename";
                JOptionPane.showMessageDialog(new JFrame(), msg, "Error", JOptionPane.ERROR_MESSAGE);
            }
        } catch (IOException ex) {
            Logger.getLogger(SummaryFrame.class.getName()).log(Level.SEVERE, null, ex);
            return;
        }
    }//GEN-LAST:event_okButtonActionPerformed

    private void cancelButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_cancelButtonActionPerformed
        this.dispose();
        this.parent.setVisible(true);
    }//GEN-LAST:event_cancelButtonActionPerformed

    private void splitRunsActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_splitRunsActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_splitRunsActionPerformed

    private void openButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_openButtonActionPerformed
        JFileChooser jfc = new JFileChooser(this.savePath.getText());
        jfc.setFileFilter(new XMLFileFilter());
        
        if (jfc.showSaveDialog(new JFrame()) == JFileChooser.APPROVE_OPTION){
            String path = jfc.getSelectedFile().getPath();
            if (!path.endsWith(".xml"))
                path = path.concat("xml");

            this.savePath.setText(path);
        }
    }//GEN-LAST:event_openButtonActionPerformed

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JPanel buttonPanel;
    private javax.swing.JButton cancelButton;
    private javax.swing.JLabel descriptionLabel;
    private javax.swing.JPanel dirPanel;
    private javax.swing.JPanel information;
    private javax.swing.JScrollPane informationScrollPane;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JPanel mainPanel;
    private javax.swing.JButton okButton;
    private javax.swing.JButton openButton;
    private javax.swing.JScrollPane previewScrollPane;
    private javax.swing.JTree previewTree;
    private javax.swing.JTextField savePath;
    private javax.swing.JSeparator separator;
    private javax.swing.JCheckBox splitRuns;
    // End of variables declaration//GEN-END:variables

}
