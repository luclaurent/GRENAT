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
** Revision: $Id: OutputDescription.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.util.Util;

import java.util.LinkedList;
import java.util.List;
import java.util.logging.Logger;

import org.dom4j.Element;
import org.dom4j.Node;

/**
 * Class that describes one input dimension
 * This object represents a task for the SampleEvaluator: 
 * for each given set of input parameters, the SampleEvaluator has to calculate the output parameters.
 *
 */
 
public class OutputDescription {
	private static Logger logger = Logger.getLogger("ibbt.sumo.config.OutputDescription");
	
	private String fName;
	
	// defines different ways this output can be treated
	enum Type {
		REAL,		// real types are processed as-is from one real from the simulator
		COMPLEX,	// complex outputs are formed by two reals from the simulator: a+bi
		MODULUS,	// modulus outputs are formed by two reals from the simulator: abs(a+bi)
		PHASE,		// phase of the output
	};
	
	
    // each output has a type, which defines how the output should be processed
	private Type fType;
	
	// the outputs that have to be selected for this parameter description
	private int[] fOutputSelect;
	
	// minimum/maximum of this output
	private double fMinimum;
	private double fMaximum;
	
	// ignore nan/inf
	private boolean fIgnoreNaN;
	private boolean fIgnoreInf;
	
	// keeps count of how many parameters were initialized and which simulator "slots" they occupy
	private static int counter = 0;	
	
	// components selected for this parameter
	private List<Node> fComponents = new LinkedList<Node>();
	
	// the measures defined globally, for ALL outputs
	private List<NodeConfig> fGlobalMeasures = new LinkedList<NodeConfig>();

	// the measures defined locally for just this output tag
	private List<NodeConfig> fLocalMeasures = new LinkedList<NodeConfig>();

	// modifier nodes
	private List<NodeConfig> fModifiers = new LinkedList<NodeConfig>();
	
	/**
	 * Copy constructor.
	 * @param other The other description to copy from.
	 */
	public OutputDescription(OutputDescription other) {
		fName = other.fName;
		fType = other.fType;
		fMinimum = other.fMinimum;
		fMaximum = other.fMaximum;
		fIgnoreNaN = other.fIgnoreNaN;
		fIgnoreInf = other.fIgnoreInf;
		fOutputSelect = other.fOutputSelect;
		for (Node item : other.fComponents)
			fComponents.add(item);
		for (NodeConfig item : other.fLocalMeasures)
			fLocalMeasures.add(item);
		for (NodeConfig item : other.fGlobalMeasures)
			fGlobalMeasures.add(item);
		for (NodeConfig item : other.fModifiers)
			fModifiers.add(item);
	}
	
	/**
	 * Initializes a parameter description, increments the output select counter.
	 * @param name Name of the parameter (does not have to be unique)
	 * @param type Type of the parameter, one of REAL, COMPLEX (COMPLEX parameters are formed out of 2 reals read from the simulator)
	 */
	public OutputDescription(NodeConfig config) {
		fName = config.valueOf("@name");
		setType(config.valueOf("@type"));
		fMinimum = config.getDoubleAttrValue("minimum", "" + Double.NEGATIVE_INFINITY);
		if (fMinimum == Double.NEGATIVE_INFINITY) fMinimum = config.getDoubleAttrValue("min", "" + Double.NEGATIVE_INFINITY);
		fMaximum = config.getDoubleAttrValue("maximum", "" + Double.POSITIVE_INFINITY);
		if (fMaximum == Double.POSITIVE_INFINITY) fMaximum = config.getDoubleAttrValue("max", "" + Double.POSITIVE_INFINITY);
		if (fType == Type.REAL)
			fOutputSelect = new int[] {counter};
		else
			fOutputSelect = new int[] {counter, counter+1};
		
		counter += fOutputSelect.length;
	}
	
	
	/**
	 * Implements the equals function for parameter descriptions, same name = equal.
	 */
	public boolean equals(OutputDescription other) {
		return fName.equals(other.fName);
	}
	
	
	/**
	 * Is this a complex parameter?
	 */
	public boolean isComplex() {
		return fType == Type.COMPLEX;
	}
	
