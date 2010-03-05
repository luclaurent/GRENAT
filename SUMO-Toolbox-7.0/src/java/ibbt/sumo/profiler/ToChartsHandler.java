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
** Revision: $Id: ToChartsHandler.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import java.awt.Dimension;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Hashtable;
import java.util.logging.Logger;

import javax.swing.ButtonGroup;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;

import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;


/**
 * This class contains all basic functions that an outputhandler which 
 * needs charts should support
 */
class ToChartsHandler extends DockableHandler {

//--------------------------------------------------------------------------------	
	private static Logger logger = Logger.getLogger("ibbt.sumo.profiler.ToJChartsHandler");	

	private String fColumns = "";	
	private ChartType fType = null;
	
	private int xAxisID = 0;
	private int[] yAxisID = null;
	private String xDescription = "";	
	private String[] yDescriptions = null;

	private String fTitle = "";	
	private String fSubTitle = "";

	private int fontSize = JFreeChartBuilder.DEFAULT_FONTSIZE;
	private int width = JFreeChartBuilder.DEFAULT_WIDTH;
	private int height = JFreeChartBuilder.DEFAULT_HEIGHT;
	private JFreeChartBuilder builder = null;
	
	private ChartPanel chartPanel = null;
	private JPanel configPanel = null;
	private Hashtable<String, JRadioButton> radioButtons = new Hashtable<String,JRadioButton>();
//--------------------------------------------------------------------------------	
	public ToChartsHandler(Profiler p, ibbt.sumo.config.NodeConfig conf) { 
		super(p,conf);
		fColumns = conf.getOption("columns", "");	
		String t = conf.getOption("chartType", "");
		
		//if the user specified a chart type use that
		if(t.length() > 0){
			fType = ChartType.valueOf(t);
		}
		
		width = conf.getIntOption("width",width);
		height = conf.getIntOption("height",height);
		fontSize = conf.getIntOption("fontSize",fontSize);
		
		chartPanel = new ChartPanel(null);
		configPanel = setupConfigPanel();
	}
//--------------------------------------------------------------------------------	
	/**
	 * Do things before the run has started
	 */
	public void begin() {
		Profiler p = getProfiler();
		
		// Use the profiler description as the plot title and subtitle
		xAxisID = 0;
		fTitle = "";
		fSubTitle = "";
		
		String[] titles = p.getDescription().split(";");
		if (titles.length < 1) {
			// nothing
		} else if (titles.length < 2) {
			fTitle = titles[0];
		} else {
			fTitle = titles[0];
			for (int i = 1; i < titles.length; i++) {
				fSubTitle += titles[i] + " ";
			}
		}
			
		//did the user specify which columns should be plotted?
		if (fColumns.length() < 1) {
			//if not select all columns
			fColumns = p.getColumnName(0);
			for (int i = 1; i < p.getColumnCount(); i++) {
				fColumns += "," + p.getColumnName(i);
			}
		}else{
			//if so, check that all column names are valid
			String[] axes = fColumns.split(",");
			for(String s : axes) {
				if(!p.getColumnsByName().containsKey(s)) {
					logger.severe("The requested column '" 
							+ s + "' + does not exist in the profiler '" + getProfiler().getName() + "', selecting all columns instead");
					
					fColumns = p.getColumnName(0);
					for (int i = 1; i < p.getColumnCount(); i++) {
						fColumns += "," + p.getColumnName(i);
					}
					break;
				}
			}
		}
		
		//split the string of column names into a list
		String[] axes = fColumns.split(",");
		if (axes.length < 2) {
			//There is only one column (1D dataset ), the chart stuff always requires at least 2
			//we will have to add a second column that is just numbered from 1 to n
			//this will be the x-axis.  Use -1 to flag this case
			xAxisID = -1;
			xDescription = "iteration";
			
			//the given column is used as y-axis
			yAxisID = new int[]{p.getColumnId(axes[0])};
			yDescriptions = new String[]{p.getColumnDescription(axes[0])};
		}else{
			//more than one column
			
			//the x-axis is the first column
			xAxisID = p.getColumnId(axes[0]);
			xDescription = p.getColumnDescription(axes[0]);
			
			//the y-axes are all other columns
			yAxisID = new int[axes.length - 1];
			yDescriptions = new String[axes.length - 1];
			for (int i = 1; i < axes.length; i++) {
				yAxisID[i-1] = p.getColumnId(axes[i]);
				yDescriptions[i-1] = p.getColumnDescription(axes[i]);
			}
		}
		
		//if the user did not choose a type explicitly, use what the profiler prefers
		if(fType == null){
			fType = getProfiler().getPreferredChartType();
			//ensure the corresponding radio button is selected
			radioButtons.get(fType.name()).setSelected(true);
		}
		
		//System.out.println("ToChartHandler, begin done, creating new builder for type " + fType);
		builder = new JFreeChartBuilder(fType,fTitle,fSubTitle,xDescription,yDescriptions);
		builder.setFontSize(fontSize);
		builder.createEmptyChart();
	}
//	--------------------------------------------------------------------------------
	public void setFontSize(int size){
		fontSize = size;
		if(builder != null) {
			builder.setFontSize(size);
		}
	}
//	--------------------------------------------------------------------------------
	/**
	 * Add a new datapoint to the profiler
	 */
	public void update(ProfileRecord rec) {
		if(rec.getValue(0) instanceof Number){
			//update the chart
			builder.update(rec, xAxisID, yAxisID);
		}else{
			//ignore non numeric profiler records
		}
	}
//--------------------------------------------------------------------------------	
	/**
	 * Do things when a run has ended
	 */
	public void end() {
		
	}
//--------------------------------------------------------------------------------		
	public int getWidth(){
		return width;
	}
//--------------------------------------------------------------------------------
	public int getHeight(){
		return height;
	}
//--------------------------------------------------------------------------------
	public void setWidth(int width){
		this.width = width;
	}
//	--------------------------------------------------------------------------------
	public void setHeight(int height){
		this.height = height;
	}
//--------------------------------------------------------------------------------		
	public JFreeChart getChart() {
		if(builder == null){
			return null;
		}else{
			return builder.getChart();
		}
	}
//--------------------------------------------------------------------------------		
	public void setType(ChartType type) {
		fType = type;
	}
//--------------------------------------------------------------------------------		
	public ChartType getType() {
		return fType;
	}
//--------------------------------------------------------------------------------		
	public String toString() {
		return getProfiler().getName();
	}
//--------------------------------------------------------------------------------		
	protected JFreeChartBuilder getChartBuilder(){
		return builder;
	}
//	--------------------------------------------------------------------------------
	public JPanel getPanel(){
		JFreeChart c = getChart();
		if(c == null){
			return null;
		}else{
			chartPanel.setChart(c);
			chartPanel.setPreferredSize(new Dimension(JFreeChartBuilder.DEFAULT_WIDTH,JFreeChartBuilder.DEFAULT_HEIGHT));
			// When resizing the chart window, redraw the chart up to this size, if size is larger simply scale the image
			chartPanel.setMaximumSize(new Dimension(1000,1000));
			return chartPanel;
		}
	}
//--------------------------------------------------------------------------------
	public void clearData(){
		//simply re-init the chart
		begin();	
	}
//--------------------------------------------------------------------------------
	private JPanel setupConfigPanel(){
		// radioboxes
	    ActionListener acl = new ActionListener() {
	    	public void actionPerformed(ActionEvent e) {
	    		//The user selected a different chart type
	    		
	    		//Get the type that user selected
	    		ChartType newType = ChartType.valueOf(e.getActionCommand());
	    		//Get the type that the handler was producing
	    		ChartType oldType = getType();
	    		
	    		//System.out.println("*** old type: " + oldType + " New type: " + newType);
	    		
	    		if(oldType == newType){
	    			//the old type is the same as the new type, nothing needs to change
	    		}else{
	    			//set the new type
	    			setType(newType);

	    			//re-initialize the chart handler (clear the old chart and create an empty new one)
	    			clearData();
	    			//set the data on the new, emtpy chart
	    			addDataFromProfiler(getProfiler());
	    			//update the chart panel
	    			chartPanel.setChart(getChart());
	    		}
	    	}
	    };
		configPanel = new JPanel(new GridLayout(0,2));
		configPanel.add(new JLabel("Chart Type:"));
		configPanel.add(new JLabel("")); //empty placeholder

		ButtonGroup typeGroup = new ButtonGroup();

		for(ChartType t : ChartType.values()){
		    JRadioButton rbutton = new JRadioButton(t.toString());
		    rbutton.setActionCommand(t.name());
		    rbutton.addActionListener(acl);
		    //Set the initial type to the preferred type
		    if(t == getProfiler().getPreferredChartType()){
		    	rbutton.setSelected(true);
		    }
		    typeGroup.add(rbutton);
		    configPanel.add(rbutton);
		    radioButtons.put(t.name(),rbutton);
		}
		
		return configPanel;
	}
//--------------------------------------------------------------------------------			
	public JPanel getConfigPanel(){
		return configPanel;
	}
//--------------------------------------------------------------------------------
	@Override
	public String getName() {
		return "Plot";
	}
//--------------------------------------------------------------------------------
}
