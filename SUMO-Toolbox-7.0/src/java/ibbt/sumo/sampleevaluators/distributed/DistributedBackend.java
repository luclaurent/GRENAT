package ibbt.sumo.sampleevaluators.distributed;
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

import ibbt.sumo.ConfigureException;
import ibbt.sumo.config.ContextConfig;
import ibbt.sumo.config.NodeConfig;
import ibbt.sumo.sampleevaluators.SampleEvaluatorStatus;

import java.util.HashMap;
/**
 * This class is a baseclass for all distributed resource backends.
 * Such backends typically have their own SampleEvaluator.
 */
public abstract class DistributedBackend {
	/**
	 * Which object to notify of a finished job, should be the SampleEvaluator
	 */
	private ResultProcessor resultProcessor = null;
	/**
	 * The working directory on the remote machine
	 */
	private String remoteDirectory = null;
	/**
	 * The working directory on the local machine
	 */
	private String localDirectory = null;
	/**
	 * Maintins a list of submitted jobs
	 */
	private HashMap<String,Job> jobs = new HashMap<String, Job>();

	public DistributedBackend(){
	}
	
	public void configure(ContextConfig context, NodeConfig config) throws ConfigureException {
		this.remoteDirectory = config.getOption("remoteDirectory","~/output");
		this.localDirectory = config.getOption("localDirectory",context.getTempDir());
	}
	
	protected Job getJob(String id){
		return jobs.get(id);
	}

	protected void addJob(String id, Job j){
		jobs.put(id,j);
	}
	
	protected void removeJob(String id){
		jobs.remove(id);
	}
	
	public void setResultProcessor(ResultProcessor rp){
		resultProcessor = rp;
	}
	
	protected ResultProcessor getResultProcessor(){
		return resultProcessor;
	}
	
	public String getLocalDirectory() {
		return localDirectory;
	}

	protected void setLocalDirectory(String localDirectory) {
		this.localDirectory = localDirectory;
	}

	protected void setRemoteDirectory(String dir){
		remoteDirectory = dir;
	}

	public String getRemoteDirectory(){
		return remoteDirectory;
	}
	
	/**
	 * Release resources
	 */
	public abstract void cleanup();
	
	/**
	 * Submit a job for evaluation
	 */
	public abstract void submitJob(Job job) throws Exception; 
	
	/**
	 * Get status information related to this backend and the resources it manages
	 */
	public abstract SampleEvaluatorStatus getStatus();
}
