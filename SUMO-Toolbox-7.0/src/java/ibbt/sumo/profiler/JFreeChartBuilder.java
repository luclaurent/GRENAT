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
** Revision: $Id: JFreeChartBuilder.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.config.ContextConfig;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Paint;
import java.awt.geom.Rectangle2D;
import java.io.File;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.logging.Logger;

import org.freehep.graphics2d.VectorGraphics;
import org.freehep.graphicsio.pdf.PDFGraphics2D;
import org.freehep.graphicsio.ps.PSGraphics2D;
import org.freehep.graphicsio.svg.SVGGraphics2D;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.block.ColumnArrangement;
import org.jfree.chart.block.LineBorder;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PiePlot;
import org.jfree.chart.plot.PiePlot3D;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.category.LineAndShapeRenderer;
import org.jfree.chart.renderer.category.StackedBarRenderer;
import org.jfree.chart.renderer.xy.StackedXYAreaRenderer2;
import org.jfree.chart.renderer.xy.XYAreaRenderer;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.chart.title.LegendTitle;
import org.jfree.chart.title.TextTitle;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.data.general.DefaultPieDataset;
import org.jfree.data.xy.DefaultTableXYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.ui.HorizontalAlignment;
import org.jfree.ui.RectangleEdge;

/**
 * A helper class for generating charts
 */
class JFreeChartBuilder {

//--------------------------------------------------------------------------------	
	public static final int DEFAULT_WIDTH = 600;
	public static final int DEFAULT_HEIGHT = 400;
	public static final int DEFAULT_FONTSIZE = 10;
	private static final float transparency = 0.6f;
	
	private int fontSize = DEFAULT_FONTSIZE;
	private ChartType type = ChartType.XY;
	private String xlabel = null;	
	private String[] yDescriptions = null;
	private String title = null;	
	private String subTitle = null;
	private JFreeChart chart = null;

