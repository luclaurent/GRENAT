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

import ibbt.sumo.ConfigureException;
import ibbt.sumo.config.ContextConfig;
import ibbt.sumo.config.NodeConfig;
import ibbt.sumo.profiler.Profiler;
import ibbt.sumo.profiler.ProfilerManager;
import ibbt.sumo.sampleevaluators.SampleEvaluatorStatus;
import ibbt.sumo.sampleevaluators.distributed.Job;
import ibbt.sumo.sampleevaluators.distributed.JobEvent;
import ibbt.sumo.sampleevaluators.distributed.JobFinishedEventListener;
import ibbt.sumo.sampleevaluators.distributed.JobPoller;
import ibbt.sumo.sampleevaluators.distributed.RemoteDistributedBackend;
import ibbt.sumo.sampleevaluators.distributed.SSHResultPoller;
import ibbt.sumo.util.Pair;
import ibbt.sumo.util.SSHWrapper;
import ibbt.sumo.util.Util;

import java.io.File;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.logging.Level;
import java.util.logging.Logger;
/**
 * This backend can submit jobs through a remote front end to a SGE cluster
 * This class will also periodically check if a different queue is faster than the current
 * one and switch.
 */
public class RemoteSGEBackend extends RemoteDistributedBackend implements JobFinishedEventListener {
	
	private int pollInterval = -1;
	private String fileMask = null;
	private String[] queues = null;
	private String envCommand = "";
	private int queueRevisionRate = 10;
	private String curQueue = null;
	private int jobCounter = 0;
	
	private Profiler freeSlotsProfiler = null;
	private SampleEvaluatorStatus status = new SampleEvaluatorStatus(true,1);
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.distributed.sge.RemoteSGEBackend");
	
	public RemoteSGEBackend() {
		//Setup the profilers
		String profname = "FreeQueueSlots";
		profname = ProfilerManager.makeUniqueProfilerName(profname);
		freeSlotsProfiler = ProfilerManager.getProfiler(profname);
		freeSlotsProfiler.setDescription("Number of free queue slots");
		freeSlotsProfiler.addColumn("freeSlots","Number of free slots");
	}

	/**
	 * Initialize the backend and  configure the poller
	 * @throws Exception
	 */
	private void init() throws Exception {
		connectToFrontNode();
		
		// Create the remote directory if needed
		SSHWrapper ssh = getSSHWrapper();
		ssh.makeDir(getRemoteDirectory());

		JobPoller poller = new SSHResultPoller(ssh,getRemoteDirectory(),fileMask);
		poller.setInterval(this.pollInterval);
		poller.addListener(this);
		setPoller(poller);
		
		logger.info("RemoteSGEBackend initialized and ready to submit jobs");
	}
	
	public void cleanup(){
		super.cleanup();
	}
	
	public void configure(ContextConfig context, NodeConfig config) throws ConfigureException {
		super.configure(context,config);
		
		this.fileMask = config.getOption("fileMask","output_*");
		this.pollInterval = config.getIntOption("pollInterval",10);
		this.envCommand = config.getOption("environmentCommand","");
		this.queueRevisionRate = config.getIntOption("queueRevisionRate",10);
		
		String q = config.getOption("queues",null);
		
		if(q == null){
			throw new ConfigureException("You must specify at least one submission queue to use");
		}else{
			this.queues = q.split(",");
			this.curQueue = this.queues[0];
		}
		
		try {
			init();
		} catch (Exception e) {
			ConfigureException ex = new ConfigureException("Error during Init: " + e.getMessage(),e);
			logger.log(Level.SEVERE,ex.getMessage(),ex);
			throw ex;
		}
	}
	
	public SampleEvaluatorStatus getStatus(){
		try{
			HashMap<String,Pair<Integer,Integer>> map = getFreeSlots(this.curQueue); 
			
			status.setAvailableNodes(map.get(this.curQueue).getFirst());
			status.setTotalNodes(map.get(this.curQueue).getSecond());
	
			//remember that things may have changed in between these two calls
			int tot = getNumJobs();
			int nr = getNumRunning();
			
			status.setNumRunning(nr);
			status.setNumInternalPending(Math.max(0, tot - nr));
		}catch(NullPointerException e){
			logger.warning("Getting sample evaluator status failed, using previous status..");
		}
		return status;
	}

