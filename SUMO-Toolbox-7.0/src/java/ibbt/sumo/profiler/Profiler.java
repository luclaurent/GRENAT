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
** Revision: $Id: Profiler.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.config.NodeConfig;
import ibbt.sumo.util.Pair;
import ibbt.sumo.util.Util;

import java.util.Arrays;
import java.util.Hashtable;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Logger;

import javax.swing.table.AbstractTableModel;

import org.dom4j.Node;
import org.dom4j.tree.DefaultElement;


/**
 *  This class can be seen as a logger class for numeric data in tuple form
 *  (like java.util.logging is for text messages)
 */
public class Profiler extends AbstractTableModel {
	private String fName;
	private String fDescription;
	private boolean fEnabled;
	
	// maps (column name) onto (column id,column description)
	private Hashtable<String,Pair<Integer, String>> fColumns;
	// maps (column id) onto (column name, column description)
	private Hashtable<Integer,Pair<String,String>> fColumnIds;
	// contains all the profiler data
	private LinkedList<ProfileRecord> fDataTable;
	// config data
	private String fOutputDirectory;
	//If no type is specified, what chart type is preferred
	private ChartType fPreferredChartType = ChartType.XY;
	// outputHandlers
	private List<OutputHandler> fOutputHandlers = new LinkedList<OutputHandler>();
	
	// logger
	private static Logger logger = Logger.getLogger("ibbt.sumo.util.Profiler");
	
	// Indicator flag...
	private boolean handlersStarted;
	
