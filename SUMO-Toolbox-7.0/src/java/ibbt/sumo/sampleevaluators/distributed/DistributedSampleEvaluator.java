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

import ibbt.sumo.config.Config;
import ibbt.sumo.config.NodeConfig;
import ibbt.sumo.profiler.Profiler;
import ibbt.sumo.profiler.ProfilerManager;
import ibbt.sumo.sampleevaluators.SampleEvaluatorException;
import ibbt.sumo.sampleevaluators.SampleEvaluatorStatus;
import ibbt.sumo.sampleevaluators.ThreadedBasicSampleEvaluator;
import ibbt.sumo.util.SystemArchitecture;
import ibbt.sumo.util.SystemPlatform;
import ibbt.sumo.util.Util;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.LinkedList;
import java.util.Properties;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
/**
 * Evaluates samplepoints through a remote SGE administered cluster
 */
public abstract class DistributedSampleEvaluator extends ThreadedBasicSampleEvaluator {
	/**
	 * Location of the executable locally
	 */
	private String localExecutable = null;
	/**
	 * Location of the executable on the remote machine
	 */
	private String remoteExecutable = null;
	/**
	 * Executable dependencies
	 */
	private LinkedList<String> dependencyList = null;
	/**
	 * The backend that deals with the middleware
	 */
	private DistributedBackend backend = null;
	/**
	 * Options that should be passed to the executable
	 */
	private String options = null;
	
	/**
	 * Keep track of the compute node utilization 
	 */
	private Profiler utilizationProfiler = null;
	private ProfilerThread profilerThread;
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.distributed.DistributedSampleEvaluator");

	public DistributedSampleEvaluator(Config config) throws SampleEvaluatorException {
		super(config);
		
		//instantiate and configure the backend
		NodeConfig backendNode = NodeConfig.newInstance(config.self.selectSingleNode("Backend"));
		String backendClass = backendNode.valueOf("@type");

		try {
			backend = (DistributedBackend) Class.forName(backendClass).newInstance();
			backend.configure(config.context, backendNode);
		} catch (Exception e) {
			SampleEvaluatorException ex = new SampleEvaluatorException("Error instantiating backend class " + backendClass, e);
			logger.log(Level.SEVERE, ex.getMessage(), ex);
			throw ex;
		}

		SystemPlatform os = Util.resolvePlatformName( config.self.getAttributeValue("Executable", "platform") );
		SystemArchitecture  arch = Util.resolveArchitectureName( config.self.getAttributeValue("Executable", "arch") );
		String exe = config.context.getSimulatorConfig().getExecutable(os, arch).getText();
		dependencyList = config.context.getSimulatorConfig().getExecutableDependencies(os,arch);
		
		if (exe == null || exe.length() < 1) {
			SampleEvaluatorException ex = new SampleEvaluatorException(
					"SampleEvaluator requires an executable for: platform="
							+ os + " and arch=" + arch);
			logger.log(Level.SEVERE, ex.getMessage(), ex);
			throw ex;
		} else {
			logger.info("SampleEvaluator configured with executable " + exe
					+ " (platform=" + os + ", arch=" + arch + ")");
		}

		try {
			this.localExecutable = config.context.findFileInPath(exe).getAbsolutePath();
		} catch (FileNotFoundException e1) {
			SampleEvaluatorException ex = new SampleEvaluatorException(e1.getMessage(),e1);
			logger.log(Level.SEVERE, ex.getMessage(), ex);
			throw ex;
		}
		this.remoteExecutable = backend.getRemoteDirectory() + "/" + new File(localExecutable).getName();
		logger.finer("Remote executable set to " + this.remoteExecutable);

		readSimulatorOptions(config.context.getSimulatorConfig().getOptions());

		// create profiler

		String profName = "NodeUtilization";
		profName = ProfilerManager.makeUniqueProfilerName(profName);
		utilizationProfiler = ProfilerManager.getProfiler(profName);
		utilizationProfiler.setDescription("Estimation of the compute node utilization");
		utilizationProfiler.addColumn("time", "Time");
		utilizationProfiler.addColumn("totNodes", "Total number of nodes");
		utilizationProfiler.addColumn("numPending", "Total number of pending points");
		utilizationProfiler.addColumn("numWaiting", "Number of queued points");
		utilizationProfiler.addColumn("numRunning", "Number of running points");
		
		profilerThread = new ProfilerThread();
		new Thread(profilerThread).start();

		// start the sample evaluator thread (poll the SQM)
		new Thread(this).start();

		logger.fine("Distributed SampleEvaluator baseclass configured and initialized");
	}

	private void readSimulatorOptions(Properties p){
		Set<Object> keys = p.keySet();
		
		options = "";
		
		for(Object key : keys){
			options += "-" + key + "=" + p.getProperty(key.toString()) + " ";
		}
		
		options = options.trim();
		
		logger.fine("Remote SGE simulator configured with the following options: '" + options + "'");
	}
	
	/**
	 * Perform any necessary cleanups and stops the polling
	 */
	public void cleanup() {
		profilerThread.stop();
		backend.cleanup();
		super.cleanup();
	}

	/**
	 * Return status of this SE (eg., how many free nodes available)
	 */
	public SampleEvaluatorStatus getStatus() {
		return backend.getStatus();
	}
	
	public LinkedList<String> getDependencies(){
		return dependencyList;
	}

	protected String getLocalExe(){
		return localExecutable;
	}
	
	protected String getRemoteExe(){
		return remoteExecutable;
	}
	
	protected String getOptions(){
		return options;
	}
	
	protected DistributedBackend getBackend(){
		return backend;
	}
	
	private class ProfilerThread implements Runnable {
		//if the thread is active or not
		private boolean active = false;

		public ProfilerThread(){
		}

		public void stop(){
			active = false;
		}

		public void run() {
			active  = true;
			while(active){
				try {
					//sleep for at least 10 seconds
					long sleepTime = (long)Math.max(10000,getAverageEvaluationTime()/2);
					Thread.sleep(sleepTime);
				
					if(!active) break;
					
					// get sample evaluator resource information
					SampleEvaluatorStatus status = getStatus();
	
					// How many points have been fetched from the input queue but are sitting in a middleware queue
					int numWaiting = status.getNumInternalPending();
	
					// how many points are currently pending evaluation
					int numPending = getNumPendingSamples();
	
					// how many are currently running
					int numRunning = status.getNumRunning();
	
					// total number of nodes
					int totalNodes = status.getTotalNodes();
	
					utilizationProfiler.addEntry(new double[]{utilizationProfiler.getRowCount()+1,totalNodes, numPending,numWaiting,numRunning});
				} catch (InterruptedException e) {
					logger.log(Level.WARNING,e.getMessage(),e);
				} catch (Exception ex){
					//dont let a broken poller mess everything up
					logger.log(Level.SEVERE,"Stopping profiler thread: " + ex.getMessage(),ex);
					stop();
				}
			}
		}
	}
}