	private DecimalFormat formatter = new DecimalFormat("0.000E0");
	//private DecimalFormat formatter = new DecimalFormat("0.###E0");
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.profiler.ChartBuilder");	
	
//--------------------------------------------------------------------------------	
	public JFreeChartBuilder(ChartType type, String title, String subTitle, String xlabel, String[] yDescriptions) { 
		//TODO some sanity checking
		
		this.type = type;
		this.title = title;
		this.subTitle = subTitle;
		this.xlabel = xlabel;
		this.yDescriptions = yDescriptions;
	}
//	--------------------------------------------------------------------------------			
	public void finalize(){
		//cleanup
	}
//	--------------------------------------------------------------------------------			
	public void setFontSize(int size){
		fontSize = size;
	}
//	--------------------------------------------------------------------------------			
	public int getFontSize(){
		return fontSize;
	}
//	--------------------------------------------------------------------------------			
	public void createEmptyChart() {

		//System.out.println("Creating empty " + type );
		
		JFreeChart emptyChart = null;
		
		// Warning: the order of the following ifs should respect the ChartType hierarchy
		
		if(type.holds(ChartType.PIE)){
			emptyChart = createPieChart();
		}else if(type.holds(ChartType.LINE)) {
			emptyChart = createLineChart();
		}else if(type.holds(ChartType.LEVEL)) {
			emptyChart = createLevelChart();
		}else if(type.holds(ChartType.AREA_STACKED)) {
			emptyChart = createStackedXYAreaChart();
		}else if(type.holds(ChartType.AREA)) {
			emptyChart = createXYAreaChart();
		}else if(type.holds(ChartType.BAR_STACKED)) {
			emptyChart = createStackedBarChart();
		}else if(type.holds(ChartType.BAR)) {
			emptyChart = createBarChart();
		}else if(type.holds(ChartType.XY)) {
			emptyChart = createXYChart();
		}else if(type.holds(ChartType.SCATTER)) {
			emptyChart = createScatterChart();
		}else{
			System.out.println(type);
			logger.severe("Unsupported chart type '" + type + "' given");
			return;
		}
		
		// chart options
		emptyChart.setBackgroundPaint(Color.white);
		emptyChart.addSubtitle(new TextTitle(subTitle));
		TextTitle source = new TextTitle("Generated by the SUMO Toolbox v" + ContextConfig.getToolboxVersion() + " - " + ContextConfig.getToolboxHomepage());
			source.setFont(new Font("SansSerif", Font.PLAIN, 10));
			source.setPosition(RectangleEdge.BOTTOM);
			source.setHorizontalAlignment(HorizontalAlignment.RIGHT);
		emptyChart.addSubtitle(source);
		
		// legend options
		LegendTitle legend = new LegendTitle(emptyChart.getPlot(), new ColumnArrangement(), new ColumnArrangement()); 
		legend.setPosition(RectangleEdge.BOTTOM); 
		legend.setFrame(new LineBorder()); 
		emptyChart.addSubtitle(legend);			
		legend.setItemFont(new Font(legend.getItemFont().getName(),legend.getItemFont().getStyle(),fontSize));
		this.chart = emptyChart;
	}
//	--------------------------------------------------------------------------------	
//	--------------------------------------------------------------------------------	
	private JFreeChart createPieChart(){
		// create a dataset
		DefaultPieDataset dataset = new DefaultPieDataset();

		JFreeChart chart = null;
		
		// create a chart...
		if(type == ChartType.PIE){
				chart = ChartFactory.createPieChart(
						title,		// title
						dataset,	// data
						false, 	// legend?
						true, 		// tooltips?
						false 		// URLs?
				);

				//Add transparancy
				PiePlot p = (PiePlot)chart.getPlot();

				//Set label font size
				Font f = p.getLabelFont(); 
				p.setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
				
		} else {
				chart = ChartFactory.createPieChart3D(
						title,		// title
						dataset,	// data
						false, 	// legend?
						true, 		// tooltips?
						false 		// URLs?
				);		
				
				//Add transparancy
				PiePlot3D p = (PiePlot3D)chart.getPlot();
				p.setForegroundAlpha(transparency);
			
				//Set label font size
				Font f = p.getLabelFont(); 
				p.setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		}
		
		return chart;
	}
//	--------------------------------------------------------------------------------	
	private JFreeChart createLineChart(){
		// create dataset
		DefaultCategoryDataset dataset = new DefaultCategoryDataset();
		
		JFreeChart chart = null;
		
		if(type == ChartType.LINE){
			chart = ChartFactory.createLineChart(
				title,						// chart title
				xlabel, 					// domain axis label
				"",							// range axis label
				dataset, 					// data
				PlotOrientation.VERTICAL, 	// orientation
				false, 					// include legend
				true, 						// tooltips
				false 						// urls
			);
		}else{
			chart = ChartFactory.createLineChart3D(
					title,						// chart title
					xlabel, 					// domain axis label
					"",							// range axis label
					dataset, 					// data
					PlotOrientation.VERTICAL, 	// orientation
					false, 					// include legend
					true, 						// tooltips
					false 						// urls
				);
		}
		// plot options
		CategoryPlot plot = chart.getCategoryPlot();
		plot.setBackgroundPaint(Color.white);
		plot.setRangeGridlinePaint(Color.lightGray);
		plot.setForegroundAlpha(transparency);
		
		//Set the label fontsize
		Font f = plot.getDomainAxis().getLabelFont(); 
		plot.getDomainAxis().setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getDomainAxis().getTickLabelFont(); 
		plot.getDomainAxis().setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getRangeAxis().getLabelFont(); 
		plot.getRangeAxis().setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getRangeAxis().getTickLabelFont(); 
		plot.getRangeAxis().setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));

		LineAndShapeRenderer renderer = (LineAndShapeRenderer)plot.getRenderer();
		renderer.setBaseShapesVisible(true);
		renderer.setDrawOutlines(true);
		renderer.setUseFillPaint(true);
		renderer.setBaseFillPaint(Color.white);

		return chart;
	}