	// CONSTRUCTORS AND CONFIGURATION
//--------------------------------------------------------------------------------	
	/**
	 * Constructor that sets the name and the directory of the profiler
	 */
	public Profiler(String name, String dir) {
		setName(name);
		fDescription = "";
		fDataTable = new LinkedList<ProfileRecord>();
		fColumns = new Hashtable<String,Pair<Integer, String>>();		
		fEnabled = false;
		handlersStarted = false;
		fColumnIds = new Hashtable<Integer,Pair<String,String>>();
		fOutputDirectory = dir;
	}
//--------------------------------------------------------------------------------
	/**
	 * Destructor
	 */
	public void clear() {
		fEnabled = false;

		clearProfilerTable();
		
		fColumns.clear();
		fColumnIds.clear();
		fireTableStructureChanged();
		
		fOutputHandlers.clear();
		handlersStarted = false;
	}
//--------------------------------------------------------------------------------
	/**
	 * Remove all previously profiled records
	 * does not notify the output handlers
	 */
	public void clearProfilerTable(){
		int numRows = fDataTable.size();
		fDataTable.clear();
		
		if(numRows > 0){
			fireTableRowsDeleted(0, numRows-1);
		}
	}
//--------------------------------------------------------------------------------
	/**
	 * Configure the profiler with xml data
	 * @param config dom4j node containing the xml file
	 */
	@SuppressWarnings("unchecked")
	public void configure(Node config) { 
		// setup the output handlers for this profiler
		
		//Docked handler
		DockedViewHandler dockedHandler = null;

		List<Node> outputs = config.selectNodes("Output");
		for (Node node : outputs) {
			// create the appropriate output handler
			OutputHandler oh = null;
			String type = node.selectSingleNode("@type").getText();

			if (type.equals("toFile")) {
				oh = new ToFileHandler(this,NodeConfig.newInstance(node));
			} else if (type.equals("toTable")) {
				oh = new ToJTableHandler(this,NodeConfig.newInstance(node));
			} else if ( type.equals("toPanel")) {
				oh = new ToPanelHandler(this,NodeConfig.newInstance(node));
			} else if (type.equals("toImage")) {
				oh = new ToImageHandler(this,NodeConfig.newInstance(node));	
			} else {
				//ignore
				logger.fine("Ignoring unknown profiler output handler " + type);
				continue;
			}

			if ( Util.isHeadless() ){
				
				if (oh.requiresDisplay() ){
					logger.warning( type + " handler disabled for profiler " + getName() + " because system is headless" );
				}else{
					// add to list
					addOutputHandler(oh);
				}

			}else{
				//can the handler be docked into the profiler gui?
				if(oh instanceof DockableHandler){
					if(dockedHandler == null){
						dockedHandler = new DockedViewHandler(this, NodeConfig.newInstance(new DefaultElement("")));
					}
					dockedHandler.addHandler((DockableHandler)oh);
				}else{
					addOutputHandler(oh);
				}					
			}
		}
		
		//add the docked view handler itself
		if(dockedHandler != null){
			addOutputHandler(dockedHandler);

			ProfilerManager.getDockedView().add(dockedHandler);
		}
	}
//--------------------------------------------------------------------------------
	public String getOutputDirectory(){
		return fOutputDirectory;
	}
//--------------------------------------------------------------------------------
	/**
	 * Set the name of the profiler
	 * @param name the ID by which the profiler shall be known
	 */
	public void setName(String name) {
		fName = name;
	}
//--------------------------------------------------------------------------------
	/**
	 * Get the name of the profiler
	 * @return the ID of the profiler
	 */
	public String getName() {
		return fName;
	}
//--------------------------------------------------------------------------------
	/**
	 * Set the description of the profiler
	 * @param desc description string
	 */
	public void setDescription(String desc) {
		fDescription = desc;
	}
//--------------------------------------------------------------------------------
	/**
	 * Get the description of the profiler
	 * @return the description of the profiler
	 */
	public String getDescription() {
		return fDescription;
	}
//--------------------------------------------------------------------------------
	/**
	 * Set the preferred chart type to use (overridden by config)
	 */
	public void setPreferredChartType(ChartType type){
		fPreferredChartType = type;
	}
//--------------------------------------------------------------------------------
	/**
	 * Get the preferred chart type for this profiler
	 */
	public ChartType getPreferredChartType(){
		return fPreferredChartType;
	}
//--------------------------------------------------------------------------------
	/**
	 * Enable or disable the profiler
	 * @param enabled
	 */
	public void setEnabled(boolean enabled) {
		fEnabled = enabled;
	}
//--------------------------------------------------------------------------------
	/**
	 * is the profiler enabled?
	 * @return enabled
	 */
	public boolean isEnabled() {
		return fEnabled;
	}
//--------------------------------------------------------------------------------
	/**
	 * Add a column to the profiler
	 * @param name the ID of the column
	 * @param desc a description of the column
	 */
	public void addColumn(String name, String desc) {
		if (!fEnabled) return; 
		
		// warning if there is already some data in the table
		if (fDataTable.size() != 0) {
			logger.severe("Cannot add the column '" + name + "' to '" +  getName() + "' if the profiler is already in use");
			return;
		}
		
		// if column already exists, return and throw warning
		if (fColumns.containsKey(name)) {
			logger.warning(getName() + " already contains the column '" + name + "', request ignored");
			return;
		}
		
		int id = fColumns.size();
		Pair<Integer,String> p1 = new Pair<Integer,String>(id,desc);
		Pair<String,String> p2 = new Pair<String,String>(name,desc);
		
		fColumns.put(name, p1);
		fColumnIds.put(id, p2);
		
		//tell listeners the table structure has changed
		fireTableStructureChanged();
	}
	//--------------------------------------------------------------------------------
	private boolean prepEntry(Object[] args){
		if (!fEnabled) 
			return false; 

		if(args.length != fColumns.size()){
			logger.severe(getName() + ", calling addEntry with an invalid number of entries, " 
					+ args.length + " passed, " + fColumns.size() + " expected");
			logger.fine("The invalid entry passed was '" + Arrays.toString(args) + "'");
			return false;
		}
		
		// Start the output handlers if its the first time
		if ( !handlersStarted ) {
			startOutputHandlers();
		}
		
		return true;
	}
//--------------------------------------------------------------------------------
	/**
	 * Add an new entry row to the profiler and fill it up with data
	 * @param args the values of the new row
	 */
	public void addEntry(String[] args) {
		if(!prepEntry(args)) return;
		
		// set data
		ProfileRecord<String> rec = new ProfileRecord<String>(args);
		fDataTable.add(rec);
		fireTableRowsInserted(fDataTable.size()-1, fDataTable.size()-1);
		updateOutput(rec);	
	}
//--------------------------------------------------------------------------------
	/**
	 * Add an new entry row to the profiler and fill it up with data
	 * @param args the values of the new row
	 */
	public void addEntry(double[] args) {
		
		//TODO: AAARG! I hate this but seems like no way around
		Double[] tmp = new Double[args.length];
		for(int i=0; i < args.length ; ++i){
			tmp[i] = args[i];
		}
		
		if(!prepEntry(tmp)) return;
		
		// set data
		ProfileRecord<Double> rec = new ProfileRecord<Double>(tmp);
		fDataTable.add(rec);
		fireTableRowsInserted(fDataTable.size()-1, fDataTable.size()-1);
		updateOutput(rec);	
	}
//--------------------------------------------------------------------------------
	/**
	 * Add an new entry row to the profiler and fill it up with data
	 * Useful if the first column is numeric but the rest are strings
	 * The actual record added is a String one
	 */
	public void addEntry(double d, String[] args) {
		
		//concat into one string array
		String[] tmp = new String[args.length + 1];
		tmp[0] = Double.toString(d);
		for(int i=0; i < args.length ; ++i){
			tmp[i+1] = args[i];
		}
		
		if(!prepEntry(tmp)) return;
		
		// set data
		ProfileRecord<String> rec = new ProfileRecord<String>(tmp);
		fDataTable.add(rec);
		fireTableRowsInserted(fDataTable.size()-1, fDataTable.size()-1);
		updateOutput(rec);	
	}
//--------------------------------------------------------------------------------
	/**
	 * Add a whole matrix of entries in one go
	 * @param args the values of the new row
	 */
	public void addEntries(double[][] args) {
	      if (!fEnabled) 
	    	  return; 

	      for(int i = 0; i < args.length; ++i){
	    	  addEntry(args[i]);
	      }
	}
//--------------------------------------------------------------------------------
	private void startOutputHandlers() {
		if(handlersStarted || !fEnabled) return;

		for (OutputHandler oh : fOutputHandlers) {
			try {
				oh.begin();
				handlersStarted = true;
			} catch (java.awt.HeadlessException ex) {
				fEnabled = false;
			}
		}
	}
//--------------------------------------------------------------------------------
	/**
	 * Update the outputhandlers
	 */
	private void updateOutput(ProfileRecord rec) {

		if (fEnabled) {
			for (OutputHandler oh : fOutputHandlers) {
				if(oh.isEnabled()) oh.update(rec);
			}
		}
	}
//--------------------------------------------------------------------------------
	/**
	 * Update the outputhandlers and tell them that the run is finished
	 */
	public void finalizeOutput() {
		if (fEnabled) {
			for (OutputHandler oh : fOutputHandlers) {
				oh.end();
			}
		}
	}	
//--------------------------------------------------------------------------------	
	/**
	 * Return the raw data table
	 */
	public LinkedList<ProfileRecord> getData() {
		return fDataTable;
	}
//	--------------------------------------------------------------------------------	
	/**
	 * Return the description matching the given column name
	 */
	public String getColumnDescription(String name) {
		return fColumns.get(name).getSecond();
	}	
//	--------------------------------------------------------------------------------
	/**
	 * Return the description matching the given column id
	 */
	public String getColumnDescription(Integer id) {
		return fColumnIds.get(id).getSecond();
	}	
//	--------------------------------------------------------------------------------
	/**
	 * Return the column id matching the given column name
	 */
	public int getColumnId(String name) {
		return fColumns.get(name).getFirst();
	}	
//	--------------------------------------------------------------------------------
	/**
	 * Return the column name matching the given column id
	 */
	public Hashtable<Integer,Pair<String,String>> getColumnsById() {
		return fColumnIds;
	}
//	--------------------------------------------------------------------------------
	/**
	 * Return the column name matching the given column id
	 */
	public Hashtable<String,Pair<Integer,String>> getColumnsByName() {
		return fColumns;
	}	
//--------------------------------------------------------------------------------		
	public void addOutputHandler(OutputHandler oh) {
		fOutputHandlers.add(oh);		
	}
//--------------------------------------------------------------------------------		
	public void removeOutputHandler(OutputHandler oh) {
		fOutputHandlers.remove(oh);		
	}
//--------------------------------------------------------------------------------		
// implement AbstractTableModel

	public String getColumnName(int id) {
		//System.out.println("**** getting colname " + fColumnIds.get(id).getFirst());
		return fColumnIds.get(id).getFirst();
	}	

	public int getColumnCount() {
		//System.out.println("*** get column count returns " + fColumns.size());
		return fColumns.size();
	}
	public int getRowCount() {
		//System.out.println("*** get row count returns " + fDataTable.size());
		return fDataTable.size();
	}
	public Object getValueAt(int row, int col) {
		//System.out.println("*** table model asked for value at " + row + "," + col);
		return fDataTable.get(row).getValue(col);
	}
	 public Class getColumnClass(int c) {
         return getValueAt(0, c).getClass();
     }
}
