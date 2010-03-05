/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package ibbt.sumo.gui.util;

import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JSpinner;

/**
 *
 * @author theking
 */
public class MyListeners {

    public static class MyKeyListener implements KeyListener{
        private JSpinner spinner;

        public MyKeyListener(JSpinner spin){
            this.spinner = spin;
        }

        public void keyTyped(KeyEvent arg0) {
            char c = arg0.getKeyChar();
            if (!Character.isDigit(c) && (c != KeyEvent.VK_BACK_SPACE) && (c != KeyEvent.VK_DELETE)) {
                JOptionPane.showMessageDialog(new JFrame(), "Invalid input!! (input must be positive number)", "Error", JOptionPane.ERROR_MESSAGE);
                arg0.consume();
                this.spinner.setValue(1);
            }
        }

        public void keyPressed(KeyEvent arg0) {
//            throw new UnsupportedOperationException("Not supported yet.");
        }

        public void keyReleased(KeyEvent arg0) {
//            throw new UnsupportedOperationException("Not supported yet.");
        }
    }

    public static class MyFocusListener implements FocusListener{
        private JSpinner spinner;

        public MyFocusListener(JSpinner spin){
            this.spinner = spin;
        }

        public void focusGained(FocusEvent arg0) {
//            throw new UnsupportedOperationException("Not supported yet.");
        }

        public void focusLost(FocusEvent arg0) {
            if (arg0.getSource() instanceof JSpinner){
               JSpinner js = (JSpinner)arg0.getSource();
               Integer value = (Integer)js.getValue();
               System.out.println(value);
               if (value < 0){
                   JOptionPane.showMessageDialog(new JFrame(), "Invalid input!! (input must be positive number)", "Error", JOptionPane.ERROR_MESSAGE);
                   this.spinner.setValue(1);
               }
            }
        }

    }

}
