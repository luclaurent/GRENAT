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
** Revision: $Id: ToFileHandler.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.config.ContextConfig;
import ibbt.sumo.util.Util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Saves profiled data to a text file
 */
public class ToFileHandler extends OutputHandler {
	private String filename = "";
	private PrintWriter fFileWriter;
	private DecimalFormat formatter = null;
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.profiler.ToFileHandler");	

	public ToFileHandler(Profiler p, ibbt.sumo.config.NodeConfig conf) { 
		super(p,conf);
		filename = conf.getOption("filenamePrefix", p.getName());
		filename =  p.getOutputDirectory() + File.separator + "profilers" + File.separator + filename + ".txt";
		
		//Enforce scientific notation and force a '.', never allow ','
		formatter = (DecimalFormat)NumberFormat.getInstance();
		formatter.applyPattern("0.000000000E0###");
	}
	
	/**
	 * Initialize the output handler and the output file
	 */
	public void begin() {
		fFileWriter = null;
		
		try {
			fFileWriter = new PrintWriter(new FileOutputStream(filename));
			
			// print information from the config file
			fFileWriter.println("% ----------------------------------------------------------------------------");
			fFileWriter.println("% This file contains profiled data created with the SUMO Toolbox profiler v" + ContextConfig.getToolboxVersion());
			fFileWriter.println("% ");

			fFileWriter.println("%   * Name: " + getProfiler().getName());
			fFileWriter.println("%   * Description: " + getProfiler().getDescription());
			// date
			fFileWriter.print("%   * Date: ");
			SimpleDateFormat dateformat3 = new SimpleDateFormat("dd/MM/yyyy");
			SimpleDateFormat dateformat4 = new SimpleDateFormat("HH");
			SimpleDateFormat dateformat5 = new SimpleDateFormat("mm");
			fFileWriter.println(dateformat3.format(new Date()) + " at " + dateformat4.format(new Date()) + ":" + dateformat5.format(new Date()));

			fFileWriter.println("% ");
			for (int i = 0; i < getProfiler().getColumnCount(); i++) {
				fFileWriter.print("%   * Column" + (i+1) + ": " + '\t');
				fFileWriter.print(getProfiler().getColumnName(i));
				String desc = getProfiler().getColumnDescription(i);
				if (desc != null && desc.compareTo("null") != 0){
					fFileWriter.print(": " + '\t' + desc);
				}
				fFileWriter.println();
			}
			fFileWriter.println("%");
			fFileWriter.println("% ----------------------------------------------------------------------------");
			fFileWriter.println();		
			
			fFileWriter.flush();
		} catch (Exception e) {
			String msg = e.getMessage();
			if(msg == null) msg = "NullPointerException occurred";
			logger.log(Level.SEVERE,"Error during toFileHandler initialization, message: " + msg,e);			
		}		

	}
//--------------------------------------------------------------------------------	
	/**
	 * Update the file with the latest new rows
	 */
	public void update(ProfileRecord rec) { 		
		Object val;
		
		try {
			for (int c = 0; c < rec.dimension(); c++) {
					val = rec.getValue(c);
					if(val instanceof Number){
						fFileWriter.print(formatter.format(val) + '\t');
					}else{
						fFileWriter.print(val + "\t");
					}
			}
			fFileWriter.println();
			fFileWriter.flush();
		} catch (Exception e) {
			logger.log(Level.SEVERE, e.getMessage(), e);					
		}			
	}
//--------------------------------------------------------------------------------		
	/**
	 * close the file
	 */
	public void end() {
		Util.close(fFileWriter);
	}
//--------------------------------------------------------------------------------
}