	/**
	 * Get the number of jobs that are currently waiting in the SGE queue
	 */
	public int getNumRunning(){
		
		//print out queues, remove header and count the number of waiting jobs
		String cmd = envCommand + "qstat -u " + getUser() + " -s r | egrep -v \"\\-\\-\\-|job\\-ID\" | wc -l";
		try {
			String s = getSSHWrapper().remoteExec(cmd);
			return Integer.valueOf(s);			
		}catch (Exception e) {
			logger.log(Level.SEVERE,e.getMessage(),e);
			return 0;
		}
	}
	
	/**
	 * Get the number of jobs that are currently waiting in the SGE queue
	 */
	public int getNumWaiting(){	
		//print out queues, remove header and count the number of waiting jobs
		String cmd = envCommand + "qstat -u " + getUser() + " -s p | egrep -v \"\\-\\-\\-|job\\-ID\" | wc -l";
		try {
			String s = getSSHWrapper().remoteExec(cmd);
			return Integer.valueOf(s);			
		}catch (Exception e) {
			logger.log(Level.SEVERE,e.getMessage(),e);
			return 0;
		}
	}
	
	/**
	 * Get the number of jobs that are currently in the SGE system
	 */
	public int getNumJobs(){	
		//print out queues, remove header and count the number of waiting jobs
		String cmd = envCommand + "qstat -u " + getUser() + " | egrep -v \"\\-\\-\\-|job\\-ID\" | wc -l";
		try {
			String s = getSSHWrapper().remoteExec(cmd);
			return Integer.valueOf(s);			
		}catch (Exception e) {
			logger.log(Level.SEVERE,e.getMessage(),e);
			return 0;
		}
	}
	
	/**
	 * Return the queue with most available slots
	 */
	public Pair<String, Pair<Integer,Integer>> getBestQueue(){
		if(queues.length < 1) return null;
		
		HashMap<String,Pair<Integer,Integer>> qs = new HashMap<String,Pair<Integer,Integer>>();
		qs = getFreeSlots(Util.join(queues, "|"));
		
		if(qs == null || qs.isEmpty()){
			return new Pair<String,Pair<Integer,Integer>>(queues[0],new Pair<Integer,Integer>(1,1));
		}else{
			String bestq = "";
			Pair<Integer,Integer> best = new Pair<Integer,Integer>(-1,-1);
			Pair<Integer,Integer> free = new Pair<Integer,Integer>(-1,-1);
			
			for(String s : qs.keySet()){
				free = qs.get(s);
				
				if(free.getFirst() > best.getFirst()){
					bestq = s;
					best = free;
				}
			}
			if(!curQueue.equals(bestq)){
				logger.finer("Found better queue " + bestq + " with " + best.getFirst() + " free slots");
				freeSlotsProfiler.addEntry(new double[]{best.getFirst()});
			}
			return new Pair<String, Pair<Integer,Integer>>(bestq,best);
		}
	}
	
	/**
	 * Get the number of free spots on the queues that match queueFilter
	 */
	private HashMap<String,Pair<Integer,Integer>> getFreeSlots(String queueFilter) {
		HashMap<String,Pair<Integer,Integer>> free = new HashMap<String,Pair<Integer,Integer>>();
		LinkedList<String> res = null;
		String[] tmp = null;
		Pair<Integer,Integer> pair = null;
		
		//TODO note, qstat can be configured to give XML output
		
		//print out queues, remove headers and extract queue name, available slots and total slots
		String cmd = envCommand + "qstat -g c -q \"" + queueFilter + "\" -u " + getUser() 
					+ " | egrep -v \"CLUSTER|---\" | awk '{print $1 \" \" $4 \" \" $5}'";
		try {
			res = getSSHWrapper().remoteExecAsList(cmd);
			
			for(String s : res){
				tmp = s.split(" ");
				pair = new Pair<Integer,Integer>(Integer.valueOf(tmp[1]),Integer.valueOf(tmp[2]));
				free.put(tmp[0],pair);
			}
			
			return free;
		}catch (Exception e) {
			logger.log(Level.SEVERE,e.getMessage(),e);
			return null;
		}
	}

