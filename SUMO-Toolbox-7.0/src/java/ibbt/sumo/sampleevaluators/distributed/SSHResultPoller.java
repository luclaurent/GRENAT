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

import ibbt.sumo.util.SSHWrapper;

import java.io.IOException;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * This class will poll for result files (files with doubles)
 * through ssh on a remote machine. Once read the files will be removed.
 */
public class SSHResultPoller extends JobPoller {

	private SSHWrapper ssh = null;
	private boolean continuePolling = false;
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.SSHResultPoller");
		
	public SSHResultPoller(SSHWrapper ssh, String directory, String mask) {
		super(directory);
		setMask(mask);
		this.ssh = ssh;
	}
	
	public boolean isPolling(){
		return continuePolling;
	}
	
	public void stopPolling(){
		continuePolling = false;
		logger.fine("continuePolling set to false");
	}
	
	public void run() {
		if(continuePolling){
			logger.severe("Illegal to start a thread more than twice!");
			return;
		}
		
		logger.info("Poller started on remote directory " + getLocation() 
					+ ", with filemask " + getMask() + " and interval " + getInterval());
		
		continuePolling = true;

		if(!ssh.isConnected()){
			logger.warning("Session not yet connected, connecting now");
			try {
				ssh.connect();
			} catch (IOException e) {
				logger.log(Level.SEVERE,e.getMessage(),e);
				return;
			}
		}
		
		LinkedList<String> files = null;
		
		while(continuePolling){
			logger.finest("polling for files that match " + getMask());
			try {
				files = listFiles();
				logger.finest(files.size() + " files found that match " + getMask());

				for(String f : files){
					try{
						if(ssh.getFileSize(f) > 0){
							logger.finest("Poller sending JobEvent for file " + f);
							JobEvent event = new JobEvent(this,f);
							sendEvent(event);
						}else{
							logger.fine("Ignoring incomplete file " + f);
						}
					} catch (Exception e) {
						logger.log(Level.WARNING,"Error while polling for file: " + f,e);
						
						try{	
							Thread.sleep(200);
						} catch (InterruptedException ex) {
							logger.log(Level.WARNING,ex.getMessage(),ex);
						}
					}
				}
			} catch (Exception e) {
				logger.log(Level.WARNING,"Error during polling: ",e);
				//stopPolling();
			}
			
			try{
				logger.finest("Polling thread sleeping for " + getInterval() + " seconds");
				Thread.sleep(getInterval() * 1000);
			} catch (InterruptedException e) {
				logger.log(Level.WARNING,e.getMessage(),e);
			}
		}
		logger.fine("Polling thread stopping...");
	}
	
	private LinkedList<String> listFiles() throws Exception{
		String findCommand = "find " + getLocation() + " -maxdepth 1 -type f -name \"" + getMask() + "\"";
		LinkedList<String> files = ssh.remoteExecAsList(findCommand);
		return files;
	}
}
