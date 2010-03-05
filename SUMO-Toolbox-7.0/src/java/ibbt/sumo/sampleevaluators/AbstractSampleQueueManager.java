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

import ibbt.sumo.config.Config;
import ibbt.sumo.profiler.ChartType;
import ibbt.sumo.profiler.Profiler;
import ibbt.sumo.profiler.ProfilerManager;
import ibbt.sumo.sampleevaluators.EvaluationUnit.EvaluationState;

import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.logging.Level;
import java.util.logging.Logger;


/**
 * This class manages input, output and pending queues for samples that need to be
 * evaluated or have been evaluated. This abstract base class does not implement the input
 * queue, which is covered by the derived class.
 */
abstract public class AbstractSampleQueueManager {

	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.AbstractSampleQueueManager");
	
	/**
	 * Holds the evaluated samples
	 */
	private Queue<SamplePoint> fEvaluatedQueue = new ConcurrentLinkedQueue<SamplePoint>();
	/**
	 * Holds the evaluation units that are currently pending evaluation
	 */
	private HashSet<EvaluationUnit> fPendingSet = new HashSet<EvaluationUnit>();
	
	/**
	 * Keeps record of which samples have been submitted multiple times (e.g., in case of failure the first time) 
	 */
	private Hashtable<EvaluationUnit,Integer> resubmissionMap = new Hashtable<EvaluationUnit,Integer>();
	/**
	 * Thread that monitors the pending queue and removes entries that take too long
	 */
	private PendingMonitorThread pendingMonitor = null;
	
	/**
	 * Profiler used for plotting the evaluation time for one point.
	 */
	private Profiler evaluationTimeProfiler = null;

	/**
	 * Profiler used for plotting the number of samples evaluated per minute
	 */
	private Profiler samplesPerMinuteProfiler = null;
	
	/**
	 * Profiler used for plotting the speedup
	 */
	private Profiler speedupProfiler = null;

	/**
	 * The average evaluation time for one point (in milliseconds).
	 */
	private double fAverageEvaluationTime = 0;
	
	/**
	 * Calculate the average evaluation time based on the previous windowSize number of samples
	 */
	private int windowSize = 0;
	
	/**
	 * Hold the past windowSize evaluation times
	 */
	private double[] evaluationTimeWindow = null;
	
	/**
	 * The number of points that have successfully been evaluated.
	 */
	private long fNumEvaluatedPoints = 0;
	
	private int maxResubmissions = 1;
	
	private long startTime = 0;
	
	public AbstractSampleQueueManager(Config config) {
		startTime = System.currentTimeMillis();
		
		windowSize = config.self.getIntOption("windowSize",7);
		if(windowSize < 1){
			logger.warning("Invalid window size given, set to 7");
			windowSize = 7;
		}
		evaluationTimeWindow = new double[windowSize];
		//initialize
		for(int i=0; i < windowSize ; ++i) evaluationTimeWindow[i] = 0;
		
		maxResubmissions = config.self.getIntOption("maxResubmissions",1);
		double timeout = config.self.getDoubleOption("sampleTimeout",-1);
		pendingMonitor = new PendingMonitorThread(timeout);
		new Thread(pendingMonitor).start();
		
		// create profiler
		String profName = ProfilerManager.makeUniqueProfilerName("SampleEvaluationTime");
		evaluationTimeProfiler = ProfilerManager.getProfiler(profName);
		evaluationTimeProfiler.setPreferredChartType(ChartType.AREA);
		evaluationTimeProfiler.setDescription("Sample evaluation time.");
		evaluationTimeProfiler.addColumn("numSamples", "Number of samples");
		evaluationTimeProfiler.addColumn("evalTime", "Time spent evaluating (s)");
		evaluationTimeProfiler.addColumn("totalTime", "Total processing time (s)");
		
		// create profiler
		profName = "Speedup";
		profName = ProfilerManager.makeUniqueProfilerName(profName);
		speedupProfiler = ProfilerManager.getProfiler(profName);
		speedupProfiler.setDescription("Speedup over Serial evaluation");
		speedupProfiler.addColumn("speedup", "Estimated speedup over serial evaluation");
		
		//create profiler
		profName = "SamplesPerMinute";
		profName = ProfilerManager.makeUniqueProfilerName(profName);
		samplesPerMinuteProfiler = ProfilerManager.getProfiler(profName);
		samplesPerMinuteProfiler.setDescription("Numer of samples evaluated per minute");
		samplesPerMinuteProfiler.addColumn("samplesPerMinute", "Number of samples evaluated per minute");
	}
	
	
	/**
	 * Prepare the passed sample points for evaluation and add them to the queue
	 */
	public void submitNewSamples(SamplePoint[] points){
		if(points.length < 1) return;
		SamplePoint sp = null;
		
		for (int i = 0; i < points.length; ++i) {
			sp = points[i];
			
			synchronized (fPendingSet) {
				//dont add a point if it is already pending
				if(fPendingSet.contains(sp)){
					logger.warning("Not adding point " + sp.getId() + " to the input queue since it is already pending evaluation");
				}else{		
					EvaluationUnit unit = new EvaluationUnit(sp);
					flagAsPending(unit);
					unit.setAddTime();
					addToInputQueue(unit);
				}
			}
		}
	}
	
