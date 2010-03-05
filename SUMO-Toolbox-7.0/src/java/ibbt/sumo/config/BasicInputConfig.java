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
** Revision: $Id: BasicInputConfig.java 6396 2009-12-14 13:09:48Z ilm $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.SUMOException;
import ibbt.sumo.util.Util;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import org.dom4j.Element;
import org.dom4j.Node;
import org.dom4j.tree.DefaultElement;

public class BasicInputConfig implements InputConfig {
	
	// logger
	private static Logger logger = Logger.getLogger("ibbt.sumo.config.BasicInputConfig");
	
	// input descriptions
	private InputDescription[] fInputDescriptions;
	
	// all input descriptions (including constants)
	private InputDescription[] fConstantInputDescriptions;
	
	// input dimension of the simulator
	private int fSimulatorInputDimension;
	
	// default value for the unused inputs
	private double fDefaultValue;
	
	// input constraints
	private List<Node> fConstraints;
	
	
	@SuppressWarnings("unchecked")
	public BasicInputConfig(List runConfig, SimulatorConfig simConfig) throws SUMOException {
		
		
		// store configs
		logger.fine("Starting InputConfig object construction...");
		
		
		// OUTPUTSELECT
		Element inputData = (Element)ConfigUtil.getTagByName(runConfig, "Inputs");
		
		// no inputs config found, create default one (all inputs selected)
		if (inputData == null) {
			inputData = new DefaultElement("Inputs");
			runConfig.add(inputData);
		}
		
		// set default value
		String defVal = inputData.valueOf("@defaultValue");
		if (defVal.length() == 0) 
			fDefaultValue = Double.NaN; /* middle of domain (handled by SampleManager.m) */
		else 
			fDefaultValue = Double.parseDouble(defVal);
		
		
		// SIMULATORFILE
		SimulatorConfig simulator = simConfig;

		
		// GET SIMULATOR INPUTS
		Map<String, InputDescription> allInputs = simulator.getInputDescriptions();
		fSimulatorInputDimension = allInputs.keySet().size();
		logger.info("Simulator input dimension: " + fSimulatorInputDimension);
		
		// get all the selected inputs and place them in a list
		List<Node> selectedInputs = inputData.selectNodes("Input");
		
		// no inputs selected, allow them all
		// and produce default input configuration settings
		boolean noInputsSelected = (selectedInputs.size() == 0);
		if (noInputsSelected) {
			selectedInputs = new LinkedList<Node>();
			List<? extends Node> allInputParameters = simulator.getInputParameterNodes();
			for (Node item : allInputParameters) {
				Element newInput = inputData.addElement("Input");
				newInput.addAttribute("name", item.valueOf("@name"));
				selectedInputs.add(newInput);
			}
		}
		
		// now walk over all selected inputs and construct the config and filter according to symmetries
		List<InputDescription> inputs = new LinkedList<InputDescription>();
		List<InputDescription> constantInputs = new LinkedList<InputDescription>();
		Iterator<? extends Node> iter = selectedInputs.iterator();
		
		while (iter.hasNext()) {
			
			// get node
			Node node = iter.next();
			
			// get names of the parameter
			String[] inputNames = node.valueOf("@name").split(",");
			
			// split the parameter up for "P1,P2,P3" format support
			for (String inputName: inputNames) {
				
				// get data from simulator about this parameter
				InputDescription dd = allInputs.remove(inputName);
				
				// invalid input
				if (dd == null) {
					String msg = "Invalid input \"" + inputName + "\" selected, does not exist or was already selected";
					logger.severe(msg);
					throw new SUMOException(msg);
				}
				
				// already set - we can't set the same parameter twice, so error
				/*if (inputs.contains(dd)) {
					String msg = "Invalid input \"" + inputName + "\" selected, already selected earlier";
					logger.severe(msg);
					throw new SUMOException(msg);
				}*/
				
				// value specified for this input - constant input specified
				if (node.valueOf("@value").length() != 0) {
					
					// get value
					double value = Double.parseDouble(node.valueOf("@value"));
					
					// update type & constant value
					dd.setType(InputDescription.Type.CONSTANT);
					dd.setValue(value);
					
					// add to list
					constantInputs.add(dd);
				}
				
				// no constant specified - normal input that is to be modelled
				else {
					inputs.add(dd);
				}
			}
		}
		
		// set non-constant input descriptions
		fInputDescriptions = inputs.toArray(new InputDescription[inputs.size()]);
		
		// now set default values for all remaining inputs that were not mentioned
		for (InputDescription dd : allInputs.values()) {
			
			// set to constant
			dd.setType(InputDescription.Type.CONSTANT);
			dd.setValue(fDefaultValue);
			
			// add to list
			constantInputs.add(dd);
		}
		
		// set all input descriptions (including constant dimensions)
		fConstantInputDescriptions = constantInputs.toArray(new InputDescription[constantInputs.size()]);
		
		// print all inputs
		logger.info("Inputs: " + Util.arrayToString(inputs));
		
		// print constant inputs
		if (fConstantInputDescriptions.length > 0) {
			logger.info("Constant inputs: " + Util.arrayToString(fConstantInputDescriptions));
		}
		
		
		// Check whether any outputs are left
		if (inputs.size() == 0) {
			String msg = "No non-constant inputs selected, can't model zero-dimensional problem";
			logger.severe(msg);
			throw new SUMOException(msg);
		}
		
		// set constraints
		fConstraints = simulator.getInputConstraints();
	}
	
//	-------------------------------------------------------------------------------------
	/* (non-Javadoc)
	 * @see ibbt.sumo.config.InputConfig#getInputDimension()
	 */
	public int getInputDimension() {
		// all selected inputs minus the constants
		return fInputDescriptions.length;
	}
//	-------------------------------------------------------------------------------------
	/* (non-Javadoc)
	 * @see ibbt.sumo.config.InputConfig#getSimulatorInputDimension()
	 */
	public int getSimulatorInputDimension() { 
		return fSimulatorInputDimension;
	}
//	-------------------------------------------------------------------------------------
	/* (non-Javadoc)
	 * @see ibbt.sumo.config.InputConfig#getNrConstant()
	 */
	public int getNrConstant() {
		return fConstantInputDescriptions.length;
	}
//	-------------------------------------------------------------------------------------
	/* (non-Javadoc)
	 * @see ibbt.sumo.config.InputConfig#getInputName(int)
	 */
	public String getInputName(int i) {
		return getInputDescriptions()[i].getName();
	}
//	-------------------------------------------------------------------------------------
	/* (non-Javadoc)
	 * @see ibbt.sumo.config.InputConfig#getInputNames()
	 */
	public String[] getInputNames() {
		String[] s = new String[this.getInputDimension()];
		for (int i = 0; i < s.length; ++i) s[i] = getInputName(i);
		return s;
	}
//	-------------------------------------------------------------------------------------
	/* (non-Javadoc)
	 * @see ibbt.sumo.config.InputConfig#getInputDescriptions()
	 */
	public InputDescription[] getInputDescriptions() {
		return fInputDescriptions;
	}
//	-------------------------------------------------------------------------------------
	/* (non-Javadoc)
	 * @see ibbt.sumo.config.InputConfig#getInputDescriptions()
	 */
	public InputDescription[] getConstantInputDescriptions() {
		return fConstantInputDescriptions;
	}
	
//	-------------------------------------------------------------------------------------
	/* (non-Javadoc)
	 * @see ibbt.sumo.config.InputConfig#getInputDescription()
	 */
	public InputDescription getInputDescription(int i) {
		return getInputDescriptions()[i];
	}
	
	/* (non-Javadoc)
	 * @see ibbt.sumo.config.InputConfig#getConstraints()
	 */
	public List<Node> getConstraints() {
		return fConstraints;
	}
}
