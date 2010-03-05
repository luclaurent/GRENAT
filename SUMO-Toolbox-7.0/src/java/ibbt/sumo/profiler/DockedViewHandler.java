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
** Revision: $Id: DockedViewHandler.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.config.NodeConfig;

import java.awt.BorderLayout;
import java.util.LinkedList;

import javax.swing.JPanel;
import javax.swing.JTabbedPane;
import javax.swing.SwingConstants;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

public class DockedViewHandler extends DockableHandler {

	private boolean visible = false;
	private JPanel panel = null;
	private JTabbedPane tabs = null;
	private LinkedList<DockableHandler> handlers = null;
	
	public DockedViewHandler(Profiler p, NodeConfig conf){
		super(p,conf);
		
		handlers = new LinkedList<DockableHandler>();
		tabs = new JTabbedPane(SwingConstants.TOP);
		
		// Register a change listener so we know when the user selects a different tab
	    tabs.addChangeListener(new ChangeListener() {
	        // This method is called whenever the selected tab changes
	        public void stateChanged(ChangeEvent evt) {
	        	//tell our parent gui to update its panels
	            ProfilerManager.getDockedView().updateProiflerPanels();
	        }
	    });
		
		panel = new JPanel(new BorderLayout());
		panel.add(tabs,BorderLayout.CENTER);
	}
	
	@Override
	public void begin() {
		for(DockableHandler h : handlers){
			h.begin();
		}
	}

	@Override
	public void end() {
		for(DockableHandler h : handlers){
			h.end();
		}
	}
	
	public void clearData(){
		if(getProfiler().getRowCount() > 0) {
			for(DockableHandler h : handlers){
				h.clearData();
			}
		}
	}
	
	public void addHandler(DockableHandler h){
		handlers.add(h);
		tabs.addTab(h.getName(), h.getPanel());
	}
	
	@Override
	public void update(ProfileRecord rec) {
		if(isVisible()){
			for(DockableHandler h : handlers){
				h.update(rec);
				//System.out.println("** Updating " + h.getClass() + " of " + getProfiler().getName());
			}
		}else{
			//panel is not visible ignore updates
			//System.out.println("** NOT Updating " + getProfiler().getName() + " since its not visible");
		}
	}

	public LinkedList<DockableHandler> getHandlers(){
		return handlers;
	}
	
	public boolean isVisible(){
		return visible;
	}

	public void setVisible(boolean b){
		if(b){
			if(isVisible()) return;
			visible = true;
			
			if(getProfiler().getRowCount() < 1) return;
			
			//clear before adding data
			for(DockableHandler h : handlers){
				h.clearData();
				h.addDataFromProfiler(getProfiler());
			}
		}else{
			visible = false;
		}
	}
	
	@Override
	public JPanel getPanel(){
		for(int i = 0 ; i < tabs.getTabCount() ; ++i){
			tabs.setComponentAt(i, handlers.get(i).getPanel());
		}
		
		return panel;
	}
	
	@Override
	public JPanel getConfigPanel(){
		if(handlers.isEmpty()){
			return new JPanel();
		}
		
		JPanel p = handlers.get(tabs.getSelectedIndex()).getConfigPanel();
		return p;
	}
	
	@Override
	public String toString(){
		return getProfiler().getName();
	}
	
	@Override
	public String getName(){
		return "Handle Group";
	}
}