//	--------------------------------------------------------------------------------	
	private JFreeChart createXYAreaChart(){
		// create dataset
		DefaultTableXYDataset dataset = new DefaultTableXYDataset();

		JFreeChart chart = null;
		
		chart = ChartFactory.createXYAreaChart(
				title,						// chart title
				xlabel, 					// domain axis label
				"",							// range axis label
				dataset, 					// data
				PlotOrientation.VERTICAL, 	// orientation
				false, 					// include legend
				true, 						// tooltips
				false 						// urls
		);			

		// plot options
		XYPlot plot = chart.getXYPlot();
		plot.setBackgroundPaint(Color.white);
		plot.setRangeGridlinePaint(Color.lightGray);
		
		//force scientific notation
		NumberAxis domAxis = (NumberAxis)plot.getDomainAxis();
		NumberAxis ranAxis = (NumberAxis)plot.getRangeAxis();

		domAxis.setNumberFormatOverride(formatter);
		ranAxis.setNumberFormatOverride(formatter);

		//Set the label fontsize
		Font f = domAxis.getLabelFont(); 
		domAxis.setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = domAxis.getTickLabelFont();
		domAxis.setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = ranAxis.getLabelFont(); 
		ranAxis.setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = ranAxis.getTickLabelFont();
		ranAxis.setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));

		XYAreaRenderer renderer = (XYAreaRenderer)plot.getRenderer();
		renderer.setBaseFillPaint(Color.white);
		
		return chart;
	}
//	--------------------------------------------------------------------------------	
	private JFreeChart createStackedXYAreaChart(){
		// create dataset
		DefaultTableXYDataset dataset = new DefaultTableXYDataset();

		JFreeChart chart = ChartFactory.createStackedXYAreaChart(
					title,						// chart title
					xlabel, 					// domain axis label
					"",							// range axis label
					dataset, 					// data
					PlotOrientation.VERTICAL, 	// orientation
					false, 					// include legend
					true, 						// tooltips
					false 						// urls
		);		

		// plot options
		XYPlot plot = chart.getXYPlot();
		plot.setBackgroundPaint(Color.white);
		plot.setRangeGridlinePaint(Color.lightGray);
		
		//force scientific notation
		NumberAxis domAxis = (NumberAxis)plot.getDomainAxis();
		NumberAxis ranAxis = (NumberAxis)plot.getRangeAxis();

		domAxis.setNumberFormatOverride(formatter);
		ranAxis.setNumberFormatOverride(formatter);

		//Set the label fontsize
		Font f = domAxis.getLabelFont(); 
		domAxis.setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = domAxis.getTickLabelFont();
		domAxis.setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = ranAxis.getLabelFont(); 
		ranAxis.setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = ranAxis.getTickLabelFont();
		ranAxis.setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));

		return chart;
	}
//	--------------------------------------------------------------------------------	
	private JFreeChart createBarChart(){
		// create dataset
		DefaultCategoryDataset dataset = new DefaultCategoryDataset();
		JFreeChart chart = null;
		
		if(type == ChartType.BAR){
		
			chart = ChartFactory.createBarChart(
					title,						// chart title
					xlabel, 					// domain axis label
					"",							// range axis label
					dataset, 					// data
					PlotOrientation.VERTICAL, 	// orientation
					false, 					// include legend
					true, 						// tooltips
					false 						// urls
			);				
		}else{
			chart = ChartFactory.createBarChart3D(
					title,						// chart title
					xlabel, 					// domain axis label
					"",							// range axis label
					dataset, 					// data
					PlotOrientation.VERTICAL, 	// orientation
					false, 					// include legend
					true, 						// tooltips
					false 						// urls
			);
		}

		// plot options
		CategoryPlot plot = chart.getCategoryPlot();
		plot.setBackgroundPaint(Color.white);
		plot.setRangeGridlinePaint(Color.lightGray);
		
		//Set the label fontsize
		Font f = plot.getDomainAxis().getLabelFont(); 
		plot.getDomainAxis().setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getDomainAxis().getTickLabelFont(); 
		plot.getDomainAxis().setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getRangeAxis().getLabelFont(); 
		plot.getRangeAxis().setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getRangeAxis().getTickLabelFont(); 
		plot.getRangeAxis().setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));

		
		//Add transparancy
		plot.setForegroundAlpha(transparency);
		return chart;
	}