	/**
	 * Is this a real parameter?
	 */
	public boolean isReal() {
		return fType == Type.REAL;
	}
	
	/**
	 * Change the name of the parameter.
	 */
	public void setName(String name) {
		fName = name;
	}
	
	/**
	 * The name of the parameter.
	 */
	public String getName() {
		return fName;
	}
	
	/**
	 * The type of the parameter.
	 */
	public String getType() {
		return typeString(fType);
	}
	
	/**
	 * Set the type of this parameter by parsing a string.
	 * @param type The new type in string description.
	 */
	private void setType(String type) {
		if (type.equals("complex")){
			fType = Type.COMPLEX;
		}else if (type.equals("real")){
			fType = Type.REAL;
		}else if (type.equals("discrete")){
			logger.warning("Discrete parameter types are not supported yet, treating as REAL");
			fType = Type.REAL;
		} else {
			throw new IllegalArgumentException("Variable type " + type + " for " + getName()	+ " is invalid");
		}
	}
	
	/**
	 * Get the minimum value this output can have.
	 */
	public double getMinimum() { return fMinimum; }
	
	/**
	 * Get the maximum value this output can have.
	 */
	public double getMaximum() { return fMaximum; }
	
	/**
	 * Ignore NaN samples for this output?
	 */
	public boolean ignoreNaN() { return fIgnoreNaN; }
	
	/**
	 * Ignore Inf samples for this output?
	 */
	public boolean ignoreInf() { return fIgnoreInf; }
	
	/**
	 * Produce a readable text description for this parameter.
	 */
	public String toString(){
		return "Name=" + fName + " Type=" + typeString(fType) + " Oss=" + Util.arrayToString(fOutputSelect) + (fMinimum != Double.NEGATIVE_INFINITY ? " Min=" + fMinimum : "") + (fMaximum != Double.POSITIVE_INFINITY ? " Max=" + fMaximum : "");
		//return fName + " (" + typeString(fType) + ")";
	}
	
	/**
	 * Return the type of the parameter in string-form.
	 */
	private String typeString(Type type) {
		if(fType == Type.COMPLEX) return "complex";
		if (fType == Type.MODULUS) return "modulus";
		return "real";
	}
	
	
	/**
	 * Create a copy of another parameter, but alter the name, the type and the output select. Used internally for complex handling conversions.
	 * @param other The other object to inherit the other data from.
	 * @param name The new name of the parameter.
	 * @param type The new type.
	 * @param oss The new output select.
	 */
	private OutputDescription(OutputDescription other, String name, Type type, int[] oss) {
		this(other);
		fName = name;
		fType = type;
		fOutputSelect = oss;
	}
	
	
	/**
	 * Interpret the REAL part of this COMPLEX parameter as a REAL parameter, ignore the IMAG part.
	 */
	public OutputDescription convertToReal() {
		assert(fType == Type.COMPLEX);
		return new OutputDescription(this, getName() + "_REAL", Type.REAL, new int[] {fOutputSelect[0]});
	}
	
	/**
	 * Interpret the IMAG part of this COMPLEX parameter as a REAL parameter, ignore the REAL part.
	 */
	public OutputDescription convertToImag() {
		assert(fType == Type.COMPLEX);
		return new OutputDescription(this, getName() + "_IMAG", Type.REAL, new int[] {fOutputSelect[1]});
	}
	
	
	/**
	 * Interpret the MODULUS of this COMPLEX parameter as a REAL parameter.
	 * @return
	 */
	public OutputDescription convertToModulus() {
		assert(fType == Type.COMPLEX);
		return new OutputDescription(this, getName() + "_MOD", Type.MODULUS, fOutputSelect);
	}

	/**
	 * Interpret the PHASE of this COMPLEX parameter as a REAL parameter.
	 * @return
	 */
	public OutputDescription convertToPhase() {
		assert(fType == Type.COMPLEX);
		return new OutputDescription(this, getName() + "_PHASE", Type.PHASE, fOutputSelect);
	}

	
	/**
	 * Reset the counter that keeps track of the parameters in the simulator.
	 */
	public static void resetCounter() {
		counter = 0;		
	}
	
