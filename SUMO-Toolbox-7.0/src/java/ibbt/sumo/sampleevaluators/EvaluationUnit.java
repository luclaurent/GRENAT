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

import java.util.Date;
import java.util.Vector;

/**
 * An evaluation unit encapsulate a sample point for evaluation.  Important is that a single
 * input point may result in multiple output points when evaluated. This happens, for example, if
 * an input dimension is auto sampled by the simulator.
 */
public class EvaluationUnit {
	
	/**
	 * The EvaluationState includes all the different states a unit can be in:
	 *   EVALUATED: The point was evaluated correctly.
	 *   AGAIN: The point wasn't evaluated, but might succeed a next time (for cluster failover, reintroduce in new samples queue).
	 *   FAILED: The point can't be evaluated.
	 */
	public enum EvaluationState {NEW, EVALUATED, FAILED, AGAIN};
	
	/**
	 * The current state of this sample.
	 */
	private EvaluationState fState;
	
	/**
	 * Creation time.
	 */
	private Date fCreationTime;
	
	/**
	 * Time the unit was added to the input queue
	 */
	private Date fAddTime;
	
	/**
	 * Time at which the evaluation began.
	 */
	private Date fEvaluationStartTime;
	
	/**
	 * Time at which the evaluation finished.
	 */
	private Date fEvaluationFinishedTime;
	
	/**
	 * Time at which the unit has been fully evaluated, processed, and is waiting to be fetched
	 */
	private Date fCompletionTime;
	
	/**
	 * The number of other evaluation units that are evaluated at the same time (= in the same batch) as this one.
	 */
	private int fBatchSize = 1;
	
	/**
	 * Input sample.
	 */
	private SamplePoint fInSample;
	
	/**
	 * One or more output samples (can be identical to input sample).
	 */
	private Vector<SamplePoint> fOutSamples;
	
	
	/**
	 * Create a new evaluation unit.
	 */
	public EvaluationUnit(SamplePoint in) {
		if(in == null){
			throw new NullPointerException("An evaluation unit must contain a non-null input sample");
		}
		fCreationTime = new Date();
		fInSample = in;
		fOutSamples = new Vector<SamplePoint>();
		fState = EvaluationState.NEW;
	}
	
	
	/**
	 * Get the id of the evaluation unit.
	 * @return the unique id
	 */
	public long getId() {
		return fInSample.getId();
	}
	
	public int hashCode() {
		return (int)getId();
	}
	
	public boolean equals(Long id) {
		return id == getId();
	}
	
	public String toString() {
		return fInSample.toString();
	}
	
	
	/**
	 * Return the sample that was submitted for evaluation.
	 */
	public SamplePoint getInputSample() {
		return fInSample;
	}
	
	
	/**
	 * Return a list of all the output samples. Can be identical to input sample.
	 */
	public SamplePoint[] getOutputSamples() {
		return fOutSamples.toArray(new SamplePoint[0]);
	}
	
	/**
	 * Add evaluated samples.
	 */
	public void addOutputSamples(SamplePoint[] samples) {
		for (int i = 0; i < samples.length; ++i)
			fOutSamples.add(samples[i]);
	}
	
	/**
	 * Add evaluated sample.
	 */
	public void addOutputSample(SamplePoint sample) {
		fOutSamples.add(sample);
	}
	
	
	/**
	 * Get the time at which the unit was created.
	 * @return Creation time in milliseconds.
	 */
	public long getCreationTime() {
		return fCreationTime.getTime();
	}
	
	/**
	 * Set the time at which this unit was placed on the intput queue
	 */
	public void setAddTime() {
		fAddTime = new Date();
	}
	
	/**
	 * Set the time at which evaluation of the unit started.
	 */
	public void setEvaluationStartTime() {
		fEvaluationStartTime = new Date();
	}
	
	/**
	 * Set the time at which evaluation of the unit finished
	 */
	public void setEvaluationFinishedTime(){
		fEvaluationFinishedTime = new Date();
	}
	
	/**
	 * Set the completion time of this unit.
	 * Should be called when the sample arrives in the evaluation queue
	 */
	public void setCompletionTime() {
		fCompletionTime = new Date();
	}
	
	/**
	 * Return time in milliseconds that has passed since it has been created
	 */
	public long getAge() {
		return ((new Date()).getTime() - fCreationTime.getTime()) / fBatchSize;
	}
	
	/**
	 * Return time in milliseconds that has passed since it was added to the input queue
	 */
	public long getPendingTime() {
		return ((new Date()).getTime() - fAddTime.getTime()) / fBatchSize;
	}
	
	/**
	 * Get the time in milliseconds that has passed between start of evaluation
	 * of the unit and completion of the evaluation process.
	 * @return Elapsed time in milliseconds.
	 */
	public long getElapsedEvaluationTime() {
		return (fEvaluationFinishedTime.getTime() - fEvaluationStartTime.getTime()) / fBatchSize;
	}
	
	/**
	 * Get the time it took from the moment the unit was added to the input queue to the moment it was waiting to be fetched
	 */
	public long getInputOutputTime(){
		return (fCompletionTime.getTime() - fAddTime.getTime()) / fBatchSize;
	}
	
	/**
	 * Set the size of the batch this unit belongs to.
	 */
	public void setBatchSize(int size) {
		fBatchSize = size;
	}
	
	
	/**
	 * Get the evaluation state.
	 */
	public EvaluationState getState() {
		return fState;
	}
	
	/**
	 * Set the evaluation state.
	 */
	public void setState(EvaluationState s) {
		fState = s;
	}
}