	/**
	 * Submit a job to the SGE middleware
	 */
	public void submitJob(Job job) throws Exception {
		++jobCounter;
		
		if(jobCounter % queueRevisionRate == 1 && queues.length > 1){
			//See if there is a queue available with more slots, if so switch
			this.curQueue = getBestQueue().getFirst();
		}
		
		if(job.getExecutable() == null){
			Exception ex = new Exception("Executable may not be null when submitting jobs!");
			logger.log(Level.SEVERE,ex.getMessage(),ex);
			throw ex;
		}
		
		//Compose the executable that must be run
		String command = "";
		if(job.getArguments() == null || job.getArguments().length() < 1){
			command = job.getExecutable();
		}else{
			command = job.getExecutable() + " " + job.getArguments();
		}
		logger.finest("SGE remote executable command is '" + command + "'");
		
		//Now build the actual submission command
		StringBuffer sgeCommand = new StringBuffer();
		//first ensure the shell environment is setup
		sgeCommand.append(envCommand);
		//add the submission program
		sgeCommand.append(" qsub");
		//add the queue to use
		if(queues.length > 0) sgeCommand.append(" -q ").append(this.curQueue);
		
		//we dont need myrinet
		sgeCommand.append(" -l myrinet=false");
		
		//inherit the environment
		sgeCommand.append(" -V");
		
		//add the output file for stdout
		if(job.getStdout() != null && job.getStdout().length() > 0){
			sgeCommand.append(" -o ").append(getRemoteDirectory() + "/" + job.getStdout());
		}
		
		//add the output file for stderr
		if(job.getStderr() != null && job.getStderr().length() > 0){
			sgeCommand.append(" -e ").append(getRemoteDirectory() + "/" + job.getStderr());
		}

		//tell qsub that we are running a binary and not a script
		sgeCommand.append(" -b y ");
		
		//now add the actual command
		sgeCommand.append(command);
		
		//Stage input sandbox
		for(String s : job.getInputSandbox()){
			getSSHWrapper().scpTo(s, getRemoteDirectory() + "/" + new File(s).getName());
			logger.info("Staged input sandbox file: " + s);
		}
		
		//Now perform the actual submission
		getSSHWrapper().remoteExec(sgeCommand.toString());
		
		logger.finest("Submitted SGE job with the following command '" + sgeCommand + "'");
		
		job.setSubmittedOn(System.currentTimeMillis());
		addJob(job.getStdout(),job);
		logger.finest("Submitted job:\n" + job.toString());
		
		if(!getPoller().isPolling()){
			logger.info("Poller thread not running, starting now...");
			new Thread(getPoller()).start();
		}
	}
	
	/**
	 * A job is finished, retrieve the necessary files
	 */
	public void jobFinished(JobEvent event){
		String key = event.getKey();
		//the key returned is the full path of the outpufile on the remote machine
		//we only want the output filename, since that is what we used on submission
		key = new File(key).getName();
		Job job = getJob(key);
		
		if(job == null){
			logger.severe("No job corresponds to key " + key + "!!!");
			return;
		}
		
		String dest;
		
		logger.finest("Downloading outputsandbox files to " + getLocalDirectory());
		//Download the output sandbox files to the local directory, remove them from the server
		for(String s : job.getOutputSandbox()){
			s = getRemoteDirectory() + "/" + s;
			dest = getLocalDirectory() + File.separator + new File(s).getName();
			
			try {
				getSSHWrapper().scpFrom(s,dest);
			} catch (Exception e) {
				logger.log(Level.SEVERE,"Failed to retrieve outputsandbox file " + s + " and copy it to " + dest,e);
			}
			
			try {
				getSSHWrapper().removeFile(s);
			} catch (Exception e) {
				logger.log(Level.WARNING,"Failed to remove retrieved outputsandbox file " + s,e);
			}
		}

		//Job is fully completed
		job.setCompletedOn(System.currentTimeMillis());
		
		//Notify the client class that a job has been completed
		if(getResultProcessor() != null){
			logger.finest("Notifying resultprocessor that job output is ready in " + getLocalDirectory());
			getResultProcessor().processResult(getLocalDirectory(), job);
		}else{
			logger.warning("No result processor configured, job ignored");
		}
		//Remove the job from the pending list
		removeJob(key);
	}


}