	/**
	 * Get the total amount of outputs that have been initialized to be read from the simulator so far.
	 */
	public static int getCounter() {
		return counter;
	}
	
	/**
	 * Which outputs from the simulator are used by this parameter? 
	 */
	public int[] getOutputSelect() {
		return fOutputSelect;
	}
	
	/**
	 * Get a list of the components that are used to model this output.
	 */
	public List<Node> getComponents() {
		return fComponents;
	}
	
	/**
	 * Get a list of all measures that are used to evaluate models for this output.
	 * This includes local and global measures
	 */
	public List<NodeConfig> getMeasures() {
		LinkedList<NodeConfig> res = new LinkedList<NodeConfig>();
		res.addAll(fGlobalMeasures);
		res.addAll(fLocalMeasures);
		return res;
	}

	/**
	 * Get a list of the global measures, measures that were defined for all outputs
	 */
	public List<NodeConfig> getGlobalMeasures() {
		return fGlobalMeasures;
	}

	/**
	 * Get a list of the local measures, measures that were defined for this output tag only
	 */
	public List<NodeConfig> getLocalMeasures() {
		return fLocalMeasures;
	}

	
	/**
	 * Get a list of modifiers that are used to modify the output.
	 */
	public List<NodeConfig> getModifiers() {
		return fModifiers;
	}
	
	
	/**
	 * Parse a config for this output (not applicable for input parameter descriptions) 
	 * @param config The node containing the info related to this parameter.
	 */
	@SuppressWarnings("unchecked")
	public void parseConfig(Node cfg, List<Node> runConfig) {
		
		// get attributes
		NodeConfig ncfg = NodeConfig.newInstance(cfg);
		fIgnoreNaN = ncfg.getBooleanAttrValue("ignoreNaN", "yes");
		fIgnoreInf = ncfg.getBooleanAttrValue("ignoreInf", "yes");
		
		// cast to Element, so that we can modify it
		Element config = (Element)cfg;
		
		// get the measures that were defined for all outputs (ie, the Measure tags not inside an output tag)
		fGlobalMeasures = ConfigUtil.getTagByNameAsList(runConfig, "Measure", false);
	
		// get the measures that were defined only for this output tag
		fLocalMeasures = NodeConfig.convertToNodeConfig(config.selectNodes("Measure"));
	
		// get all children of this output's config
		List<Node> list = config.selectNodes("child::*");
		
		// merge with runconfig
		List<Node> mergedConfig = ConfigUtil.updateConfig(runConfig, list);
		
		// now separate measures from other components in the merged config
		for (Node item : mergedConfig) {
			
			// see if it's a measure
			if (item.getName().equals("Measure")) {
				//do nothing since we already treated measures above
			}
			
			// see if it's a modifier
			else if (item.getName().equals("Modifier")) {
				
				// add to list of modifier configurations
				fModifiers.add(NodeConfig.newInstance(item));
				
				// update name of the parameter according to the modifier
				fName = fName + "_" + item.valueOf("@type");
			}
			
			else if (item.getName().equals("Outputs")) {
				//it does not make sense to add the Outputs tag again
			}
			
			// any other component (model builder, sample selector, etc)
			else {
				// add to list of overwritten components
				fComponents.add(item);
			}
		}
		
		
		// if no measures were explicitly defined, default to CrossValidation + MinMax
		if ((fLocalMeasures.size() + fGlobalMeasures.size()) == 0) {
			Element newMeasure = config.addElement("Measure");
			newMeasure.addAttribute("type", "CrossValidation");
			fLocalMeasures.add(NodeConfig.newInstance(newMeasure));
			Element newMeasure2 = config.addElement("Measure");
			newMeasure2.addAttribute("type", "MinMax");
			fLocalMeasures.add(NodeConfig.newInstance(newMeasure2));
			
			logger.info("No measures were defined for output " + this.getName() + ", defaulting to CrossValidation and MinMax");
		}
	}
}
