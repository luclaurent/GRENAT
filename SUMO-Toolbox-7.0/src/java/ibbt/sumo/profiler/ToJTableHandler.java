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
** Revision: $Id: ToJTableHandler.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.config.NodeConfig;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.event.MouseEvent;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.LinkedList;

import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.SwingConstants;
import javax.swing.table.AbstractTableModel;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.JTableHeader;

public class ToJTableHandler extends DockableHandler {

	private JTable table;
	private JPanel panel;
	
	public ToJTableHandler(Profiler p, NodeConfig conf) { 
		super(p,conf);
		
		table = new JTable(new ProxyTableModel(p)){
			//Implement table header tool tips. 
            protected JTableHeader createDefaultTableHeader() {
                return new JTableHeader(columnModel) {
                    public String getToolTipText(MouseEvent e) {
                        String tip = null;
                        java.awt.Point p = e.getPoint();
                        int index = columnModel.getColumnIndexAtX(p.x);
                        int realIndex = columnModel.getColumn(index).getModelIndex();
                        return getProfiler().getColumnDescription(realIndex);
                    }
                };
            }
		};
		
		//table.setFillsViewportHeight(true); //only supported in 1.6
		table.setAutoCreateColumnsFromModel(true);
		
		panel = new JPanel();
		panel.setLayout(new BorderLayout());
		panel.add(new JScrollPane(table),BorderLayout.CENTER);
	}
//--------------------------------------------------------------------------------	
	public void begin() {
		//table.setAutoCreateRowSorter(true); //only supported in 1.6
		
		for(int i=0; i < table.getColumnCount() ; ++i){
			table.getColumnModel().getColumn(i).setCellRenderer(new ProfilerCellRenderer());
		}
		
		// let all table model listeners know we are ready for business
		((ProxyTableModel)table.getModel()).begin();
	}
//--------------------------------------------------------------------------------
	public void clearData(){
		((ProxyTableModel)table.getModel()).clear();
	}
//--------------------------------------------------------------------------------	
	public void update(ProfileRecord rec){
		((ProxyTableModel)table.getModel()).add(rec);
	}
//--------------------------------------------------------------------------------	
	public JPanel getPanel(){
		return panel;
	}
//--------------------------------------------------------------------------------	
	public void end(){
		//do nothing
	}
//--------------------------------------------------------------------------------	
	public String getName(){
		return "Data Table";
	}
//--------------------------------------------------------------------------------	
	public boolean requiresDisplay(){
		return true;
	}
//--------------------------------------------------------------------------------	
	private class ProfilerCellRenderer extends DefaultTableCellRenderer {
		DecimalFormat formatter = (DecimalFormat)NumberFormat.getInstance();
		
	    public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus,int row, int column) {

	  	  	//Enforce scientific notation (if a number) and force a '.', never allow ','
	    	formatter.applyPattern("0.###E0#");

	    	if(column > 0 && value != null && value instanceof Number){
	        	super.setValue(formatter.format(value));
	        }
	 
	        Component component = super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);
            setHorizontalAlignment(SwingConstants.CENTER);
	        
	        return component;
	    }
	}
//--------------------------------------------------------------------------------
	/**
	 * Profiler already implements AbstractTableModel but when we start messing around with the 
	 * table (like clearing it) we want to leave the original profiler alone
	 */
	private class ProxyTableModel extends AbstractTableModel {

		private LinkedList<ProfileRecord> table = new LinkedList<ProfileRecord>();
		private Profiler profiler = null;
		
		public ProxyTableModel(Profiler p){
			profiler = p;
		}
		
		public void add(ProfileRecord rec){
			table.add(rec);
			fireTableRowsInserted(table.size()-1, table.size()-1);
		}

		public void begin(){
			fireTableStructureChanged();
		}

		public void clear(){
			int numRows = table.size();
			table.clear();
			
			if(numRows > 0){
				fireTableRowsDeleted(0, numRows-1);
			}
		}
		
		public String getColumnName(int id) {
			return profiler.getColumnName(id);
		}	

		public int getColumnCount() {
			return profiler.getColumnCount();
		}
		public int getRowCount() {
			return table.size();
		}
		public Object getValueAt(int row, int col) {
			return table.get(row).getValue(col);
		}
		
		public Class getColumnClass(int c) {
	        return getValueAt(0, c).getClass();
	    }
		
	}
	
//--------------------------------------------------------------------------------	

}