//	--------------------------------------------------------------------------------	
	private JFreeChart createStackedBarChart(){
		// create dataset
		DefaultCategoryDataset dataset = new DefaultCategoryDataset();

		JFreeChart chart = ChartFactory.createStackedBarChart(
					title,						// chart title
					xlabel, 					// domain axis label
					"",							// range axis label
					dataset, 					// data
					PlotOrientation.VERTICAL, 	// orientation
					false, 						// include legend
					true, 						// tooltips
					false 						// urls
			);							

		// plot options
		CategoryPlot plot = chart.getCategoryPlot();
		plot.setBackgroundPaint(Color.white);
		plot.setRangeGridlinePaint(Color.lightGray);
		
		//Set the label fontsize
		Font f = plot.getDomainAxis().getLabelFont(); 
		plot.getDomainAxis().setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getDomainAxis().getTickLabelFont(); 
		plot.getDomainAxis().setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getRangeAxis().getLabelFont(); 
		plot.getRangeAxis().setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getRangeAxis().getTickLabelFont(); 
		plot.getRangeAxis().setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		
		StackedBarRenderer renderer = (StackedBarRenderer)plot.getRenderer();
		renderer.setItemMargin(0);
		
		return chart;
	}
//	--------------------------------------------------------------------------------	
	private JFreeChart createLevelChart(){
		// create dataset
		DefaultTableXYDataset dataset = new DefaultTableXYDataset();

		JFreeChart chart = ChartFactory.createStackedXYAreaChart(
					title,						// chart title
					xlabel, 					// domain axis label
					"",							// range axis label
					dataset, 					// data
					PlotOrientation.VERTICAL, 	// orientation
					false, 						// include legend
					true, 						// tooltips
					false 						// urls
		);		

		// plot options
		XYPlot plot = chart.getXYPlot();
		plot.setBackgroundPaint(Color.white);
		plot.setRangeGridlinePaint(Color.lightGray);
		
		//Set the label fontsize
		Font f = plot.getDomainAxis().getLabelFont(); 
		plot.getDomainAxis().setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getDomainAxis().getTickLabelFont(); 
		plot.getDomainAxis().setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getRangeAxis().getLabelFont(); 
		plot.getRangeAxis().setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = plot.getRangeAxis().getTickLabelFont(); 
		plot.getRangeAxis().setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));

		
		StackedXYAreaRenderer2 renderer = (StackedXYAreaRenderer2)plot.getRenderer();
		Paint[] paints = makeGrayscalePaints(yDescriptions.length);
		for (int i = 0; i < paints.length; i++) {
			renderer.setSeriesPaint(i, paints[i]);
		}
				
		return chart;
	}
