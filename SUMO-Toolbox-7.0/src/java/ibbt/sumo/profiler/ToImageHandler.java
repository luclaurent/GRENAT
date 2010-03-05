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
** Revision: $Id: ToImageHandler.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.config.NodeConfig;
import ibbt.sumo.util.Util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jfree.chart.ChartUtilities;


/**
 * This outputhandlers dumps it's jcharted image to a png file
 */
public class ToImageHandler extends OutputHandler {

	private static Logger logger = Logger.getLogger("ibbt.sumo.profiler.ToImageHandler");	

	private String fFilename = null;
	private enum ImageType {JPG, PNG, EPS, PDF, SVG};
	private ImageType type = null;
	private ToChartsHandler chartHandler = null;
	
	public ToImageHandler(Profiler p, NodeConfig conf) {
		super(p,conf);
		chartHandler = new ToChartsHandler(p,conf);
		
		// get the file extension
		String extension = conf.getOption("extension","png").toLowerCase();
		
		if(extension.equals("png")){
			type = ImageType.PNG;
		}else if(extension.equals("jpg")){
			type = ImageType.JPG;
		}else if(extension.equals("jpeg")){
			type = ImageType.JPG;
		}else if(extension.equals("eps")){
			type = ImageType.EPS;
		}else if(extension.equals("pdf")){
			type = ImageType.PDF;
		}else if(extension.equals("svg")){
			type = ImageType.SVG;
		}else{
			type = ImageType.PNG;
			logger.warning("Invalid or unsupported image extension " + extension + " defaulting to png");
		}

		// Build the filename
		fFilename = p.getOutputDirectory() + File.separator + "profilers" + File.separator + p.getName() + "." + extension;
		
		//TODO this ignores any user specified config
		//Export a large image with large fonts
		chartHandler.setHeight((int)Math.round(chartHandler.getHeight()*1.5));
		chartHandler.setWidth((int)Math.round(chartHandler.getWidth()*1.5));
		chartHandler.setFontSize(14);
	}
	
	/**
	 * Initialize the output handler
	 */
	public void begin() {
		chartHandler.begin();
	}
//--------------------------------------------------------------------------------	
	/**
	 * Save the chart to disk
	 */
	public void update(ProfileRecord rec) { 	
		//update the chart
		chartHandler.update(rec);
	
		//save the chart to disk
		File file = new File(fFilename);
		FileOutputStream fout = null;
		try{         
			fout = new FileOutputStream(file);
			
			switch (type) {
			case JPG:
				ChartUtilities.writeChartAsJPEG(fout,chartHandler.getChart(), chartHandler.getWidth(), chartHandler.getHeight());
				break;
			case PNG:
				ChartUtilities.writeChartAsPNG(fout, chartHandler.getChart(), chartHandler.getWidth(), chartHandler.getHeight());
				break;
			case EPS:
				JFreeChartBuilder.writeChartAsEPS(file, chartHandler.getChart(), chartHandler.getWidth(), chartHandler.getHeight());
				break;
			case PDF:
				JFreeChartBuilder.writeChartAsPDF(file, chartHandler.getChart(), chartHandler.getWidth(), chartHandler.getHeight());
				break;
			case SVG:
				JFreeChartBuilder.writeChartAsSVG(file, chartHandler.getChart(), chartHandler.getWidth(), chartHandler.getHeight());
				break;

			default:
				logger.warning("Invalid chart type " + type + " specified");
				break;
			}

		}catch(IOException e){
			logger.log(Level.SEVERE,e.getMessage(),e);	
		}finally{
			// always close the file stream again
			Util.close(fout);
		}
	}
//--------------------------------------------------------------------------------		
	/**
	 * Cleanup
	 */
	public void end() {
		chartHandler.end();
	}
//--------------------------------------------------------------------------------		
}
