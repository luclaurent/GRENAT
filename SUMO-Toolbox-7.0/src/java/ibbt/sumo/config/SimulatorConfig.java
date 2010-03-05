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
** Revision: $Id: SimulatorConfig.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.SUMOException;
import ibbt.sumo.util.Pair;
import ibbt.sumo.util.SystemArchitecture;
import ibbt.sumo.util.SystemPlatform;
import ibbt.sumo.util.Util;

import java.io.File;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.dom4j.Element;
import org.dom4j.Node;

/**
 * Wraps all the configuration information from the Simulator XML file
 */
@SuppressWarnings("unchecked")
public class SimulatorConfig {
	private static Logger logger = Logger.getLogger("ibbt.sumo.config.SimulatorConfig");
	
	private File file = null;
	private NodeConfig config = null;
	
//	-----------------------------------------------------------------------------------------------------------
	public SimulatorConfig(File f) throws SUMOException{
		try{			
			logger.info("Reading simulator data from file '" + f.getName() + "'");
			this.config = NodeConfig.newInstance(ConfigUtil.readXML(f));
			this.file = f;
		}catch (Exception e) {
			SUMOException ex =  new SUMOException(e.getMessage());
			ex.initCause(e);
			logger.log(Level.SEVERE,"Error reading simulator file " + f.getAbsolutePath() + ex.getMessage(),ex);
		}
	}
//	-----------------------------------------------------------------------------------------------------------
	public SimulatorConfig(String f) throws SUMOException{
		this( new File(f) );
	}
//	-----------------------------------------------------------------------------------------------------------
	public String getXmlFilename(){
		return this.file.getName(); 
	}
//	-----------------------------------------------------------------------------------------------------------
	public String getName(){
		return config.selectSingleNode( "//Simulator/Name" ).getText(); 
	}
//	-----------------------------------------------------------------------------------------------------------
	public String getDescription(){
		return config.selectSingleNode( "//Simulator/Description" ).getText(); 
	}
//	-----------------------------------------------------------------------------------------------------------
	public int getInputDimension(){
		return getInputParameterNodes().size(); 
	}
//	-----------------------------------------------------------------------------------------------------------
	public int getOutputDimension(){
		return getOutputParameterNodes().size(); 
	}
//	-----------------------------------------------------------------------------------------------------------
	public int getNumberOfComplexOutputs(){
		return config.selectNodes( "//Simulator/OutputParameters/Parameter[@type=\"complex\"]" ).size();
	}
//	-----------------------------------------------------------------------------------------------------------
	public int getNumberOfRealOutputs(){
		return config.selectNodes( "//Simulator/OutputParameters/Parameter[@type=\"real\"]" ).size();
	}
//	-----------------------------------------------------------------------------------------------------------
	/**
	 * 
	 * @param platform
	 * @param arch
	 * @return
	 */
	public NodeConfig getExecutable(SystemPlatform platform, SystemArchitecture localArch){
		//Get all the entries that match the current platform
		List<Node> nodes = config.selectNodes("//Executable");
		
		//get the first entry that matches the current architecture and platform
		SystemArchitecture simArch;
		SystemPlatform simPlatform;
		NodeConfig tmp = null;
		for(Node n : nodes){
			tmp = NodeConfig.newInstance(n);
			
			// First check platform
			simPlatform = Util.resolvePlatformName(tmp.getAttrValue("platform", "ANY"));
			if( platform.holds( simPlatform ) ) {
				// Second check architecture
				simArch = Util.resolveArchitectureName(tmp.getAttrValue("arch", "ANY"));
				// Check if the simulator architecture is included (=parent) in the local architecture
				if( localArch.holds( simArch ) ) {
					return tmp;
				}
			}
		}

		return null;
	}
//	-----------------------------------------------------------------------------------------------------------
	/**
	 * 
	 * @param platform
	 * @param arch
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public LinkedList<String> getExecutableDependencies(SystemPlatform platform, SystemArchitecture localArch){
		LinkedList<String> deps = new LinkedList<String>();
		
		NodeConfig exe = getExecutable(platform, localArch);
		
		if(exe == null){
			logger.severe("No executable defined for platform " + platform + " and arch " + localArch);
			return deps;
		}else{
			//Get the id of the dependency list
			String id = exe.valueOf("@dependencyList");
			if(id == null || id.length() < 1){
				//No dependency list specified, return empty list
				return deps;
			}else{
				List<Node> locations = config.selectNodes("//DependencyList[@id='" + id + "']/Dependency");
				if(locations == null || locations.size() == 0){
					logger.warning("Id " + id + " refers to an empty or invalid dependency list");
					return deps;
				}
				
				String loc = null;
				for(Node n : locations){
					loc = n.valueOf("@location");
					if(loc == null || loc.length() < 1 || !new File(loc).exists()){
						logger.warning("Empty, missing or invalid dependency location " + loc + " for dependency list " + id + "(platform=" + platform + ", arch=" + localArch + ")");
					}else{
						deps.add(loc);
						logger.fine("Added dependency location " + loc + "(id=" + id + ", platform=" + platform + ", arch=" + localArch + ")");
					}
				}
				return deps;
			}
		}
	}
//	-------------------------------------------------------------------------------------
	public Map<String, InputDescription> getInputDescriptions() throws SUMOException{ 
		List<Node> parameterData = getInputParameterNodes();
		Map<String, InputDescription> allInputs = new HashMap<String, InputDescription>();
		int counter = 0;
		for (Node item : parameterData) {
			String name = item.valueOf("@name");
			
			if(!Util.isValidIdentifier(name)){
				throw new SUMOException("Invalid parameter name '" + name + "', parameter names should start with letters and contain only letters, numbers, or underscores");
			}
			
			allInputs.put(name, new InputDescription(NodeConfig.newInstance(item), counter++));
		}
		
		return allInputs;
	}
	
//	-------------------------------------------------------------------------------------
	public Pair<Map<String, OutputDescription>, Integer> getOutputDescriptions() throws SUMOException{ 
		OutputDescription.resetCounter();
		List<Node> parameterData = getOutputParameterNodes();
		Map<String, OutputDescription> allOutputs = new HashMap<String, OutputDescription>();
		for (Node item : parameterData) {
			String name = item.valueOf("@name");
			
			if(!Util.isValidIdentifier(name)){
				throw new SUMOException("Invalid parameter name '" + name + "', parameter names should start with letters and contain only letters, numbers, or underscores");
			}
			
			allOutputs.put(name, new OutputDescription(NodeConfig.newInstance(item)));
		}
		
		return new Pair<Map<String, OutputDescription>, Integer>(allOutputs,OutputDescription.getCounter());
	}
//	-------------------------------------------------------------------------------------
	public List<Node> getInputParameterNodes(){ 
		return config.selectNodes("//Simulator/InputParameters/Parameter");
	}
//	-------------------------------------------------------------------------------------
	public List<Node> getInputConstraints(){
		return config.selectNodes("//Simulator/InputParameters/Constraint");
	}
//	-------------------------------------------------------------------------------------	
	public List<Node> getOutputParameterNodes(){ 
		return config.selectNodes("//Simulator/OutputParameters/Parameter");
	}
//	-------------------------------------------------------------------------------------
	public List<? extends Element> getGriddedDataFiles(){
		return config.selectNodes( "//Simulator/Implementation/DataFiles/GriddedDataFile" );
	}
//	-------------------------------------------------------------------------------------
	public List<? extends Element> getScatteredDataFiles(){
		return config.selectNodes( "//Simulator/Implementation/DataFiles/ScatteredDataFile" );
	}
//	-------------------------------------------------------------------------------------
	public List<? extends Element> getExecutables(){
		return config.selectNodes( "//Simulator/Implementation/Executables/Executable" );
	}
//	-------------------------------------------------------------------------------------
	public Node getGriddedDataFile(String id){
		return config.selectSingleNode( "//DataFiles/GriddedDataFile[@id=\"" + id + "\"]");
	}
//	-------------------------------------------------------------------------------------
	public Node getScatteredDataFile(String id){
		return config.selectSingleNode( "//DataFiles/ScatteredDataFile[@id=\"" + id + "\"]");
	}
//	-------------------------------------------------------------------------------------
	public Properties getOptions(){
		Properties p = new Properties();
		
		List<Node> ops = config.selectNodes("//Options/Option");

		String key,value;
		for(Node n : ops){
			key = n.valueOf("@key");
			value = n.valueOf("@value");
			
			p.put(key, value);
		}
		
		return p;
	}
//	-------------------------------------------------------------------------------------
//	-------------------------------------------------------------------------------------

}