//	--------------------------------------------------------------------------------	

	private JFreeChart createXYChart(){
		// create dataseries
		DefaultTableXYDataset dataset = new DefaultTableXYDataset();
		
		// create the chart...
		JFreeChart chart = ChartFactory.createXYLineChart(
				title,				 		// chart title
				xlabel,		 				// x axis label
				"",							// y axis label
				dataset, 					// data
				PlotOrientation.VERTICAL,	// orientation
				false, 					// include legend
				true, 						// tooltips
				false 						// urls
		);			
	
		// plot options
		XYPlot plot = chart.getXYPlot();
		//plot.setRenderer(new XYSplineRenderer());
		plot.setBackgroundPaint(Color.white);
		plot.setRangeGridlinePaint(Color.lightGray);
		
		//force scientific notation
		NumberAxis domAxis = (NumberAxis)plot.getDomainAxis();
		NumberAxis ranAxis = (NumberAxis)plot.getRangeAxis();
		domAxis.setNumberFormatOverride(formatter);
		ranAxis.setNumberFormatOverride(formatter);

		//Set the label fontsize
		Font f = domAxis.getLabelFont(); 
		domAxis.setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = domAxis.getTickLabelFont();
		domAxis.setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = ranAxis.getLabelFont(); 
		ranAxis.setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = ranAxis.getTickLabelFont();
		ranAxis.setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		
		// renderer options
		XYLineAndShapeRenderer renderer = (XYLineAndShapeRenderer) plot.getRenderer();
		renderer.setBaseShapesVisible(true);
		renderer.setDrawOutlines(true);
		renderer.setUseFillPaint(true);
		renderer.setBaseFillPaint(Color.white);
		
		return chart;
	}
//	--------------------------------------------------------------------------------	

	private JFreeChart createScatterChart(){
		// create dataseries
		DefaultTableXYDataset dataset = new DefaultTableXYDataset();
		
		// create the chart...
		JFreeChart chart = ChartFactory.createScatterPlot(
				title,				 		// chart title
				xlabel,		 				// x axis label
				"",							// y axis label
				dataset, 					// data
				PlotOrientation.VERTICAL,	// orientation
				false, 					// include legend
				true, 						// tooltips
				false 						// urls
		);			
	
		// plot options
		XYPlot plot = chart.getXYPlot();
		plot.setBackgroundPaint(Color.white);
		plot.setRangeGridlinePaint(Color.lightGray);
		
		//force scientific notation
		NumberAxis domAxis = (NumberAxis)plot.getDomainAxis();
		NumberAxis ranAxis = (NumberAxis)plot.getRangeAxis();
		domAxis.setNumberFormatOverride(formatter);
		ranAxis.setNumberFormatOverride(formatter);

		//Set the label fontsize
		Font f = domAxis.getLabelFont(); 
		domAxis.setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = domAxis.getTickLabelFont();
		domAxis.setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = ranAxis.getLabelFont(); 
		ranAxis.setLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		f = ranAxis.getTickLabelFont();
		ranAxis.setTickLabelFont(new Font(f.getName(),f.getStyle(),fontSize));
		
		// renderer options
		XYLineAndShapeRenderer renderer = (XYLineAndShapeRenderer) plot.getRenderer();
		renderer.setBaseShapesVisible(true);
		renderer.setDrawOutlines(true);
		renderer.setUseFillPaint(true);
		renderer.setBaseFillPaint(Color.white);
		
		return chart;
	}
//	--------------------------------------------------------------------------------	
	private Paint[] makeGrayscalePaints(int count) {
		Paint[] paints = new Paint[count];
		for ( int i=count;i>0;i-- )
		{
			float x = (float) (((double)(count-i) / (double)count * .6 ) + .2); 
			paints[count - i] = new Color( x, x, x, 1.0f );
		}
			
		return paints;
	}
	
//--------------------------------------------------------------------------------		
	public JFreeChart getChart(){
		return this.chart;
	}
//	--------------------------------------------------------------------------------		
	public ChartType getType() {
		return type;
	}
//	--------------------------------------------------------------------------------		
	public void setType(ChartType t) {
		type = t;
	}
