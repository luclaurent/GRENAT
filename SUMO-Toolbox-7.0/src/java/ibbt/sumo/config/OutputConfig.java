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
** Revision: $Id: OutputConfig.java 6376 2009-12-11 10:13:11Z dgorissen $
**-----------------------------------------------------------------------------------------
*/

public interface OutputConfig {

	/**
	 * Get the number of output as defined by this config.
	 */
	public int getOutputDimension();
	
	/**
	 * Get the descriptiobs for each output as defined by this config.
	 */
	public OutputDescription[] getOutputDescriptions();
	
	/**
	 * Get the description of output i.
	 * @param i The i'th description (counting from 0).
	 * @return The description of the output.
	 */
	public OutputDescription getOutputDescription(int i);
	
	
	/**
	 * Get an array corresponding to the (unique) names of all the outputs.
	 */
	public String[] getOutputNames();
	
	/**
	 * Get the name of output i.
	 * @param i The i'th output (counting from 0).
	 * @return The name of the output.
	 */
	public String getOutputName(int i);
	
	
	/**
	 * Does this config contain complex outputs?
	 */
	public boolean hasComplexOutputs();
	
	
	
	/**
	 * Get the array which corresponds to the indices of the raw outputs
	 * that have to be selected from samples. These raw values are then
	 * converted using the proper complex handling to the values that
	 * correspond to the output descriptions.
	 * @return An array of indices.
	 */
	public int[] getOutputSelect();
	
	/**
	 * Does the same as getOutputSelect but returns the array as a string.
	 * @return String of array of indices.
	 */
	public String getOutputSelectString();
	
	/**
	 * Gives the total amount of raw, unprocessed outputs as returned by samples.
	 */
	public int getSimulatorOutputDimension();
	
}
