package ibbt.sumo.config;
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
** Revision: $Id: ContextConfig.java 6385 2009-12-11 14:26:13Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.SUMOException;
import ibbt.sumo.profiler.ProfilerManager;
import ibbt.sumo.util.HiddenFileFilter;
import ibbt.sumo.util.SUMOFileFormatter;
import ibbt.sumo.util.SUMOFormatter;
import ibbt.sumo.util.SystemArchitecture;
import ibbt.sumo.util.SystemPlatform;
import ibbt.sumo.util.Util;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Properties;
import java.util.logging.ConsoleHandler;
import java.util.logging.FileHandler;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.LogManager;
import java.util.logging.Logger;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.Node;

/**
 * An important class that holds globally important configuration information and
 * plays a large role in bootstrapping the toolbox.
 */
public class ContextConfig {

	private static Logger logger = null;
	private static Handler generalFilehandler = null;
	private static boolean fRunsInMainLog = false;	
	private Handler runFileHandler = null; 
	
	private String runName;
	private int curRunNumber = -1;
	private String fOutputDirectory;
	private String fProjectDirectory;
	private static String fRootDirectory;
	private SystemPlatform fPlatform; // Platform name
	private SystemArchitecture fArch; // Architecture
	private boolean fSamplingEnabled = true;
	private boolean fKeepOldModels = false;
	private boolean fParallelMode = false;

	private List<File> fSearchPath = new LinkedList<File>();
	
	private Document fFullConfig;
	private SimulatorConfig fSimulatorConfig;
	private BasicInputConfig inputConfig;
	private BasicOutputConfig outputConfig;
	
	private NodeConfig fPlotOptions;
	
