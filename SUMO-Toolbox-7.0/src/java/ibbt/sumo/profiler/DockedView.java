package ibbt.sumo.profiler;
/**----------------------------------------------------------------------------------------
** This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
**
** This program is free software; you can redistribute it and/or modify it under
** the terms of the GNU Affero General Public License version 3 as published by the
** Free Software Foundation.
** 
** This program is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
** PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
** 
** You should have received a copy of the GNU Affero General Public License along
** with this program; if not, see http://www.gnu.org/licenses or write to the Free
** Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301 USA, or download the license from the following URL:
** 
** http://www.sumo.intec.ugent.be
** 
** In accordance with Section 7(b) of the GNU Affero General Public License, these
** Appropriate Legal Notices must retain the display of the "SUMO Toolbox" text and
** homepage.  In addition, when mentioning the program in written work, reference
** must be made to the corresponding publication.
** 
** You can be released from these requirements by purchasing a commercial license.
** Buying such a license is in most cases mandatory as soon as you develop
** commercial activities involving the SUMO Toolbox software. Commercial activities
** include: consultancy services or using the SUMO Toolbox in commercial projects 
** (standalone, on a server, through a webservice or other remote access technology).
** 
** For more information, please contact SUMO lab at
** 
**             sumo@intec.ugent.be - www.sumo.intec.ugent.be
**
** Revision: $Id: DockedView.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.config.ContextConfig;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.MouseEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.io.File;
import java.util.logging.Logger;

import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTextField;
import javax.swing.ListSelectionModel;
import javax.swing.WindowConstants;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;
import javax.swing.text.BadLocationException;
import javax.swing.text.Document;

public class DockedView {

	private JList fList;
	private FilteredListModel fListModel;
	private JFrame fFrame;
	private String windowTitle;
	private int previousSelection = -1;

	public DockedView() {
		windowTitle = "SUMO-Toolbox v" + ContextConfig.getToolboxVersion() + " - Profiler viewer";
	}

	private Logger logger = Logger.getLogger("ibbt.sumo.profiler.DockedView");
	
	public DockedView(String winTitle) {
		
		windowTitle = winTitle;
		
		// create the list of profilers
		fListModel = new FilteredListModel();
		fList = new JList(fListModel) {
			private static final long serialVersionUID = 1718523709675945171L;

			@Override
			public String getToolTipText(MouseEvent e) {
				int index = locationToIndex(e.getPoint());
				if (index >= 0) {
					return ((DockedViewHandler)fListModel.getElementAt(index)).getProfiler().getDescription();
				} else {
					return super.getToolTipText();
				}
			}
		};
		fList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		fList.setValueIsAdjusting(false);
		
		ListSelectionListener listener = new ListSelectionListener() {
			public void valueChanged(ListSelectionEvent e) {
				//Called when the user selects a different profiler
				
				if(e.getValueIsAdjusting()){
					//Only accept the last even in a fast series of events
					return;
				}
								
				int selectedIndex = fList.getSelectedIndex();
				DockedViewHandler cur = (DockedViewHandler)fListModel.getElementAt(selectedIndex);

				if(cur == null){
					return;
				}

				//System.out.println("** The user selected " + cur);
				
				if(previousSelection < 0){
					//Very first time we select something
					
					//activate the chart
					cur.setVisible(true);
					updateContentPanel(cur.getPanel());
					updateConfigPanel(cur.getConfigPanel());
					
					//save the current chart as the previous one
					previousSelection = selectedIndex;
					
					//update the radio button selection so it matches the
					//chart type requested by the currently selected profiler
				}else{
					if(previousSelection != selectedIndex){
						//deactivate the previous chart
						DockedViewHandler prev = (DockedViewHandler)fListModel.getElementAt(previousSelection);
						if(prev != null) {
							prev.setVisible(false);
						}
						
						//System.out.println("** The previous profiler selected is " + prev);
						
						//activate the current chart
						cur.setVisible(true);
						updateContentPanel(cur.getPanel());
						updateConfigPanel(cur.getConfigPanel());
						previousSelection = selectedIndex;
					}else{
						//ignore
					}
				}
			}
		};
		fList.addListSelectionListener(listener);
	
		// ProfilerChooser
		JScrollPane profilerChooser = new JScrollPane(fList);
		profilerChooser.setMinimumSize(new Dimension(250, 400));
		profilerChooser.setPreferredSize(new Dimension(250, 400));
		
		// SEARCH TEXTFIELD
		JTextField searchTextField = new JTextField();
		searchTextField.getDocument().addDocumentListener(new DocumentListener() {
			public void insertUpdate(DocumentEvent event) {
				update(event);
			}

			public void removeUpdate(DocumentEvent event) {
				update(event);
			}
			
			public void changedUpdate(DocumentEvent event) {
				update(event);
			}
			
			private void update(DocumentEvent event) {
				Document doc = event.getDocument();
				try {
					String filterString = doc.getText(0, doc.getLength());
					fListModel.updateFilter(filterString);
				} catch (BadLocationException e) {
				}
			}

		});
		
		// BUILD GUI
		
	    // filter bar
	    JPanel filterPane = new JPanel(new BorderLayout());
	    filterPane.add(new JLabel("Search: "), BorderLayout.NORTH);
	    filterPane.add(searchTextField, BorderLayout.SOUTH);
	    
		// left pane: filter bar + scroll pane + config pane
		JPanel leftPane = new JPanel(new BorderLayout());
		leftPane.add(filterPane, BorderLayout.NORTH);
		leftPane.add(profilerChooser, BorderLayout.CENTER);
		leftPane.add(new JPanel(), BorderLayout.SOUTH);

		// right pane : the actual profiler content
		JPanel rightPane = getDefaultPanel();
		
		// complete pane: left pane + profiler frame
	    JPanel contentPane = new JPanel(new BorderLayout());
	    contentPane.add(new JSplitPane(
	    		JSplitPane.HORIZONTAL_SPLIT,
	    		leftPane,
	    		rightPane));
	    contentPane.setOpaque(true);
		
	    // create frame
	    fFrame = new JFrame(windowTitle);
	    
	    //Set the window icon
	    try{
	    	String imgURL = ContextConfig.getRootDirectory() + File.separator + ContextConfig.getToolboxIcon();
	    	fFrame.setIconImage(new ImageIcon(imgURL).getImage());
	    }catch (Exception e) {
			logger.warning("Failed to set window icon: " + e.getMessage());
		}
	    
	    fFrame.setContentPane(contentPane);

	    // what happens when user closes the JFrame.
	    fFrame.setDefaultCloseOperation ( WindowConstants.DO_NOTHING_ON_CLOSE );
	    WindowListener windowListener = new WindowAdapter(){
	      // anonymous WindowAdapter class
	      @Override
		public void windowClosing ( WindowEvent w ) {
		  disableAllHandlers();
		  clear();

		  fFrame.setVisible( false );
		  fFrame.dispose();
		  } // end windowClosing
	      };// end anonymous class
	    fFrame.addWindowListener( windowListener );
	    
	    // show frame
	    fFrame.pack();
	    fFrame.setVisible(true);
	}

	private void updateContentPanel(JPanel newPanel){
		JPanel p = (JPanel)fFrame.getContentPane();
		JSplitPane c = (JSplitPane)p.getComponents()[0];
		c.setRightComponent(new JScrollPane(newPanel));
		fFrame.repaint();
	}

	private void updateConfigPanel(JPanel newPanel){
		JPanel p = (JPanel)fFrame.getContentPane();
		JSplitPane c = (JSplitPane)p.getComponents()[0];
		JPanel leftPanel = (JPanel)c.getLeftComponent();
		leftPanel.remove(2);
		leftPanel.add(newPanel, BorderLayout.SOUTH);
		fFrame.repaint();
	}
	
	public void updateProiflerPanels(){
		//get the currently selected profiler
		int selectedIndex = fList.getSelectedIndex();
		DockedViewHandler cur = (DockedViewHandler)fListModel.getElementAt(selectedIndex);

		if(cur == null){
			return;
		}
		
		updateContentPanel(cur.getPanel());
		updateConfigPanel(cur.getConfigPanel());
	}

	private void disableAllHandlers(){
	  for(int i=0;i < fListModel.getSize(); ++i){
	    ((DockedViewHandler)fListModel.getElementAt(i)).setEnabled(false);
	  }
	}

	public void setWindowTitle(String t){
		if(fFrame != null){
			fFrame.setTitle(t);
		}
	}
	
	// add profiler to list
	public void add(DockedViewHandler d) {
		fListModel.addElement(d);
		fFrame.repaint();
	}
	
	public void clear( ) {
		// Clear the listmodel contents
		fListModel.clear();
		
		// Repaint this window
		fFrame.repaint();
	}
	
	private JPanel getDefaultPanel(){
		//default empty chart panel
		JPanel p = new JPanel(new FlowLayout());
		JLabel l = new JLabel("Please select a profiler from the list");
		p.add(l);
		p.setMinimumSize(new Dimension(730,480));
		p.setPreferredSize(new Dimension(730,480));
		return p;
	}
}
