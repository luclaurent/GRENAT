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

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Adds threading capabilities to BatchSampleEvaluator.  The number of threads can be chosen up to a maximum of MAX_THREADS
 */
public abstract class ThreadedBatchSampleEvaluator extends BatchSampleEvaluator {

	/**
	 * Expresses whether the thread is active or not.
	 */
	boolean fActive = false;
	/**
	 * A set of worker threads
	 */
	private Thread[] fThreads;
	/**
	 * Number of threads
	 */
	private int nThreads = 1;
	/**
	 * Max number of threads
	 */
	public static final int MAX_THREADS = 20;
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.ThreadedBatchSampleEvaluator");

	public ThreadedBatchSampleEvaluator(Config config) {
		super(config);
		
		// Read number of threads and construct & start the thread vector
		nThreads = config.self.getIntOption( "threadCount", 1 );
		
		if ( nThreads <= 0 || nThreads > MAX_THREADS ) {
			logger.warning( "Invalid threadCount value detected (" + nThreads + "), maximum is " + MAX_THREADS + ", number clipped" );
			nThreads = Math.min(nThreads, MAX_THREADS);
		}

		getStatus().setAvailableNodes(nThreads);
		getStatus().setTotalNodes(nThreads);

		logger.info( "Constructed LocalSampleEvaluator with " + nThreads + " threads (not started yet)" );
	}
	
	protected void startThreads(){
		fThreads = new Thread[nThreads];
		for (int i=0;i<nThreads;i++ ) {
			fThreads[i] = new Thread( new ExecutingThread(i) );
			fThreads[i].start();
		}
		logger.info(nThreads + " sample evaluator thread(s) started....");
	}
	
	public int getNumThreads(){
		return nThreads;
	}
	
	/**
	 * Cleanup procedure called when the sample queue thread is aborted.
	 * Stops all threads
	 */
	public void cleanup() {
		getStatus().setActive(false);
		
		logger.fine("Waiting for " + nThreads + " to finish..");
		for ( Thread t : fThreads ) {
			try {
				t.join();
			} catch (InterruptedException e) {
				SampleEvaluatorException ex = new SampleEvaluatorException( "Interrupted exception while joining threads", e);
				logger.log(Level.SEVERE, ex.getMessage(), ex);
			}
		}		

		super.cleanup();
	}
	
	private class ExecutingThread implements Runnable {
		
		int fNumber;
		
		ExecutingThread( int i ) {
			fNumber = i;
		}
		
		/**
		 * Poll for batches & queue them for evaluation.
		 */
		public void run( ) {
			EvaluationUnitBatch batch = null;
				
			// keep going until stopped
			while (getStatus().isActive()) {
				try {
					if ((batch = requestNewBatch()) != null) {
						logger.log( Level.FINEST, "Running simulator in thread " + fNumber );
						evaluate(batch);
						logger.log( Level.FINEST, "Completed simulation in thread " + fNumber );
					} else {
						// No points available, wait a while
						Thread.sleep(500);
					}
					//	Dont hog the scheduler
					Thread.sleep(100);
				} catch (InterruptedException e) {
					//we dont treat this as a major error, treat the batch as failed and try to continue
					logger.log(Level.WARNING, e.getMessage(), e);
					submitFailedBatch(batch);
				} catch (SampleEvaluatorException e) {
					//if we receive a SampleEvaluatorException, we assume something is really wrong and we
					//abort the thread and disable the sample evaluator
					logger.log(Level.SEVERE, "Problem with the sample evaluator, disabling.." +  e.getMessage(), e);
					submitFailedBatch(batch);
					getStatus().disable(e);
				}
			}
		}
	}
}
