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
import ibbt.sumo.util.SSHWrapper;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * This class forms a baseclass for all distributed resources
 * that must be contacted through a remote submit node (or front node)
 * reachable through SSH.
 */
public abstract class RemoteDistributedBackend extends DistributedBackend {
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.RemoteDistributedBackend");

	/*
	 * SSH information for logging into the headnode (key based authentication)
	 */
	private String user = null;
	private String knownHostsFile = null;
	private String identityFile = null;
	private String frontNode = null;
	private int frontNodePort = -1;
	private SSHWrapper sshWrapper = null;
	
	/**
	 * The poller to use to monitor submitted jobs
	 */
	private JobPoller poller = null;

	public RemoteDistributedBackend(){
		super();
	}
	
	public void configure(ContextConfig context, NodeConfig config) throws ConfigureException {
		super.configure(context, config);
		this.user = config.getOption("user",System.getProperty("user.name"));
		this.frontNode = config.getOption("frontNode",null);
		this.frontNodePort = config.getIntOption("frontNodePort",22);
		this.knownHostsFile = config.getOption("knownHostsFile",System.getProperty("user.home") + "/.ssh/known_hosts");
		this.identityFile = config.getOption("identityFile",System.getProperty("user.home") + "/.ssh/id_dsa");

		if(frontNode == null){
			ConfigureException ex = new ConfigureException("Missing front node!");
			logger.log(Level.SEVERE,ex.getMessage(),ex);
			throw ex;
		}
	}
	
	protected void connectToFrontNode() throws IOException {
		//Connect to the submit node
		sshWrapper = new SSHWrapper(identityFile, null,user, frontNode, frontNodePort);
		sshWrapper.connect();
	}
	
	protected SSHWrapper getSSHWrapper(){
		return sshWrapper;
	}
	
	protected void setPoller(JobPoller poller){
		this.poller = poller;
	}
	
	public JobPoller getPoller(){
		return poller;
	}
		
	public void setResultProcessor(ResultProcessor rp){
		super.setResultProcessor(rp);
	}
	
	public String getUser(){
		return user;
	}
	
	public String getFrontNode() {
		return frontNode;
	}

	public int getFrontNodePort() {
		return frontNodePort;
	}
	
	public String getIdentityFile() {
		return identityFile;
	}

	public String getKnownHostsFile() {
		return knownHostsFile;
	}
	
	public void cleanup(){
		if(sshWrapper.isConnected()){
			sshWrapper.close();
		}
		
		if(poller.isPolling()){
			poller.stopPolling();
		}
	}

	public abstract void submitJob(Job job) throws Exception; 
}