//--------------------------------------------------------------------------------		
	public void update(ProfileRecord<Double> rec, int xAxisID, int[] yAxisID) {
		//System.out.println("Builder updating " + type);
		
		double xvalue = 0;
		double yvalue = 0;
			
		if (type.holds(ChartType.PIE)) {
			PiePlot pl = (PiePlot)chart.getPlot();
			DefaultPieDataset dataset = (DefaultPieDataset)pl.getDataset();
			
			// loop over all columns
			for (int j = 0; j < yAxisID.length; j++) {
				dataset.setValue(yDescriptions[j],rec.getValue(yAxisID[j]));
			}
			
		} else if (type.holds(ChartType.LINE) || type.holds(ChartType.BAR)){
			CategoryPlot pl = chart.getCategoryPlot();
			DefaultCategoryDataset dataset = (DefaultCategoryDataset)pl.getDataset();
			
			if(xAxisID == -1){
				// in this case the dataset is only 1D, we only have y-values
				// so as x-values, simply use a counter starting from 0
				yvalue = rec.getValue(yAxisID[0]);
				dataset.setValue(yvalue, yDescriptions[0], new Double(dataset.getColumnCount()));
			}else{
				// loop over all columns
				for (int j = 0; j < yAxisID.length; j++) {
					yvalue = rec.getValue(yAxisID[j]);
					dataset.setValue(yvalue, yDescriptions[j], new Double(rec.getValue(xAxisID)));
				}
			}
			
		} else if (type.holds(ChartType.AREA) || type == ChartType.XY || type == ChartType.SCATTER) {
			XYPlot xp = chart.getXYPlot();
			DefaultTableXYDataset ds = (DefaultTableXYDataset)xp.getDataset();
			
			//is this the first time?
			if(ds.getItemCount() < 1){
				XYSeriesCollection series = new XYSeriesCollection();
				for (int i = 0; i < yAxisID.length; i++) {
					series.addSeries(new XYSeries(yDescriptions[i],false,false));
				}

				if(xAxisID == -1){
					// in this case the dataset is only 1D, we only have y-values
					// so as x-values, simply use a counter starting from 0
					xvalue = 0;
				}else{
					xvalue = rec.getValue(xAxisID);
				}
				
				for (int j = 0; j < yAxisID.length; j++) {
					yvalue = rec.getValue(yAxisID[j]);
					series.getSeries(j).addOrUpdate(xvalue, yvalue);
				}
		
				// add series to dataset
				for (int i = 0; i < yAxisID.length; i++) {
					ds.addSeries(series.getSeries(i));
				}
			}else{
				if(xAxisID == -1){
					// in this case the dataset is only 1D, we only have y-values
					// so as x-values, simply use a counter starting from 0
					xvalue = ds.getItemCount();
				}else{
					xvalue = rec.getValue(xAxisID);
				}

				for (int j = 0; j < yAxisID.length; j++) {
					yvalue = rec.getValue(yAxisID[j]);
					ds.getSeries(j).addOrUpdate(xvalue, yvalue);
				}
			}
		}else{
			logger.severe("Invalid chart type '" + type + "', update failed");
		}
	}
	
	static public void writeChartAsEPS(File name, JFreeChart chart, int width, int height) throws IOException {
        VectorGraphics g = new PSGraphics2D(name, new Dimension(width,height));
        Rectangle2D r2d = new Rectangle2D.Double(0, 0, width, height);
        g.startExport();
        chart.draw(g, r2d);
        g.endExport();
	}
	 
	static public void writeChartAsPDF(File name, JFreeChart chart, int width, int height) throws IOException {
        VectorGraphics g = new PDFGraphics2D(name, new Dimension(width,height));
        Rectangle2D r2d = new Rectangle2D.Double(0, 0, width, height);
        g.startExport();
        chart.draw(g, r2d);
        g.endExport();
	}

	static public void writeChartAsSVG(File name, JFreeChart chart, int width, int height) throws IOException {
        VectorGraphics g = new SVGGraphics2D(name, new Dimension(width,height));
        Rectangle2D r2d = new Rectangle2D.Double(0, 0, width, height);
        g.startExport();
        chart.draw(g, r2d);
        g.endExport();
	}

}
