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
** Revision: $Id: ProfilerManager.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.SUMOException;
import ibbt.sumo.config.NodeConfig;
import ibbt.sumo.util.Pair;
import ibbt.sumo.util.Util;

import java.util.Hashtable;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Logger;
import java.util.regex.Pattern;

import org.dom4j.Element;
import org.dom4j.Node;

/**
 * This class creates and manages all the Profilers. This class contains of a number of static
 * It also applies settings from the configfile to the accurate profiles 
 * 
 * PROFILER MANUAL
 * ---------------
 * 
 * Note: Profilers only work at the run level, it ain't possible to put results of
 * different runs in one profiler.
 * 
 * A. INPUT
 * The first step is to create a profiler and set up its columns
 * 
 * 		import ibbt.sumo.profiler.*
 * 		profiler = ProfilerManager.getProfiler('<profilername>');
 * 		profiler.setDescription('<desc>');
 *		profiler.addColumn('<columnname1>', '<columndescription1>');
 *		profiler.addColumn('<columnname2>', '<columndescription2>');
 *		...
 * 	The description is optional.
 *
 * After the profiler has been setup, filling it up with data can be done in a few ways:
 * 	1. profiler.addEntry([<value1>, <value2>, ...]);
 * 		this adds a new row to the table and fills it up with data specified in the arguments
 * 
 * B. OUTPUT
 * Writing profiled data to the output handlers through the config file:
 *		
 *			- main tag:
 *				<profiling>...</profiling>
 *			- a main tag consists of a series of profilertags: 
 *				<profiler name="<profilername>" enabled="<true/false>">
 *			- each profiler can contain a number of outputs with matching options:
 *				<output type="toFile">
 *					<option key="filename" value="<filename>"/> 		"<profilername>.txt is" used if this is not specified
 *				</output>
 *				<output type="toPanel">
 *					<option key="columns" value="<seriesOfNumbers"/> 	which columns are plotted. the first digit is the x-axis, the others the y-axis, "1,2,3,..." is used as default
 *				</output> 			   			  
 *				<output type="toImage">
 *					<option key="filename" value="<filename>"/> 		see above
 *					<option key="columns" value="<seriesOfNumbers"/> 	see above
 *				</output> 
 *			  
 *	Config example:
 *		<Profiling>
 *			<Profiler name="testProfiler" enabled="true">
 *				<Output type="toFile"/>
 *				<Output type="toImage">
 *					<Option key="filenamePrefix" value="testP"/>
 *					<Option key="columns" value="0,1"/>
 *				</Output>		
 *				<Output type="toPanel"/>
 *			</Profiler>
 *		</Profiling>
 */
public class ProfilerManager {
// PRIVATE STATIC FIELDS
//	--------------------------------------------------------------------------------	
		

	// alive profilers
	private static Hashtable<String,Profiler> fProfilers = new Hashtable<String,Profiler>();

	// RAW CONFIGS
	// config of the profilers
	private static NodeConfig fConfig;
	// config of the run
	//private static ContextConfig fContextConfig;
	
	// DATA EXTRACTED FROM THE CONFIGS
	// which profilers are enabled
	private static List<Pair<Pattern,Node>> fSelectedProfilers = new LinkedList<Pair<Pattern,Node> >();
	private static String fOutputDirectory;
	
	// Name of this profiler group
	private static String title = null;
	
	//logger
	private static Logger logger = Logger.getLogger("ibbt.sumo.util.ProfilerManager");

