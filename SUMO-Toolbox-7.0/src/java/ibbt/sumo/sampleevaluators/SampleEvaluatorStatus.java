package ibbt.sumo.sampleevaluators;
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
** Revision: $Id$
**-----------------------------------------------------------------------------------------
*/

public class SampleEvaluatorStatus {
	private boolean active;
	private int numAvailableNodes;
	private int numTotalNodes;
	private int numRunning;
	private int numInternalPending;
	private String errorMessage;
	private Exception error;
	
	/**
	 * Constructor. Initializes to default values.
	 */
	public SampleEvaluatorStatus() {
		setActive(true);
		numTotalNodes = 1;
		numAvailableNodes = numTotalNodes;
		numInternalPending = 0;
		numRunning = numTotalNodes;
		errorMessage = "";
	}

	public SampleEvaluatorStatus(boolean active, int availableNodes) {
		setActive(active);
		numAvailableNodes = availableNodes;
		errorMessage = "";
	}

	public void disable(Exception reason) {
		setActive(false);
		error = reason;
		errorMessage = reason.getMessage();
	}
	
	public void setActive(boolean active){
		this.active = active;
	}
	
	public boolean isActive(){
		return active;
	}
	
	public int getAvailableNodes(){
		return numAvailableNodes;
	}
	
	public void setAvailableNodes(int n) {
		numAvailableNodes = n;
	}
	
	public int getTotalNodes(){
		return numTotalNodes;
	}
	
	public void setTotalNodes(int n){
		numTotalNodes = n;
	}
	
	public int getNumInternalPending(){
		return numInternalPending;
	}
	
	public void setNumInternalPending(int n){
		numInternalPending = n;
	}
	
	public void setNumRunning(int n){
		numRunning = n;
	}
	
	public int getNumRunning(){
		return numRunning;
	}
	
	public String getErrorMessage(){
		return errorMessage;
	}
	
	public Exception getError(){
		return error;
	}
}
