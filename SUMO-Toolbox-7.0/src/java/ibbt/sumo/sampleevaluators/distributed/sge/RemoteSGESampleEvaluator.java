package ibbt.sumo.sampleevaluators.distributed.sge;
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
import ibbt.sumo.sampleevaluators.SampleEvaluatorException;
import ibbt.sumo.sampleevaluators.SamplePoint;
import ibbt.sumo.sampleevaluators.distributed.DistributedSampleEvaluator;
import ibbt.sumo.sampleevaluators.distributed.Job;
import ibbt.sumo.sampleevaluators.distributed.RemoteDistributedBackend;
import ibbt.sumo.sampleevaluators.distributed.ResultProcessor;
import ibbt.sumo.util.SSHWrapper;
import ibbt.sumo.util.Util;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
/**
 * Evaluates samplepoints through a remote SGE administered cluster
 */
public class RemoteSGESampleEvaluator extends DistributedSampleEvaluator implements	ResultProcessor {
	
	/*
	 * SSH information for logging into the headnode (key based authentication)
	 */
	private SSHWrapper sshWrapper = null;
	
	/**
	 * The prefix is to prevent output files from different runs from interfering
	 */
	private static String prefix = Util.getRandomPrefix();
	/**
	 * List of pending sample points
	 */
	Map<String, SamplePoint> pointMap = new HashMap<String, SamplePoint>();
	/**
	 * The backend that deals with the middleware
	 */
	private RemoteDistributedBackend backend = null;
	
	private int filenameCounter = 0;
	private int completedCounter = 0;
	
	private static Logger logger = Logger
			.getLogger("ibbt.sumo.sampleevaluators.distributed.sge.RemoteSGESampleEvaluator");

	public RemoteSGESampleEvaluator(Config config) throws SampleEvaluatorException {
		super(config);

		try {
			backend = (RemoteDistributedBackend)getBackend();
			backend.setResultProcessor(this);
			backend.getPoller().setMask("output_" + prefix + "_*");

			init();
		} catch(ClassCastException e){
			SampleEvaluatorException ex = new SampleEvaluatorException("The remote distributed backend is of the wrong type: " + getBackend().getClass());
			logger.log(Level.SEVERE, ex.getMessage(), ex);
			throw ex;
		} catch (Exception e) {
			SampleEvaluatorException ex = new SampleEvaluatorException("Error during Init: " + e.getMessage(),e);
			logger.log(Level.SEVERE, ex.getMessage(), ex);
			throw ex;
		}

		logger.fine("Remote SGESampleEvaluator configured and initialized");
	}

	/**
	 * Setup the SSH session and stage the necessary files
	 * @throws Exception
	 */
	private void init() throws Exception {
		//Connect to the submit node
		sshWrapper = new SSHWrapper(backend.getIdentityFile(),
									backend.getKnownHostsFile(),
									backend.getUser(),
									backend.getFrontNode(),
									backend.getFrontNodePort());
		sshWrapper.connect();

		//Stage the executable
		sshWrapper.scpTo(getLocalExe(),getRemoteExe());
		logger.finer("Staged executable " + getLocalExe());
		//make executable
		sshWrapper.remoteExec("chmod +x " + getRemoteExe());
		logger.finer("Executable made executable");
		
		//stage executable dependencies
		logger.finer("Number of dependencies to stage: " + getDependencies().size());
		String remoteFile;
		for(String s : getDependencies()){
			if(new File(s).isDirectory()){
				logger.warning("The SGE SampleEvaluator does not support directories as dependencies, ignoring directory " + s);
			}else{
				remoteFile = backend.getRemoteDirectory() + "/" + new File(s).getName();
				sshWrapper.scpTo(s,remoteFile);
			}
		}
		
		logger.fine("RemoteSGESampleEvaluator initialized");
	}

	/**
	 * Perform any necessary cleanups and stops the polling
	 */
	public void cleanup() {
		pointMap.clear();
		sshWrapper.close();
		backend.cleanup();
		super.cleanup();
	}

	/**
	 * Evaluate a sample
	 */
	public void evaluate(SamplePoint point) {
		++filenameCounter;
		
		//Create the job object represenging this sample point
		String date = Util.getDateTime();
		String outputFilename = "output_" + prefix + "_" + date + "_" + filenameCounter + ".dat";
		String errorFilename = "error_" + prefix + "_" + date + "_" + filenameCounter + ".dat";

		// Pass input parameters on the command line
		
		String args = (point.inputsToString() + " " + getOptions()).trim();
		
		Job job = new Job();
		job.setExecutable(getRemoteExe());
		job.setArguments(args);
		job.setStdout(outputFilename);
		job.setStderr(errorFilename);
		job.addToOutputSandbox(errorFilename);
		job.addToOutputSandbox(outputFilename);

		try {
			//submit the job
			backend.submitJob(job);

			//In this case a job is uniquely defined by its output filename
			pointMap.put(job.getStdout(), point);

		} catch (Exception e) {
			logger.log(Level.SEVERE, "Failed to submit SGE job remotely: " + e.getMessage(),e);
			submitFailedSample(point);
		}
	}

	/**
	 * A job is finished, turn the Job object into a sample point and update the queues
	 */
	public void processResult(String directory, Job job) {
		String localOutputFile = directory + File.separator + new File(job.getStdout()).getName();
		String localErrorFile = directory + File.separator + new File(job.getStderr()).getName();
		
		logger.finest("Starting processing result of file " + job.getStdout());
		logger.finest("The stderr log of this job is " + Util.getFileContent(localErrorFile));
		
		SamplePoint point = pointMap.get(job.getStdout());

		if(point == null){
			logger.warning("Ignoring and deleting file from previous run: " + localOutputFile);
			try {
				new File(localOutputFile).delete();
			} catch (Exception e) {
				logger.warning("Failed to remove file from previous run " + localOutputFile);
			}
			return;
		}
		
		try {
			point.outputsFromFile(new File(localOutputFile));
			logger.finest("Added result for file " + job.getStdout() + " from file " + localOutputFile);

			// finally add point to evaluated to queue for processing by the modeller
			submitEvaluatedSample(point);
			++completedCounter;
			logger.fine("Finished results: " + completedCounter);

			// Remove finished point from map
			pointMap.remove(job.getStdout());

			// delete the processed output and error files
			try {
				new File(localOutputFile).delete();
			} catch (Exception e) {
				logger.warning("Failed to remove output file " + localOutputFile);
			}

			try {
				new File(localErrorFile).delete();
			} catch (Exception e) {
				logger.warning("Failed to remove error file " + localOutputFile);
			}
		} catch (Exception e) {
			logger.log(Level.SEVERE, e.getMessage(), e);
		}
	}

}