	private static DockedView fDockedView = null;
	private static boolean fIsEnabled = true;
	
	
// PUBLIC STATIC FUNCTIONS
//--------------------------------------------------------------------------------
	/**
	 * Configure the profiler with xml data
	 * @param config  run information
	 * @param context dom4j node containing the xml file
	 */
	@SuppressWarnings("unchecked")
	public static void initialize(NodeConfig config, String dir, String tit) {
		
		if (!fIsEnabled)
			return;
		
		logger.info("Configuring the ProfilerManager");
		
		title = tit;
		
		if (config == null) {
			logger.warning("Profiler tag not found in XML configuration");
			return;
		}		

		fConfig = config; 
		fOutputDirectory = dir;
		
		// clear all profilers and manager data
	    for(Profiler p : fProfilers.values()){
	    	p.clear();
	    }
		fProfilers.clear();
		fSelectedProfilers.clear();

		// Initialize the docked view (if present)
		clearDockedView();
				
		// set the list of enabled profilers
		List<Element> selectedProfilers = fConfig.selectNodes("Profiler");
		
		for (Element el : selectedProfilers) {
			String name = el.attributeValue("name");
			String enabled = el.attributeValue("enabled");
			
			if (Boolean.valueOf(enabled)) {
				fSelectedProfilers.add(new Pair<Pattern,Node>( Pattern.compile( name ), el));
			}
		}
	}
//--------------------------------------------------------------------------------
	public static boolean exists(String name){
		return fProfilers.containsKey(name);
	}
//--------------------------------------------------------------------------------
/**
 * Add a numeric suffix to the profiler name to make it unique
 */
	public static String makeUniqueProfilerName(String profname){
		if(!fIsEnabled) return profname; 
	
		if(exists(profname)){
			//System.out.println(profname + " is NOT unique");
			int suffix = 1;
			profname = profname + "_0" + suffix;
			
			while(ProfilerManager.exists(profname)){
				if(suffix > 9){
					profname = profname.substring(0,profname.length()-2) + "_" + suffix;
				}else{
					profname = profname.substring(0,profname.length()-2) + "_0" + suffix;
				}
				++suffix;
			}
		}else{
			//System.out.println(profname + " is already unique...");
		}
		
		//System.out.println("returning " + profname);
		return profname;
	}
//	--------------------------------------------------------------------------------

	/**
	 * get a profiler
	 * @param name the ID of the profiler, if it doesn't exist, create a new one
	 * @return the profiler
	 */
	public static Profiler getProfiler(String name) {
		if (!fIsEnabled) {
			// return dummy profiler
			return new Profiler("dummy", fOutputDirectory);
		}
			
		// if profiler already exists, just return it
		if (exists(name)) {
			logger.fine("Got existing profiler " + name);
			return fProfilers.get(name);

		// if it doesn't, create one first
		} else {
			Profiler p = new Profiler(name, fOutputDirectory);		
			
			// if it's turned off, or simply isn't configured, just return an empty one
			Node selected = findSelectedConfig(name);
			if (selected == null) {
				p.setEnabled(false);
				logger.fine("New profiler " + name + " is disabled, not added");
			// else configure it with the given options
			} else {
				p.setEnabled(true);
				p.configure(selected);
				fProfilers.put(name, p);
			}				
			return p;		
		}
	}
//--------------------------------------------------------------------------------	
	private static Node findSelectedConfig(String name) {
		for (Pair<Pattern,Node> item : fSelectedProfilers) {
			// Read this ;)  Try to match the pattern to the profiler's name...
			//System.out.println( name + "  < - >  " + item.getFirst().pattern() );
			if ( item.getFirst().matcher(name).matches() ) {
				//System.out.println( "MATCH !!!" );
				return item.getSecond();
			}
		}
		return null;
	}
//--------------------------------------------------------------------------------	
	public static boolean isEnabled( String name ) {
		if(exists(name)){
			return fProfilers.get(name).isEnabled();
		}else{
			return false;
		}
	}
//--------------------------------------------------------------------------------
	public static void enable(boolean b) {
		fIsEnabled = b;
		
		if (b) {
			logger.info("enabled ProfilerManager");
		} else {
			logger.info("disabled ProfilerManager");
		}
	}	
//--------------------------------------------------------------------------------
	/**
	 * Clear the docked view
	 */
	public static void clearDockedView(){
		if (fDockedView != null && fIsEnabled){
			fDockedView.clear();
			fDockedView.setWindowTitle(title);
		}

	}
//--------------------------------------------------------------------------------
	/**
	 * Tell all the profilers to clean up
	 */
	public static void finish() throws  SUMOException {
		logger.info("Flushing all profilers...");
		
		for(Profiler p : fProfilers.values()){
			p.finalizeOutput();
		}
	}
//--------------------------------------------------------------------------------
	public static DockedView getDockedView() {
		if ( fDockedView == null && !Util.isHeadless()){
			fDockedView = new DockedView(title);
		}
		
		return fDockedView;		
	}
//--------------------------------------------------------------------------------
	
}
