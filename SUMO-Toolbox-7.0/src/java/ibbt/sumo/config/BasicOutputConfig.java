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
** Revision: $Id: BasicOutputConfig.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.SUMOException;
import ibbt.sumo.util.Pair;
import ibbt.sumo.util.Util;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Vector;
import java.util.logging.Logger;

import org.dom4j.Element;
import org.dom4j.Node;
import org.dom4j.tree.DefaultElement;

public class BasicOutputConfig implements OutputConfig {
	
	// logger
	private static Logger logger = Logger.getLogger("ibbt.sumo.config.OutputConfig");
	
	// flat output dimension (filtered)
	private int fFlatOutputDimension;
	
	// array which contains the final output selection
	private int[] fOutputSelect;
	
	// output descriptions
	private OutputDescription[] fOutputDescriptions;

//	-------------------------------------------------------------------------------------
	@SuppressWarnings("unchecked")
	public BasicOutputConfig(List runConfig, SimulatorConfig simConfig) throws SUMOException {
		
		// store configs
		logger.fine("Starting OutputConfig object construction...");
		
		
		// OUTPUTSELECT
		Element outputData = (Element)ConfigUtil.getTagByName(runConfig, "Outputs");
		
		// no outputs config found, create default one
		if (outputData == null) {
			outputData = new DefaultElement("Outputs");
			runConfig.add(outputData);
		}
		
		// SIMULATORFILE
		SimulatorConfig simulator = simConfig;
		
		
		// READ SIMULATOR OUTPUTS
		Pair<Map<String, OutputDescription>, Integer> p = simulator.getOutputDescriptions();
		Map<String, OutputDescription> allOutputs = p.getFirst();
		fFlatOutputDimension = p.getSecond();		
		logger.info( "Simulator Output Dimension: " + fFlatOutputDimension );

		
		// READ, FILTER & PROCESS SELECTED OUTPUTS
		
		// get all the selected outputs and place them in a list
		List<Node> selectedOutputs = outputData.selectNodes("Output");
		
		// no outputs selected, allow them all
		// and produce default output configuration settings
		boolean noOutputsSelected = (selectedOutputs.size() == 0);
		if (noOutputsSelected) {
			selectedOutputs = new LinkedList<Node>();
			List<? extends Node> allOutputParameters = simulator.getOutputParameterNodes();
			for (Node item : allOutputParameters) {
				Element newOutput = outputData.addElement("Output");
				newOutput.addAttribute("name", item.valueOf("@name"));
				selectedOutputs.add(newOutput);
			}
		}
		
		// now walk over all selected outputs and construct the config and filter
		Vector<OutputDescription> outputs = new Vector<OutputDescription>();
		Map<String, Integer> outputCount = new HashMap<String, Integer>();
		Iterator<? extends Node> iter = selectedOutputs.iterator();
		while (iter.hasNext()) {
			
			// get node
			Node node = iter.next();
			
			// get name of the parameter
			String[] outputNames = node.valueOf("@name").split(",");
			
			// get complex handling scheme for this output
			String complexHandling = node.valueOf("@complexHandling");
			if (complexHandling.length() == 0) complexHandling = "complex";
			
			// split the parameter up for "P1,P2,P3" format support
			for (String outputName: outputNames) {
				
				// get data from simulator about this parameter
				OutputDescription dd = allOutputs.get(outputName);
				
				// no output of this name
				if (dd == null) {
					String msg = "Invalid output \"" + outputName + "\" selected, not found in the simulator " + simulator.getXmlFilename();
					logger.severe(msg);
					throw new SUMOException(msg);
				}
				
				// create copy of this parameter
				dd = new OutputDescription(dd);
				
				// update the parameter description with measure/component data
				dd.parseConfig(node, runConfig);
				outputName = dd.getName();
				
				
				// update amount of times this parameter is to be modelled
				if (outputCount.get(outputName) == null) outputCount.put(outputName, 0);
				int count = outputCount.get(outputName) + 1;
				outputCount.put(outputName, count);
				
				// if we model an output multiple times, we change its name
				if (count > 1) dd.setName(dd.getName()+ "_" + count);
				
				
				// real outputs are always treated as just real numbers
				// but they can be filtered out
				if (dd.isReal()) outputs.add(dd);
				
				// if the output is complex, we behave differently according to complex handling setting
				if (dd.isComplex()) {
					
					// only consider real part of complex output
					if (complexHandling.equals("real")) {
						outputs.add(dd.convertToReal());
					}
					
					// only consider imaginary part of complex output
					else if (complexHandling.equals("imaginary")) {
						outputs.add(dd.convertToImag());
					}
					
					// treat a complex number as 2 separate unrelated real numbers
					else if (complexHandling.equals("split")) {
						outputs.add(dd.convertToReal());
						outputs.add(dd.convertToImag());
					}
					
					// model the modulus of the complex number
					else if (complexHandling.equals("modulus"))
						outputs.add(dd.convertToModulus());

					// model the phase of the complex number
					else if (complexHandling.equals("phase"))
						outputs.add(dd.convertToPhase());
					
					// model the complex number itself
					else if (complexHandling.equals("complex"))
						outputs.add(dd);
					
					// invalid complex handling specified
					else {
						String msg = "Complexhandling specified for output " + outputName + " is invalid: " + complexHandling;
						logger.severe(msg);
						throw new SUMOException(msg);
					}
					
					logger.info("Complex handling for output " + dd.getName() + " set to " + complexHandling);
					
				}
			}
		}
		
		// print all outputs
		logger.info("Outputs: " + Util.arrayToString(outputs));
		
		
		// Construct output selection string
		Vector<Integer> finalOutputSelect = new Vector<Integer>();
		for (OutputDescription output: outputs) {
			int[] add = output.getOutputSelect();
			for (int i = 0; i < add.length; ++i) finalOutputSelect.add(add[i]);
		}
		fOutputSelect = new int[finalOutputSelect.size()];
		for (int i = 0; i < fOutputSelect.length; ++i) fOutputSelect[i] = finalOutputSelect.get(i);
		
		// Check whether any outputs are left
		if ( outputs.size() == 0 ) {
			String msg = "All outputs were filtered out, at least one output must be selected";
			logger.severe(msg);
			throw new SUMOException(msg);
		}
		
		// SET FINAL OUTPUT DESCRIPTIONS
		fOutputDescriptions = outputs.toArray(new OutputDescription[outputs.size()]);
	}
	
	
//	-------------------------------------------------------------------------------------
	public int getOutputDimension() {
		return fOutputDescriptions.length;
	}
//	-------------------------------------------------------------------------------------
	// What are the outputs you have to model
	public OutputDescription[] getOutputDescriptions() {
		return fOutputDescriptions;
	}
//	-------------------------------------------------------------------------------------
	public OutputDescription getOutputDescription(int i) {
		assert 0 <= i && i < fOutputDescriptions.length;
		return getOutputDescriptions()[i];
	}
//	-------------------------------------------------------------------------------------
	public String[] getOutputNames() {
		return ConfigUtil.dd2s(getOutputDescriptions());
	}
//	-------------------------------------------------------------------------------------
	public String getOutputNamesAsString(String delim) {
		String[] s = ConfigUtil.dd2s(getOutputDescriptions());
		return Util.join(s, delim);
	}
//	-------------------------------------------------------------------------------------
	public String getOutputName(int i) {
		assert 0 <= i && i < fOutputDescriptions.length;
		return getOutputDescriptions()[i].getName();
	}
//	-------------------------------------------------------------------------------------
	public boolean hasComplexOutputs(){
		for(OutputDescription d : getOutputDescriptions()){
			if(d.isComplex()) return true;
		}
		return false;
	}
//	-------------------------------------------------------------------------------------	
	public int[] getOutputSelect() {
		return fOutputSelect;
	}
//	-------------------------------------------------------------------------------------
	public String getOutputSelectString() {
		return Util.arrayToString(fOutputSelect);
	}
//	-------------------------------------------------------------------------------------
	public int getSimulatorOutputDimension() {
		return fFlatOutputDimension;
	}
}