	// ----- Important Constants -----
	// Toolbox version
	private static final String SUMO_VERSION = "7.0";
	//Toolbox homepage
	private static final String SUMO_HOMEPAGE = "http://www.sumowiki.intec.ugent.be";
	// SUMO icon
	private static final String SUMO_ICON_NAME = "sumo.ico";
	// Code revision
	private static final String SUMO_REVISION = "$Rev: 6385 $";
	// -------------------------------

//	-------------------------------------------------------------------------------------	
	@SuppressWarnings("unchecked")
	public static ContextConfig getContextConfigInstance( Document doc, List runConfig, int runNr ) throws SUMOException {
		try{
			//silly workaround, see: http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=4327286
			com.sun.media.util.Registry.set("secure.allowSaveFileFromApplets", Boolean.TRUE);
		}catch(NoClassDefFoundError e){
			logger.warning("The extension pack is not installed, movie creation will not work properly (jmf.jar missing)");
		}
		
		// read context config
		String id = ConfigUtil.getTagTextByName(runConfig, "ContextConfig");
		Element config = (Element)ConfigUtil.resolveReference(doc, "ContextConfig", id);
		
		if(config == null){
			throw new SUMOException("No <ContextConfig> tag found (declaration or definition), you must always specify one!");
		}
				
		//Get the toolbox version as specified in the XML file
		String vXML = ConfigUtil.getToolboxVersion(doc);
		
		if(vXML.length() < 1){
			logger.warning("No version specified in the toolbox configuration file, assuming " + SUMO_VERSION);
			vXML = SUMO_VERSION;
		}
		
		//Get the toolbox version as declared in ContextConfig
		String vCtxt = SUMO_VERSION;
		
		if(!vXML.equals(vCtxt)){
			logger.severe("Version mismatch! Your toolbox configuration file is at v" + vXML + " while the toolbox itself is at v" + vCtxt + " trying to continue anyway...");
		}
		
		//Clear docked view if present from previous runs
		ProfilerManager.clearDockedView();
		
		// return the initialized context object
		return new ContextConfig(NodeConfig.newInstance(config ), doc, runConfig, runNr);
	}
//	-------------------------------------------------------------------------------------
	@SuppressWarnings("unchecked")
	public ContextConfig(NodeConfig n, Document doc, List runConfig,int runNr) throws SUMOException {

		// We are in ContextConfig::Ctor
		logger.fine("Starting ContexConfig object construction");

		// Set the default locale (e.g., use the point as the decimal separator)
		Locale.setDefault(Locale.UK);
	
		// Store parameters
		fFullConfig = doc;
		curRunNumber = runNr;
		
		// Add default search paths when resolving projects
		addToPath(new File(getRootDirectory() + File.separator + "examples"), true);

		// Resolve and parse the simulator config
		Element simulator = (Element)ConfigUtil.getTagByName(runConfig, "Simulator");
		if( simulator == null )
			throw new SUMOException( "No simulator specified! You must specify a <Simulator> tag in order for the toolbox to run" );

		String simulatorPath = Util.cleanFileSeparators(simulator.getText());
		// Setup the project directory
		File simFile = resolveSimulatorFile(simulatorPath);
		
		fSimulatorConfig = new SimulatorConfig(simFile);
		logger.info("Loaded simulator file " + simFile.getName() + " from project directory " + fProjectDirectory);
		
		// set the configuration of the inputs and outputs
		inputConfig = new BasicInputConfig(runConfig, fSimulatorConfig);
		outputConfig = new BasicOutputConfig(runConfig, fSimulatorConfig);
		
		// Is sample selection enabled?
		fSamplingEnabled = ConfigUtil.samplingEnabled(runConfig);
		
		// Build the output directory where all results will be stored
		// First resolve all the placeholders in the run name
		String rawRunName = ConfigUtil.getRunName(doc, runNr);
		runName = composeRunName(rawRunName, runConfig);
		logger.log( Level.INFO, "Run name set to " + runName );
		
		//Get the output directory
		String rootDir = ContextConfig.getRootDirectory();
		String odir = n.getNodeText("OutputDirectory","output");
		odir = odir.replaceFirst("#SUMO_HOME#", rootDir);
		
		// Now generate a unique name
		int numRuns = ConfigUtil.getNumberOfRuns(doc);
		fOutputDirectory = Util.getAbsolutePath(odir, getProjectDirectory() );
		fOutputDirectory = Util.generateOutputDirectoryName(fOutputDirectory, runName, runNr, numRuns );
		
		// Setup the profilers
		setupProfilers(n,runName);
		
		// Instantiate any plot option configuration
		Node plotnode = n.selectSingleNode("PlotOptions");
		if (plotnode != null){
			fPlotOptions = NodeConfig.newInstance(plotnode);
		}else{
			fPlotOptions = null;
		}
		
		// Set fPlatform property:		
		fPlatform = Util.getPlatform();
	
		// Set fArch property:		
		fArch = Util.getArchitecture();
	
		// Are we keeping old models instead of resetting the score
		fKeepOldModels = n.getBooleanOption("keepOldModels", false);
		// If the Matlab parallel computing toolbox is available, should we run in parallel where possible?
		fParallelMode = n.getBooleanOption("parallelMode", false);
		
		// initialize this run (enables run logger too)
		initializeRun();
	}
//	-------------------------------------------------------------------------------------
	private File resolveSimulatorFile(String simulatorPath) throws SUMOException {
		File simFile = new File(simulatorPath);

		//Fistly, does the simulator path contain an xml filename
		if(simulatorPath.toUpperCase().endsWith(".XML")){
			//Secondly, does the path contain a directory (= project)
			if(simulatorPath.contains(File.separator)){
				//Yes it does, this means we are specifying a particular xml file inside a project dir
				
				//is it an absolute path?
				if(simFile.isAbsolute()){
					fProjectDirectory = simFile.getParent();
				}else{
					//assume a relative path, look for this relative directory in the toolbox path
					String projName = simFile.getParentFile().getPath();
					try{
						fProjectDirectory = findDirectoryInPath(projName).getAbsolutePath();
					} catch ( FileNotFoundException ex ){
						SUMOException e = new SUMOException("Unable to find the project " + projName + " in the toolbox search path");
						logger.log(Level.SEVERE,e.getMessage(),e);
						throw e;					
					}
				}
				simFile = new File(fProjectDirectory + File.separator + simFile.getName());
			}else{
				//No it doesn't, its just a simple xml file.
				//This was the old way of working but is no longer supported

				SUMOException e = new SUMOException("You must specify a project directory or an XML file prefixed by a project directory");
				logger.log(Level.SEVERE,e.getMessage(),e);
				throw e;					
			}
		}else{
			//Only a project directory was specified
			//is it an absolute path?
			if(simFile.isAbsolute()){
				//the path fully specifies the project dir
				fProjectDirectory = simulatorPath;
			}else{
				//assume a relative path, look for this relative directory in the toolbox path
				try{
					fProjectDirectory = findDirectoryInPath(simFile.getPath()).getAbsolutePath();
				} catch ( FileNotFoundException ex ){
					SUMOException e = new SUMOException("Unable to find the project " + simFile.getPath() + " in the toolbox search path");
					logger.log(Level.SEVERE,e.getMessage(),e);
					throw e;					
				}

			}
			//simply add xml to get the filename
			String projName = new File(fProjectDirectory).getName();
			simFile = new File(fProjectDirectory + File.separator + projName + ".xml");
		}	
		
		if(!simFile.exists()){
			SUMOException e = new SUMOException("Unable to load the simulator file " + simFile.getName() + " from the project directory " + fProjectDirectory);
			logger.log(Level.SEVERE,e.getMessage(),e);
			throw e;
		}
		
		// add project dir to path
		fSearchPath.clear();
		addToPath(new File(fProjectDirectory), true);
		
		logger.finest("Simulator xml file resolved to " + simFile.getAbsolutePath());
		
		// return simulator
		return simFile;

	}
//	-------------------------------------------------------------------------------------
	/**
	 * Is sampling enabled
	 */
	public boolean samplingEnabled(){
		return fSamplingEnabled;
	}
//	-------------------------------------------------------------------------------------
	/**
	 * Is parallel mode enabled (ie, run modeling in parallel if the distcomp toolbox is available)
	 */
	public boolean parallelMode(){
		return fParallelMode;
	}
//	-------------------------------------------------------------------------------------
	/**
	 * Set parallel model
	 */
	public void setParallelMode(boolean b){
		fParallelMode = b;;
	}
//	-------------------------------------------------------------------------------------
	/**
	 * Are we keeping old models
	 */
	public boolean keepOldModels(){
		return fKeepOldModels;
	}
//	-------------------------------------------------------------------------------------
	public String getRunName(){
		return runName;
	}
//	-------------------------------------------------------------------------------------
	public int getCurrentRunNumber(){
		return curRunNumber;
	}
//	-------------------------------------------------------------------------------------
	public void cleanup() throws SUMOException	{
		
		//Note by Dirk: in some cases cleanup may be called twice so take care!
		
		// Pseudo destructor: cleans some things up
		//The run has finished, tell all the profilers to cleanup
        ProfilerManager.finish();

        // Switch back to main log, only if there was a generalfilehandler in the first place
		if( generalFilehandler != null )
		{
			Logger root = LogManager.getLogManager().getLogger("");
			// Enable general FileHandler
			if (!fRunsInMainLog) {
				root.addHandler(generalFilehandler);
			}

            // Disable filehandler of this run
			if(runFileHandler != null){
                runFileHandler.close();
                root.removeHandler(runFileHandler);
                runFileHandler = null;
            }
		}
	}
//	-------------------------------------------------------------------------------------
	public static void configureLogger(Document config) throws SUMOException {
		
		try{
			NodeConfig n = NodeConfig.newInstance(config.getRootElement());
			NodeConfig logging = NodeConfig.newInstance(n.selectSingleNode("Logging"));
			
			if(logging == null)
				throw new SUMOException("No logging configuration found in your XML file, logging will will not work!");
			
			NodeConfig rootconfig = NodeConfig.newInstance(logging.selectSingleNode("RootLogger"));
			if(rootconfig == null)
			{
				System.out.println("No rootlogger found");
				return;
			}

			// do we log the runs in the general log as well?
			fRunsInMainLog = rootconfig.getBooleanOption("runsInMainLog", false);

			LogManager logmanager = LogManager.getLogManager();
			logmanager.reset();
			Logger rootlogger = logmanager.getLogger("");			
			rootlogger.setLevel( Level.parse(rootconfig.getOption("Level", "INFO")));;
			
			List handlers = rootconfig.selectNodes("Handlers/*");
			Iterator it = handlers.iterator();
			while( it.hasNext() )
			{
				// it is Node or Text (depending on XPath expression = dom4j reference)
		        NodeConfig nc = NodeConfig.newInstance((Node)it.next());
		       				
		        Handler h = null;
				if( nc.getName() == "ConsoleHandler" )
				{
					h = new ConsoleHandler();
					h.setFormatter( new SUMOFormatter() );
				} else if( nc.getName() == "FileHandler" ) {
					h = new FileHandler( nc.getOption("Pattern", "output" + File.separator + "SUMO-Toolbox.%g.%u.log"),
										 nc.getIntOption("Limit", 0),
										 nc.getIntOption("Count", 1),
										 nc.getBooleanOption("Append", false));
					h.setFormatter( new SUMOFileFormatter() );
					generalFilehandler = h;
				}
				else
				{
					throw new SUMOException("Unknown logging handler type");
				}
				h.setLevel(Level.parse(nc.getOption("Level", "INFO")));
				
				rootlogger.addHandler(h);
			}
			
			// set levels for other loggers
			Properties prop = logging.getAllOptionsAsProperties();
			String logname;
			for (Enumeration e = prop.keys (); e.hasMoreElements ();)
			{
			      logname = e.nextElement().toString();			      
			      Logger.getLogger(logname).setLevel(
			    		  Level.parse(prop.getProperty(logname))
			    		  );      
			 }
			
			logger = Logger.getLogger("ibbt.sumo.config.ContextConfig");
			logger.info("Logging configured...");
		} catch(IOException e) {
			e.printStackTrace();
			throw new SUMOException(e.getMessage());
		}
	}
//	-------------------------------------------------------------------------------------
	/**
	 * Among all logging handlers, return the most verbose log level
	 */
	public static int getMostVerboseLogLevel() {
		Handler[] handlers = LogManager.getLogManager().getLogger("").getHandlers();

		if(handlers.length == 0){
			return (Level.OFF).intValue();
		}
		
		Level l1 = handlers[0].getLevel();
		
		for(Handler h : handlers){
			if(h.getLevel().intValue() < l1.intValue()){
				l1 = h.getLevel();
			}
		}
		
		return l1.intValue();		
	}
//	-------------------------------------------------------------------------------------	
	/**
	 * which platform are we running on?
	 * @return platform
	 */
	public SystemPlatform getPlatform( ) {
		return fPlatform;
	}
//	-------------------------------------------------------------------------------------
	/**
	 * Which architecture are we running on?
	 * @return
	 */
	public SystemArchitecture getArch(){
		return fArch;
	}
//	-------------------------------------------------------------------------------------	
	/**
	 * Where is our project directory?
	 * @return project directory
	 */
	public String getProjectDirectory() {
		return fProjectDirectory;
	}
//	-------------------------------------------------------------------------------------
	public static void setRootDirectory(String root) {
		//make sure we escape backslashes, this is important on windows
		fRootDirectory = root.replace("\\", "\\\\");
	}
//	-------------------------------------------------------------------------------------
	public static String getRootDirectory() {
		return fRootDirectory;
	}
//	-------------------------------------------------------------------------------------
	/**
	 * Setup the directory structure and logging settings in order to start a new run
	 */
	private void initializeRun() throws SUMOException { 
		String logfile = getOutputDirectory() + File.separator + runName + ".%g.%u.log";
		
		File dir = new File( getOutputDirectory() );
		if( !dir.mkdirs() )
			throw new SUMOException("Could not create output directory:" + getOutputDirectory() );
		
		// create sub-folders
		File profiler_dir = new File(getOutputDirectory() + File.separator + "profilers");
		if( !profiler_dir.mkdir() )
			throw new SUMOException("Could not create profilers directory in " + getOutputDirectory() );
		
		// Switch to run log, only if there was a generalfilehandler in the first place
		if( generalFilehandler != null ) {
			Logger root = LogManager.getLogManager().getLogger("");
			try	{
				logger.log( Level.INFO, "Switching to log of run: " + runName );
				generalFilehandler.flush();
				
				runFileHandler = new FileHandler(logfile, Integer.MAX_VALUE, 1, false );
				runFileHandler.setFormatter(new SUMOFileFormatter());
				runFileHandler.setLevel(Level.ALL);
				root.addHandler(runFileHandler);
			} catch( IOException e ) {
				e.printStackTrace();
				throw new SUMOException("Failed to create log file '" + logfile + "', " + e.getMessage(),e);
				
			}
			
			if (!fRunsInMainLog) {
				root.removeHandler(generalFilehandler);
			}
		}
	}
//	-------------------------------------------------------------------------------------
	/**
	 * Where is the output directory
	 */
	public String getOutputDirectory() {
		return fOutputDirectory;
	}
	
//	-------------------------------------------------------------------------------------
	public static String getToolboxVersion() { 
		return SUMO_VERSION;
	}
//	-------------------------------------------------------------------------------------
	public static String getToolboxRevision() { 
		return SUMO_REVISION;
	}
//	-------------------------------------------------------------------------------------
	public static String getToolboxIcon() { 
		return SUMO_ICON_NAME;
	}
//	-------------------------------------------------------------------------------------
	public static String getToolboxHomepage() { 
		return SUMO_HOMEPAGE;
	}
//	-------------------------------------------------------------------------------------
	/**
	 * find a file
	 * @param name where to search for this file
	 * @return file
	 * @throws FileNotFoundException
	 */
	public File findFileInPath( String name ) throws FileNotFoundException {		
		if(name == null) 
			throw new FileNotFoundException("Filename given is null!" );
		
		name = Util.cleanFileSeparators(name);
		File plain = new File( name );
		if ( plain.exists() && plain.isFile() )
			return plain;
		
		for ( File entry : fSearchPath )	{
			File file = new File( entry, name );
			if ( file.exists() && file.isFile() )
				return file;
		}
		
		throw new FileNotFoundException("File " + name + " was not found in the toolbox search path" );
	}
//	-------------------------------------------------------------------------------------
	/**
	 * Find a directory
	 * @param name name of the directory to find
	 * @return File object
	 * @throws FileNotFoundException
	 */
	public File findDirectoryInPath( String name ) throws FileNotFoundException {		
		if(name == null) 
			throw new FileNotFoundException("Directory given is null!" );
		
		name = Util.cleanFileSeparators(name);
		File plain = new File( name );
		if ( plain.exists() && plain.isDirectory() )
			return plain;
		
		for ( File entry : fSearchPath )	{
			File file = new File( entry, name );
			if ( file.exists() && file.isDirectory() )
				return file;
		}
		
		throw new FileNotFoundException("Directory " + name + " was not found in the toolbox search path" );
	}
//	-------------------------------------------------------------------------------------
	public String getTempDir( ) {
		return System.getProperty("java.io.tmpdir");
	}
//	-------------------------------------------------------------------------------------
	public SimulatorConfig getSimulatorConfig( ) {
		return fSimulatorConfig;
	}
//	-------------------------------------------------------------------------------------
	public NodeConfig getPlotOptions() {
		return fPlotOptions;
	}
//	-------------------------------------------------------------------------------------
	private void setupProfilers(NodeConfig ctxt, String runName) {
		
		Node profnode = ctxt.selectSingleNode("Profiling");
		
		if(profnode == null){
			//
		}else{
			NodeConfig n = NodeConfig.newInstance(profnode); 
				
			// Initialize the profilers
			String title = "SUMO-Toolbox profilers for run " +  runName;
			ProfilerManager.initialize(n, getOutputDirectory(), title);
			
			//Clear the docked view widget, may contain profilers from previous runs
			ProfilerManager.clearDockedView();		
		}
	}
	
//	-------------------------------------------------------------------------------------
	public InputConfig getInputConfig(){
		return inputConfig;
	}
//	-------------------------------------------------------------------------------------
	public OutputConfig getOutputConfig(){
		return outputConfig;
	}
//	-------------------------------------------------------------------------------------
	public boolean logRunsInMainLog() {
		return fRunsInMainLog; 
	}
//	-------------------------------------------------------------------------------------
	public void addToPath( List toAdd ) {

		if(toAdd == null){
			return;
		}
			
		for ( Object x : toAdd ) {
			if ( ! (x instanceof Node) ){
				continue;
			}
			Node node = (Node) x;
			
			// Fix path with correct path seperators
			String entry = node.getStringValue();
			Node recurseNode = node.selectSingleNode( "@recurse" );
			boolean recurse = (recurseNode != null) && recurseNode.getText().equals("true");
			entry = Util.cleanFileSeparators(entry);
			
			File file = new File( entry );
			if ( file.isDirectory() ){
				logger.info("Context is adding " + file.getAbsolutePath() + " to the toolbox path " + (recurse ? "(RECURSIVELY)" : "") );
				addToPath( file, recurse );
			}else{
				logger.warning("Path entry " + entry + " is not a directory" );
			}
		}
	}
//	-------------------------------------------------------------------------------------	
	public void addToPath( File file, boolean recurse) {
		fSearchPath.add(file);
		if (recurse){
			for (File f : file.listFiles(new HiddenFileFilter())){
				if (f.isDirectory()){
					addToPath( f, true);
				}
			}
		}
	}
//	-------------------------------------------------------------------------------------	
	/**
	 * Given a raw run name and the current config for this run, replace all placeholders
	 * by their correct value in order to come to a sane run name
	 * 
	 * TODO: this is not the most straightforward of code :)
	 */
	private String composeRunName(String rawRunName, List runConfig){

		String runName;
		
		// Set a default run name
		if(rawRunName.length() < 1){
			runName = "#simulator#_#adaptivemodelbuilder#";
		}else{
			runName = rawRunName;
		}

		//which placeholders map to which tag names (placeholders like measure, output, simulator are treated specially)
		HashMap<String, String> placeHolders = new HashMap<String, String>();
		placeHolders.put("#simulator#",				"Simulator");
		placeHolders.put("#sampleselector#",		"SampleSelector");
		placeHolders.put("#sampleevaluator#",		"SampleEvaluator");
		placeHolders.put("#adaptivemodelbuilder#",	"AdaptiveModelBuilder");
		placeHolders.put("#measure#",				"Measure");
		placeHolders.put("#output#",				"Output");
		
		//the replacement for each placeholder
		HashMap<String, String> replacements = new HashMap<String, String>();

		//get configuration for each output
		OutputDescription[] ods = outputConfig.getOutputDescriptions();
		
		//some local vars
		String ph,tmp = null;
		String id = null;
		
		//The simulator can only occur once, replace it up front
		if(runName.contains("#simulator#")){
			runName = runName.replaceAll("#simulator#", fSimulatorConfig.getName());
		}
		
		//iterate over each output, note that one run can contain multiple output tags, each with their own
		//selected configs
		for(OutputDescription od : ods){
			//System.out.println("*************" + od.getName());
			
			//System.out.println(ConfigUtil.asXML(od.getComponents()));
			//System.out.println(ConfigUtil.asXML(NodeConfig.convertToNode(od.getMeasures())));
			
			//iterate over every placeholder
			Iterator<String> it = placeHolders.keySet().iterator();
			
			while(it.hasNext()){
				ph = it.next();
				
				//The runname contains this placeholder
				if(runName.contains(ph)){
					//System.out.println("*****"+ph);
					
					//Output and measure are special cases since they are not addressed by id
					if(ph.equals("#output#")){
						tmp = od.getName();
					}else if(ph.equals("#measure#")){
						//do nothing, measures are added all together at the end since they
						//accumulate and dont override
						tmp = "";
						
					//all the others: simply lookup the correct id
					}else{
						//is the component matching this placeholder defined for this output?
						id = ConfigUtil.getTagTextByName(od.getComponents(), placeHolders.get(ph));
						
						if(id == null){
							//no it isnt, check on the plan level
							id = ConfigUtil.getTagTextByName(runConfig, placeHolders.get(ph));
													
							//There is no matching tag to replace, this should never happen
							if(id == null){
								tmp = "";
							}else{
								//Get the corresponding config section
								NodeConfig n = NodeConfig.newInstance(ConfigUtil.resolveReference(fFullConfig, placeHolders.get(ph), id));
								
								//This means the user is referring to an id that does not exist in the config file
								if(n == null){
									tmp = "";
								}else{
									//check if combine outputs is true
									boolean co = n.getBooleanAttrValue("combineOutputs", "false");
									if(co){
										//only add it once
										if(replacements.containsValue(id)){
											tmp = "";
										}else{
											tmp = id;
										}
									}else{
										tmp = id;
									}
								}
							}
						}else{
							NodeConfig n = NodeConfig.newInstance(ConfigUtil.resolveReference(fFullConfig, placeHolders.get(ph), id));
							
							//This means the user is referring to an id that does not exist in the config file
							if(n == null){
								tmp = "";
							}else{
								//check if combine outputs is true
								boolean co = n.getBooleanAttrValue("combineOutputs", "false");
								if(co){
									//only add it once
									if(replacements.containsValue(id)){
										tmp = "";
									}else{
										tmp = id;
									}
								}else{
									tmp = id;
								}
							}
						}
					}
					
					//ok, now store the value generated for this output with the corresponding placeholder
					//if we have already treated this placeholder (eg. for the previous output) simply concatenate
					if(replacements.containsKey(ph)){
						if(tmp.length() > 0) replacements.put(ph, replacements.get(ph) + "_" + tmp);
					}else{
						replacements.put(ph,tmp);
					}
				}
			
			}
		}
		
		//add the measures all in one go since they accumulate instead of overriding
		if(replacements.containsKey("#measure#")){
			List<NodeConfig> measures = ConfigUtil.getTagByNameAsList(runConfig, "Measure",true);
			
			if(measures == null){
				//no measures to add
			}else{
				//get the types of the measures defined on the plan level
				tmp = "";
				NodeConfig nc;
				boolean use;
				for(NodeConfig m : measures){
					use = m.getBooleanAttrValue("use", "on");
					
					if(use){
						tmp += m.getAttrValue("type","") + "_";
					}else{
						//measure is set to off, so dont add it
					}
				}
				//remove trailing underscore
				tmp = tmp.substring(0, tmp.length()-1);
				
				//add them to the replacement
				replacements.put("#measure#", replacements.get("#measure#") + "_" + tmp);
			}
				
		}
		
		//Actually do the replacement
		Iterator<String> it = replacements.keySet().iterator();
		while(it.hasNext()){
			ph = it.next();
			runName = runName.replace(ph, replacements.get(ph));	
		}		
				
		//Get rid of any spaces or duplicate underscores
		runName = runName.replaceAll("\\s", "_" );
		runName = runName.replaceAll("\\_+", "_" );
		 
		return runName;
	}
//	-------------------------------------------------------------------------------------
}