	/**
	 * Add a new evaluation unit to the input queue
	 */
	abstract protected void addToInputQueue(EvaluationUnit unit);
	
	/**
	 * Add & process one new sample.
	 * @param point The sample to be submitted.
	 */
	public void submitNewSample(SamplePoint point) {
		submitNewSamples(new SamplePoint[]{point});
	}
	
	/**
	 * Return the number of samples that are currently waiting to be evaluated.
	 * @return The number of samples.
	 */
	public int pendingSamples() {
		synchronized (fPendingSet) {
			return fPendingSet.size();
		}
	}
	
	/**
	 * Return the number of samples that have been evaluated already.
	 * @return The number of samples.
	 */
	public int evaluatedSamples() {
		return fEvaluatedQueue.size();
	}

	/**
	 * Get the average time it takes to evaluate one single sample.
	 */
	public double averageEvaluationTime() {
		return fAverageEvaluationTime;
	}
	
	/**
	 * Signal that a set of samples have been evaluated
	 * Valid termination states include:
	 *   EVALUATED: The point was evaluated correctly.
	 *   AGAIN: The point wasn't evaluated, but might succeed a next time (for cluster failover, reintroduce in new samples queue).
	 *   FAILED: The point can't be evaluated.
	 */
	public void submitEvaluatedSample(EvaluationUnit unit) {
		long id = -1;
		
		synchronized (fPendingSet) {
			
			// get id of the unit
			id = unit.getId();
			
			// point not in pending queue, strange?!
			if (!fPendingSet.contains(unit)) {
				logger.warning("A point (id=" + id + ") was evaluated that is not in the pending list, maybe it was assumed lost.  Using it anyway.");
			}				
			// remove from pending queue
			else {
				fPendingSet.remove(unit);
				//System.out.println("---- removed point " + point.getId() + " from pending queue");
			}
			
			// check the state of the evaluation unit
			if (unit.getState() == EvaluationState.AGAIN) {
				// the sample evaluator has requested this point be evaluated again
				// since something went wrong the first time
				
				//set the completion time
				unit.setCompletionTime();
				
				// has this point been re-submitted before?
				if (resubmissionMap.containsKey(unit)){
					// yes, check how many times
					int t = resubmissionMap.get(unit);
					if (t >= maxResubmissions){
						// maximum exceeded
						unit.setState(EvaluationState.FAILED);
						
						logger.warning("Point " + id + " has already been re-submitted " + t
								+ " times, maximum reached, point considered failed.");
					}
					
					// next resubmission
					else {
						resubmissionMap.put(unit, t+1);
						submitNewSample(unit.getInputSample());
					}
				}
				
				// max resubmissions reached
				else {
					// no, re-add it to the input queue
					resubmissionMap.put(unit, 1);
					submitNewSample(unit.getInputSample());
				}
			}
			
			else if (unit.getState() == EvaluationState.EVALUATED) {
				// set the completion time
				unit.setCompletionTime();
				
				// completed successfully, add to the evaluated queue
				fEvaluatedQueue.addAll(Arrays.asList(unit.getOutputSamples()));
				++fNumEvaluatedPoints;
				
				//update the average evaluation time
				updateAverageEvaluationTime(unit);
				
				//update the profilers
				
				//calculate the average number of samples evaluated per minute
				double elTime = (System.currentTimeMillis() - startTime);
				elTime = elTime / (60*1000);
				double samplesPerMin = ( fNumEvaluatedPoints / elTime); 
				samplesPerMinuteProfiler.addEntry( new double[]{samplesPerMin} );
				
				double ns = evaluationTimeProfiler.getRowCount();
				double et = unit.getElapsedEvaluationTime()/1000.0;
				double tt = unit.getInputOutputTime()/1000.0;
				
				evaluationTimeProfiler.addEntry(new double[]{ns,et,tt});
			}
			
			else if (unit.getState() == EvaluationState.FAILED) {
				//set the completion time
				unit.setCompletionTime();
				
				// failed point
				logger.warning("Discarded failed point " + unit.getInputSample());
			}
			
			else {
				//should never happen
				logger.severe("Invalid sample state : " + unit.getState() + " for point " + unit.getInputSample());
			}
		}
	}
	
