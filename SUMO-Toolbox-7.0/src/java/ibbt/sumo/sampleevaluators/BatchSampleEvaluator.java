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
import ibbt.sumo.sampleevaluators.EvaluationUnit.EvaluationState;

import java.util.logging.Logger;

/**
 * Same as BasicSampleEvaluator, only now samples can be evaluated in batches
 */
public abstract class BatchSampleEvaluator extends DefaultSampleEvaluator {

	/**
	 * The batch size.
	 */
	private int fBatchSize = 1;
	
	/**
	 * Batch we're currently filling for submission.
	 */
	private EvaluationUnitBatch fCurrentBatch = new EvaluationUnitBatch();
	
	/**
	 * Amount of samples in the current batch.
	 */
	private int fCurrentBatchSize = 0;
	
	
	private static Logger logger = Logger.getLogger("ibbt.sumo.sampleevaluators.BatchSampleEvaluator");
	
	
	public BatchSampleEvaluator(Config config) {
		super(config);
		
		fBatchSize = config.self.getIntOption("batchSize", 1);
	}
	
	/**
	 * Evaluate one batch. This function is called in a separate thread so
	 * it is non-blocking for the main thread.
	 */
	public abstract void evaluate(EvaluationUnitBatch point) throws SampleEvaluatorException;
	
	/**
	 * Request a new batch of SamplePoints from the queue. Returns null if the queue is empty.
	 */
	public EvaluationUnitBatch requestNewBatch() {
		
		// inactive, return nothing
		if (!getStatus().isActive()) return null;
		
		DefaultSampleQueueManager sqm = (DefaultSampleQueueManager)getSampleQueueManager();
		
		// try to fill up a batch
		EvaluationUnit unit;
		while ((unit = sqm.requestNewSample()) != null) {
			// add this point to the current batch
			unit.setEvaluationStartTime();
			fCurrentBatch.addEvaluationUnit(unit);
			++fCurrentBatchSize;
			
			// current batch is full, submit
			if (fCurrentBatchSize >= fBatchSize) {
				fCurrentBatchSize = 0;
				EvaluationUnitBatch batch = fCurrentBatch;
				fCurrentBatch = new EvaluationUnitBatch();
				return batch;
			}
		}
		
		// return half-full batch, better than nothing
		if (fCurrentBatchSize > 0) {
			fCurrentBatchSize = 0;
			EvaluationUnitBatch batch = fCurrentBatch;
			fCurrentBatch = new EvaluationUnitBatch();
			return batch;
		}
		
		// no sample available, return nothing
		return null;
	}
	
	/**
	 * This function is called by the derived subclass whenever a *successfully*
	 * evaluated batch of points needs to be added to the queue.
	 * @param point Evaluated point to be added.
	 */
	protected final void submitEvaluatedBatch(EvaluationUnitBatch batch) {
		EvaluationUnit[] units = batch.getEvaluatedUnits();
		for (int i = 0; i < units.length; ++i) {
			units[i].setState(EvaluationState.EVALUATED);
			units[i].setEvaluationFinishedTime();
			getSampleQueueManager().submitEvaluatedSample(units[i]);
		}
	}
	
	/**
	 * This function is called by the derived subclass whenever a FAILED batch of points
	 * needs to be added to the queue
	 */
	protected final void submitFailedBatch(EvaluationUnitBatch batch) {
		EvaluationUnit[] units = batch.getEvaluatedUnits();
		for (int i = 0; i < units.length; ++i) {
			logger.finest("Failed point " + units[i] + " added to the output queue");
			units[i].setState(EvaluationState.FAILED);
			units[i].setEvaluationFinishedTime();
			getSampleQueueManager().submitEvaluatedSample(units[i]);
		}
	}
	
	/**
	 * Cleanup procedure called when the sample queue thread is aborted.
	 * Stops the polling thread.
	 */
	public void cleanup() {
		super.cleanup();
	}
	
	public void setBatchSize(int size) {
		fBatchSize = size;
	}
}
