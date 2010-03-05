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
** Revision: $Id: InputDescription.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

public class InputDescription {
	
	// all the different things an input can be
	enum Type {
		NORMAL,		// normal input variable, has effect and is modelled
		CONSTANT	// constant input, will not be modelled but remains constant
	}
	
	// name of the input
	String fName;
	
	// the type of this input
	Type fType;
	
	// input select
	int[] fInputSelect;
	
	// constant (only set if type = CONSTANT)
	double fValue;
	
	// min/max
	private double fMinimum;
	private double fMaximum;
	
	// sampling is done automatically by the simulator
	private boolean fAutoSampling;
	
	// create new input description with input select
	public InputDescription(NodeConfig config, int inputSelect) {
		fName = config.valueOf("@name");
		fType = Type.NORMAL;
		fMinimum = config.getDoubleAttrValue("minimum", "-1");
		if (fMinimum == -1) fMinimum = config.getDoubleAttrValue("min", "-1");
		fMaximum = config.getDoubleAttrValue("maximum", "1");
		if (fMaximum == 1) fMaximum = config.getDoubleAttrValue("max", "1");
		fAutoSampling = config.getBooleanAttrValue("autoSampling", "false");
		//System.out.print( fMinimum );
		
		fInputSelect = new int[]{inputSelect};
	}
	
	
	// copy constructor
	public InputDescription(InputDescription other) {
		fName = other.fName;
		fType = other.fType;
		fMinimum = other.fMinimum;
		fMaximum = other.fMaximum;
		fInputSelect = new int[other.fInputSelect.length];
		for (int i = 0; i < fInputSelect.length; ++i) fInputSelect[i] = other.fInputSelect[i];
		//fValue = other.fValue;
	}
	
	
	// is this input sampled automatically?
	public boolean isSampledAutomatically() {
		return fAutoSampling;
	}
	
	
	// set the constant value
	public void setValue(double c) {
		fValue = c;
	}
	
	// get the constant value
	public double getValue() {
		return fValue;
	}
	
	// get the name of the input
	public String getName() {
		return fName;
	}
	
	// set the type
	
	public void setType(Type t) {
		fType = t;
	}
	
	// get the type
	public String getType() {
		return typeString(fType);
	}
	
	// get input select
	public int[] getInputSelect() {
		return fInputSelect;
	}
	
	/**
	 * Implements the equals function for parameter descriptions, same name = equal.
	 */
	public boolean equals(InputDescription other) {
		return fName.equals(other.fName);
	}
	
	/**
	 * Convert this description to a string.
	 */
	public String toString() {
		String s = "Name=" + fName + " Type=" + typeString(fType);
		if (fType == Type.CONSTANT) s += " Value=" + fValue;
		if (fAutoSampling) s += " autoSampling";
		return s;
	}
	
	/**
	 * Return the type of the parameter in string-form.
	 */
	private String typeString(Type type) {
		if(fType == Type.NORMAL) return "normal";
		else //if (fType == Type.CONSTANT)
		return "constant";
	}
	
	/**
	 * Get the minimum value this input can have.
	 */
	public double getMinimum() { return fMinimum; }
	
	/**
	 * Get the maximum value this input can have.
	 */
	public double getMaximum() { return fMaximum; }
}
