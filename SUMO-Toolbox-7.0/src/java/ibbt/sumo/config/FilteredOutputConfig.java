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
** Revision: $Id: FilteredOutputConfig.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.SUMOException;
import ibbt.sumo.util.Util;

import java.util.Vector;

public class FilteredOutputConfig implements OutputConfig {
	
	// the original output config
	OutputConfig fOutput;
	
	// outputs to filter
	int[] fFilter;
	
	
	// internally we filter the existing config using the filter
	public FilteredOutputConfig(OutputConfig outputConfig, int[] filter) throws SUMOException {
		fOutput = outputConfig;
		fFilter = filter;
	}
	
	
	// apply filter
	public OutputDescription[] getOutputDescriptions() {
		
		// create new array of output descriptions
		OutputDescription[] res = new OutputDescription[fFilter.length];
		
		// now process filter
		for (int i = 0; i < fFilter.length; ++i) {
			res[i] = fOutput.getOutputDescription(fFilter[i]);
		}
		return res;
	}


	// apply filter
	public OutputDescription getOutputDescription(int i) {
		assert 0 <= i && i < fFilter.length;
		return getOutputDescriptions()[i];
	}


	// return filter length
	public int getOutputDimension() {
		return fFilter.length;
	}
	
	
	// apply filter
	public String[] getOutputNames() {
		return ConfigUtil.dd2s(getOutputDescriptions());
	}

	public String getOutputNamesAsString(String delim) {
		String[] s = ConfigUtil.dd2s(getOutputDescriptions());
		return Util.join(s, delim);
	}

	public String getOutputName(int i) {
		assert 0 <= i && i < fFilter.length;
		return getOutputDescriptions()[i].getName();
	}


	public int[] getOutputSelect() {
		
		// Construct output selection string
		Vector<Integer> finalOutputSelect = new Vector<Integer>();
		for (OutputDescription output: getOutputDescriptions()) {
			int[] add = output.getOutputSelect();
			for (int i = 0; i < add.length; ++i) finalOutputSelect.add(add[i]);
		}
		int[] outputSelect = new int[finalOutputSelect.size()];
		for (int i = 0; i < outputSelect.length; ++i) outputSelect[i] = finalOutputSelect.get(i);
		return outputSelect;
	}


	public String getOutputSelectString() {
		return Util.arrayToString(getOutputSelect());
	}


	public boolean hasComplexOutputs() {
		for(OutputDescription d : getOutputDescriptions()){
			if(d.isComplex()) return true;
		}
		return false;
	}	
	
	
	
	// flat output dimension remains the same
	public int getSimulatorOutputDimension() {
		return fOutput.getSimulatorOutputDimension();
	}
}
