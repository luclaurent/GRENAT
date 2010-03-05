/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * EditFrame.java
 *
 * Created on Aug 19, 2009, 7:43:45 PM
 */

package ibbt.sumo.gui.forms;

import javax.swing.JFrame;
import javax.swing.JOptionPane;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

/**
 *
 * @author theking
 */
public class EditFrame extends javax.swing.JDialog {
//    private OptionsFrameV2 parent;
    private ExpandablePanel parent;
    private Element configElement;

    /** Creates new form EditFrame */
    public EditFrame() {
        initComponents();
    }

    /**
     *
     * @param configElement
     */
    public EditFrame(ExpandablePanel parent, Element configElement) {
        this.parent = parent;
        this.configElement = configElement;
        initComponents();

        String xml = this.configElement.asXML().replace("><", ">\n\t<");
        this.editTextArea.setText(xml);
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane1 = new javax.swing.JScrollPane();
        editTextArea = new javax.swing.JTextArea();
        descriptionLabel = new javax.swing.JLabel();
        buttonPanel = new javax.swing.JPanel();
        okButton = new javax.swing.JButton();
        cancelButton = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);

        //editTextArea.setLineWrap(true);
        //editTextArea.setWrapStyleWord(true);
        editTextArea.setColumns(0);
        editTextArea.setRows(0);
        editTextArea.setTabSize(4);
        editTextArea.setToolTipText("You can add remove options from element");
        //editTextArea.setText(this.configElement.asXML());
        jScrollPane1.setViewportView(editTextArea);

        descriptionLabel.setIcon(new javax.swing.ImageIcon(getClass().getResource("/ibbt/sumo/gui/inputfiles/sumo1.png"))); // NOI18N
        descriptionLabel.setText("Enter your xml code here:");

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
                .add(layout.createParallelGroup(org.jdesktop.layout.GroupLayout.CENTER)
                    .add(jScrollPane1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 521, Short.MAX_VALUE)
                    .add(buttonPanel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 521, Short.MAX_VALUE)
                    .add(descriptionLabel, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 521, Short.MAX_VALUE))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(org.jdesktop.layout.GroupLayout.LEADING)
            .add(org.jdesktop.layout.GroupLayout.TRAILING, layout.createSequentialGroup()
                .addContainerGap()
                .add(descriptionLabel, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, 16, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE)
                .add(18, 18, 18)
                .add(jScrollPane1, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, 207, Short.MAX_VALUE)
                .addPreferredGap(org.jdesktop.layout.LayoutStyle.RELATED)
                .add(buttonPanel, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE, org.jdesktop.layout.GroupLayout.DEFAULT_SIZE, org.jdesktop.layout.GroupLayout.PREFERRED_SIZE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void okButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_okButtonActionPerformed
        Document d = null;
        try {
            d = DocumentHelper.parseText(this.editTextArea.getText());
        } catch (DocumentException ex) {
            String msg = "Invalid xml code!";
            JOptionPane.showMessageDialog(new JFrame(), msg, "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }
        this.parent.setConfigElement((Element) d.getRootElement().clone());
        this.parent.initTitlePanel();
        this.parent.initContentPanel();
        this.parent.refreshPanel();
        this.dispose();
    }//GEN-LAST:event_okButtonActionPerformed

    private void cancelButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_cancelButtonActionPerformed
        this.dispose();
    }//GEN-LAST:event_cancelButtonActionPerformed

    /**
    * @param args the command line arguments
    */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                new EditFrame().setVisible(true);
            }
        });
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JPanel buttonPanel;
    private javax.swing.JButton cancelButton;
    private javax.swing.JLabel descriptionLabel;
    private javax.swing.JTextArea editTextArea;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JButton okButton;
    // End of variables declaration//GEN-END:variables

}