	/**
	 * Calculate the average evaluation time based on the previous 'windowSize' samples
	 * In milliseconds!
	 */
	private void updateAverageEvaluationTime(EvaluationUnit point){
		int index = ((int)fNumEvaluatedPoints % windowSize) - 1;
		if(index < 0) index = windowSize - 1;
		
		evaluationTimeWindow[index] = point.getElapsedEvaluationTime();
		
		long max = Math.min(evaluationTimeWindow.length, fNumEvaluatedPoints);
		
		double totEvalTime = 0;
		//calculate the average and total over the window
		for(int i=0; i < max; ++i){
			totEvalTime = totEvalTime + evaluationTimeWindow[i];
		}
		fAverageEvaluationTime = totEvalTime/max;
		
		// we can also calculate the speedup
		
		// how long have we been running
		long elapsedTime = System.currentTimeMillis() - startTime;
		// if we evaluate points one by one, how long would it take
		double serialTime = fAverageEvaluationTime * fNumEvaluatedPoints;
		// whats the speedup
		double speedup = serialTime / elapsedTime;
		// log to profiler
		speedupProfiler.addEntry(new double[]{speedup});
	}
	
	
	/**
	 * Get a newly evaluated sample. Returns null if the queue is empty.
	 * @return The evaluated sample.
	 */
	public SamplePoint requestEvaluatedSample() {
		SamplePoint p = fEvaluatedQueue.poll();
		if (p != null) {
			logger.finest("Fetched sample from the evaluated queue (" + fEvaluatedQueue.size() + " points remain): " + p);
		}
		return p;
	}
	
	protected void flagAsPending(EvaluationUnit unit) {
		synchronized(fPendingSet) {
			fPendingSet.add(unit);
		}
	}

	public void cleanup(){
		pendingMonitor.stop();
	}
	
	/**
	 * Monitor the pending queue and remove all entries
	 * which have been pending for too long.
	 */
	private class PendingMonitorThread implements Runnable {
		
		/**
		 * Sleep this many seconds before checking again
		 */
		private long SLEEP = 10*1000;
		/**
		 * Remove samples whose pending time exceeds timeout*average sample evaluation time
		 */
		private double timeout = -1;
		/**
		 * Is the thread active
		 */
		private boolean active = false;
		
		/**
		 * Create a new thread that monitors the pending queue
		 * @param timeout sample timeout as a multiplier of the average sample evaluation time 
		 * For example, if set to 5 a sample is timed out if its running time exceeds 5 times the
		 * average sample evaluation time (set to <= 0 to disable)
		 * 	
		 */
		public PendingMonitorThread(double timeout) {
			this.active = true;
			this.timeout = timeout;
		}
		
		public void run() {
			if(timeout <= 0) return;
			
			long t = 0;
			double maxTime = 0;
			EvaluationUnit unit;
			
			Iterator<EvaluationUnit> it = null;
			
			logger.finer("Starting pending queue monitor thread, configured with a timeout multiplier of " + timeout);
			
			while(active) {
				
				synchronized (fPendingSet) {
					it = fPendingSet.iterator();
					while(it.hasNext()){
						unit = it.next();
						t = unit.getPendingTime();
						maxTime = timeout * averageEvaluationTime();
						if( (t >= maxTime) && (maxTime > 0) ){
							//this point has been pending for too long
							//remove it from the queue
							it.remove();
							//TODO callback to sample evaluator?
							logger.warning("Point " + unit.getInputSample() + " has been running for more than " + (maxTime/1000) + " secconds, assuming point has failed");
						}else{
							//point is still ok
						}
					}
				}
				
				try {
					Thread.sleep(SLEEP);
				} catch (InterruptedException e) {
					logger.log(Level.SEVERE,e.getMessage(),e);
				}

			}
		}
		
		public void stop(){
			this.active = false;
		}
		
	}
	
}
