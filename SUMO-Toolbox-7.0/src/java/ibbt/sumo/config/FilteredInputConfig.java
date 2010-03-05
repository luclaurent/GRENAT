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
** Revision: $Id: FilteredInputConfig.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

import ibbt.sumo.SUMOException;

import java.util.List;
import java.util.logging.Logger;

import org.dom4j.Node;

public class FilteredInputConfig implements InputConfig {
	
	// logger
	private static Logger logger = Logger.getLogger("ibbt.sumo.config.FilteredInputConfig");
	
	
	// the original output config
	InputConfig fInput;
	
	// inputs to filter
	int[] fFilter;
	
	// internally we filter the existing config using the filter
	public FilteredInputConfig(InputConfig inputConfig, int[] filter) throws SUMOException {
		fInput = inputConfig;
		fFilter = filter;
		
		// must leave at least one dimension unfiltered
		if (fFilter.length == 0) {
			String msg = "Can't filter all inputs, need at least one unfiltered dimension";
			logger.severe(msg);
			throw new SUMOException(msg);
		}
		
		// check all filter dimensions for valid values
		for (int i = 0; i < fFilter.length; ++i) {
			if (fFilter[i] < 0 || fFilter[i] >= fInput.getInputDimension()) {
				String msg = "Invalid filter, trying to filter dimension " + fFilter[i] + " while there are only " + fInput.getInputDimension();
				logger.severe(msg);
				throw new SUMOException(msg);
			}
		}
	}
	
	public List<Node> getConstraints() {
		// pass-through
		return fInput.getConstraints();
	}

	public InputDescription[] getInputDescriptions() {
		// create new array of output descriptions
		InputDescription[] res = new InputDescription[fFilter.length];
		
		// now process filter
		for (int i = 0; i < fFilter.length; ++i) {
			res[i] = fInput.getInputDescription(fFilter[i]);
		}
		return res;
	}

	// apply filter
	public InputDescription getInputDescription(int i) {
		assert 0 <= i && i < fFilter.length;
		return getInputDescriptions()[i];
	}
	
	public int getInputDimension() {
		return fFilter.length;
	}

	public String getInputName(int i) {
		assert 0 <= i && i < fFilter.length;
		return getInputDescriptions()[i].getName();
	}
	
	public String[] getInputNames() {
		return ConfigUtil.dd2s(getInputDescriptions());
	}
	
	public int getNrConstant() {
		return fInput.getNrConstant();
	}


	public int getSimulatorInputDimension() {
		return fInput.getSimulatorInputDimension();
	}
	
	public InputDescription[] getConstantInputDescriptions() {
		return fInput.getConstantInputDescriptions();
	}
}
